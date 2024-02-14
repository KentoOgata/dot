---@param action string
---@return function
local function uiAction(action)
  return function()
    vim.fn['ddu#ui#do_action'](action)
  end
end

---@param action string
---@param params? table
---@return function
local function itemAction(action, params)
  return function()
    vim.fn['ddu#ui#do_action']('itemAction', {
      name = action,
      params = params,
    })
  end
end

local function getUiParamsOfWindowSize()
  local lines = vim.opt.lines:get()
  local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
  local columns = vim.opt.columns:get()
  local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)
  return {
    ff = {
      winHeight = height,
      winRow = row,
      winWidth = width,
      winCol = col,
      previewWidth = math.floor(width / 2),
    },
  }
end

---@param source string|table
local function ddu(source)
  if type(source) == 'string' then
    return function()
      vim.fn['ddu#start'] {
        uiParams = getUiParamsOfWindowSize(),
        sources = {
          {
            name = source,
          },
        },
      }
    end
  elseif type(source) == 'table' then
    return function()
      vim.fn['ddu#start'] {
        uiParams = getUiParamsOfWindowSize(),
        sources = {
          source,
        },
      }
    end
  end
end

return {
  setup = function()
    vim.fn['ddu#custom#patch_global'] {
      ui = 'ff',
      uiParams = {
        ff = {
          startFilter = true,
          prompt = '> ',
          split = 'floating',
          floatingBorder = 'single',
          splitDirection = 'belowright',
          filterSplitDirection = 'floating',
          filterFloatingPosition = 'top',
          -- autoAction = {
          --   name = 'preview',
          -- },
          previewFloating = true,
          previewFloatingBorder = 'single',
          previewSplit = 'vertical',
          previewFloatingTitle = 'Preview',
          highlights = {
            floating = 'Normal',
            floatingBorder = 'Normal',
          },
        },
      },
      sourceOptions = {
        _ = {
          matchers = { 'matcher_fzf' },
          sorters = { 'sorter_fzf' },
          converters = { 'converter_devicon' },
        },
        help = {
          converters = {},
        },
        rg = {
          matchers = {},
          sorters = {},
          converters = {},
          volatile = true,
        },
        line = {
          matchers = { 'matcher_substring' },
          sorters = {},
          converters = {},
        },
      },
      kindOptions = {
        _ = {
          defaultAction = 'open',
        },
      },
      filterParams = {
        matcher_fzf = {
          highlightMatched = 'Search',
        },
        matcher_substring = {
          highlightMatched = 'Search',
        },
      },
      sourceParams = {
        file_external = {
          cmd = { 'fd', '-t', 'file' },
        },
        buffer = {
          orderby = 'asc',
        },
        lsp_references = {
          includeDeclaration = false,
        },
      },
    }

    vim.keymap.set('n', '<Plug>(ddu-buffers)', ddu 'buffer')
    vim.keymap.set('n', '<Plug>(ddu-files)', ddu 'file_external')
    vim.keymap.set('n', '<Plug>(ddu-help_tags)', ddu 'help')
    vim.keymap.set('n', '<Plug>(ddu-rg)', ddu 'rg')
    vim.keymap.set('n', '<Plug>(ddu-lines)', ddu 'line')

    vim.keymap.set('n', '<Plug>(ddu-lsp_implementations)', function()
      vim.fn['ddu#start'] {
        uiParams = vim.tbl_deep_extend('error', getUiParamsOfWindowSize(), {
          ff = {
            autoAction = {
              name = 'preview',
            },
          },
        }),
        sources = {
          {
            name = 'lsp_defenition',
            params = {
              method = 'textDocument/implementation',
            },
          },
        },
      }
    end)

    vim.keymap.set('n', '<Plug>(ddu-lsp_references)', function()
      vim.fn['ddu#start'] {
        sources = {
          {
            name = 'lsp_references',
          },
        },
        uiParams = vim.tbl_deep_extend('error', getUiParamsOfWindowSize(), {
          ff = {
            autoAction = {
              name = 'preview',
            },
          },
        }),
      }
    end)

    vim.keymap.set('n', '<Plug>(ddu-resume)', function()
      vim.fn['ddu#start'] {
        resume = true,
        uiParams = vim.tbl_deep_extend('force', getUiParamsOfWindowSize(), {
          ff = {
            startFilter = false,
          },
        }),
      }
    end)

    vim.keymap.set('n', '<Plug>(ddu-config_files)', function()
      vim.fn['ddu#start'] {
        uiParams = getUiParamsOfWindowSize(),
        sources = {
          {
            name = 'file_external',
          },
        },
        sourceOptions = {
          file_external = {
            path = vim.fs.joinpath(vim.env.XDG_DATA_HOME, 'chezmoi'),
          },
        },
      }
    end)

    vim.api.nvim_create_autocmd('FileType', {
      group = 'VimRc',
      pattern = 'ddu-ff',
      desc = 'Setup keymaps of ddu-ff',
      callback = function(ctx)
        vim.keymap.set_table {
          mode = 'n',
          opts = {
            buffer = ctx.buf,
          },
          maps = {
            { '<CR>', uiAction 'itemAction' },
            { 'i', uiAction 'openFilterWindow' },
            { 'q', uiAction 'quit' },
            { 'd', itemAction 'delete' },
            { '<SPACE>', uiAction 'toggleSelectItem', { nowait = true } },
            {
              'p',
              function()
                if vim.b[ctx.buf].previewAutocmdId ~= nil then
                  vim.api.nvim_del_autocmd(vim.b[ctx.buf].previewAutocmdId)
                else
                  vim.b[ctx.buf].previewAutocmdId = vim.api.nvim_create_autocmd('CursorMoved', {
                    buffer = ctx.buf,
                    group = 'VimRc',
                    callback = function()
                      vim.fn['ddu#ui#do_action'] 'preview'
                    end,
                  })
                end
              end,
            },
          },
        }
      end,
    })

    vim.api.nvim_create_autocmd('FileType', {
      group = 'VimRc',
      pattern = 'ddu-ff-filter',
      desc = 'Setup keymaps of ddu-ff-filter',
      callback = function(ctx)
        vim.keymap.set('i', '<CR>', function()
          vim.cmd.stopinsert()
          vim.fn['ddu#ui#do_action'] 'closeFilterWindow'
        end, { buffer = ctx.buf })
        vim.keymap.set('n', '<CR>', uiAction 'closeFilterWindow', { buffer = ctx.buf })
        vim.keymap.set('n', 'q', uiAction 'quit', { buffer = ctx.buf })
      end,
    })
  end,
}
