import { DduOptions, Denops, opt } from "../../deps.ts";
import { globalConfig } from "./ff/global.ts";

export async function main(denops: Denops) {
  await denops.batch(["ddu#custom#patch_global", globalConfig()]);
  await watchVimSize(denops, "VimRc");
}

async function watchVimSize(denops: Denops, augroup: string) {
  const fn = "notifyVimSize";
  denops.dispatcher = {
    ...denops.dispatcher,
    [fn]: async () => {
      const lines = await opt.lines.get(denops);
      const columns = await opt.columns.get(denops);

      const winHeight = Math.floor(lines * 0.8);
      const winRow = Math.floor(lines * 0.1);
      const winWidth = Math.floor(columns * 0.8);
      const winCol = Math.floor(columns * 0.1);

      const [
        previewSplit,
        previewHeight,
        previewWidth,
      ] = columns < 200
        ? ["horizontal", Math.floor(winHeight / 2), winWidth]
        : ["vertical", winHeight, Math.floor(winWidth / 2)];

      await denops.batch([
        "ddu#custom#patch_global",
        {
          uiParams: {
            ff: {
              winHeight,
              winRow,
              winWidth,
              winCol,
              previewWidth,
              previewHeight,
              previewSplit,
            },
          },
        } satisfies Partial<DduOptions>,
      ]);
    },
  };

  await denops.dispatcher[fn]();

  await denops.cmd(
    `au ${augroup} VimResized * call denops#notify('${denops.name}', '${fn}', [])`,
  );
}
