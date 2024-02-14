import {
  ActionFlags,
  DduOptions,
  FfParams,
  GitStatusActionData,
} from "../../../deps.ts";

export function globalConfig(): Partial<DduOptions> {
  return {
    ui: "ff",
    uiParams: {
      ff: {
        startFilter: true,
        prompt: "> ",
        split: "floating",
        floatingBorder: "single",
        filterSplitDirection: "floating",
        filterFloatingPosition: "top",
        previewFloating: true,
        previewFloatingBorder: "single",
        previewFloatingTitle: "Preview",
        highlights: {
          floating: "NormalFloat",
          floatingBorder: "FloatBorder",
        },
        autoAction: {
          name: "preview",
        },
      } satisfies Partial<FfParams>,
    },
    sourceOptions: {
      _: {
        matchers: ["matcher_fzf"],
        sorters: ["sorter_fzf"],
        converters: ["converter_devicon"],
      },
      help: {
        converters: [],
      },
      rg: {
        matchers: [],
        sorters: [],
        converters: ["converter_hl_dir"],
        volatile: true,
      },
      line: {
        matchers: ["matcher_substring"],
        sorters: [],
        converters: [],
      },
      file_external: {
        converters: ["converter_hl_dir", "converter_devicon"],
      },
      deno_module: {
        volatile: true,
        columns: ["filename"],
      },
      git_status: {
        converters: [
          "converter_devicon",
          "converter_hl_dir",
          "converter_git_status",
        ],
      },
      git_branch: {
        columns: [
          "git_branch_head",
          "git_branch_remote",
          "git_branch_name",
          "git_branch_upstream",
          "git_branch_author",
          "git_branch_date",
        ],
      },
    },
    kindOptions: {
      file: {
        defaultAction: "open",
      },
      help: {
        defaultAction: "open",
      },
      lsp: {
        defaultAction: "open",
      },
      lsp_codeAction: {
        defaultAction: "apply",
      },
      ui_select: {
        defaultAction: "select",
      },
      action: {
        defaultAction: "do",
      },
      deno_module: {
        defaultAction: "resolve",
      },
      git_status: {
        defaultAction: "open",
        actions: {
          chaperon: async (args) => {
            const { denops, items } = args;
            for (const item of items) {
              const action = item.action as GitStatusActionData;
              await denops.cmd(`GinChaperon ${action.path}`);
            }
            return ActionFlags.None;
          },
          patch: async (args) => {
            const { denops, items } = args;
            for (const item of items) {
              const action = item.action as GitStatusActionData;
              await denops.cmd(`GinPatch ${action.path}`);
            }
            return ActionFlags.None;
          },
        },
      },
      git_branch: {
        defaultAction: "switch",
      },
      git_repo: {
        defaultAction: "find",
      },
    },
    kindParams: {
      file: {
        trashCommand: ["trash"],
      },
    },
    filterParams: {
      matcher_fzf: {
        highlightMatched: "Search",
      },
      matcher_substring: {
        highlightMatched: "Search",
      },
      converter_hl_dir: {
        hlGroup: "String",
      },
    },
    sourceParams: {
      file_external: {
        cmd: ["fd", "-t", "file"],
      },
      buffer: {
        orderby: "asc",
      },
      lsp_references: {
        includeDeclaration: false,
      },
    },
  };
}
