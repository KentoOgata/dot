-- ORIGINAL:
-- https://scrapbox.io/vim-jp/boolean%E3%81%AA%E5%80%A4%E3%82%92%E8%BF%94%E3%81%99vim.fn%E3%81%AEwrapper_function
vim.bool_fn = setmetatable({}, {
  __index = function(_, key)
    return function(...)
      return not vim.fn.empty(vim.fn[key](...))
    end
  end,
})

---@param config { mode: string|table, maps: table, opts: table|nil }
---@diagnostic disable-next-line: duplicate-set-field
function vim.keymap.set_table(config)
  for _, map in ipairs(config.maps) do
    local lhs, rhs, opts =
      map[1], map[2], ((map[3] and config.opts) and vim.tbl_deep_extend('error', config.opts, map[3])) or map[3]

    vim.keymap.set(config.mode, lhs, rhs, opts or config.opts)
  end
end
