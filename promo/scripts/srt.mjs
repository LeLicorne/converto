import { mkdirSync, readFileSync, writeFileSync } from "node:fs";

const timing = JSON.parse(readFileSync(new URL("../src/timing.json", import.meta.url), "utf8"));
const captions = JSON.parse(readFileSync(new URL("../src/captions.json", import.meta.url), "utf8"));
const format = (seconds) => {
  const ms = Math.round(seconds * 1000);
  const pad = (n, w = 2) => String(n).padStart(w, "0");
  return `${pad(Math.floor(ms / 3600000))}:${pad(Math.floor(ms / 60000) % 60)}:${pad(Math.floor(ms / 1000) % 60)},${pad(ms % 1000, 3)}`;
};

mkdirSync(new URL("../out/", import.meta.url), { recursive: true });
for (const [layout, name] of [["vertical", "9x16"], ["wide", "16x9"]]) {
  let start = 0;
  let index = 1;
  let srt = "";
  for (const [scene, frames] of Object.entries(timing[layout].scenes)) {
    const begin = start / timing.fps + 0.3;
    const end = (start + frames) / timing.fps - 0.2;
    srt += `${index++}\n${format(begin)} --> ${format(end)}\n${captions[scene].join("\n")}\n\n`;
    start += frames;
  }
  writeFileSync(new URL(`../out/converto-fr-${name}.srt`, import.meta.url), srt);
}
console.log("Sous-titres écrits dans promo/out/");
