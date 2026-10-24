import timing from "./timing.json";

export type Layout = "vertical" | "wide";

export const colors = {
  indigo: "#4F46E5",
  violet: "#6E50F0",
  deep: "#262070",
  bg: "#FBF9FF",
  ink: "#1C1B1F",
  muted: "#4A4658",
  white: "#FFFFFF",
  container: "#E3E0FF",
  line: "#D9D4E6",
};

export const FONT = "Noto, system-ui, sans-serif";

/** Passer à true une fois l'app publiée sur Google Play. */
export const SHOW_STORE_LINE = false;

export const fps = timing.fps;
/** Images de chevauchement entre scènes ; 0 = coupe franche sur le temps fort. */
export const OVERLAP = 0;
export const scenesFor = (layout: Layout) => timing[layout].scenes;
export const sizeFor = (layout: Layout) => ({
  width: timing[layout].width,
  height: timing[layout].height,
});
export const totalFrames = (layout: Layout) =>
  Object.values(scenesFor(layout)).reduce((sum, value) => sum + value, 0);
