import React from "react";
import { AbsoluteFill } from "remotion";
import captions from "../captions.json";
import { Background } from "../components/Background";
import { Caption } from "../components/Caption";
import { FormatChip } from "../components/FormatChip";
import { PhoneFrame, phoneWidth } from "../components/PhoneFrame";
import { SceneFade } from "../components/SceneFade";
import { Shot } from "../components/Shot";
import type { SceneProps } from "./types";

export const Formats: React.FC<SceneProps> = ({ layout, duration }) => {
  const vertical = layout === "vertical";
  const phoneHeight = vertical ? 1100 : 900;
  const scale = vertical ? 1 : 1.2;
  const chipSize = vertical ? 46 : 52;
  const chips = (
    <>
      <FormatChip label="PDF → PNG" ok delay={Math.round(20 * scale)} size={chipSize} />
      <FormatChip label="PDF → JPG" ok delay={Math.round(32 * scale)} size={chipSize} />
      <FormatChip label="PDF → TXT" ok delay={Math.round(44 * scale)} size={chipSize} />
      <FormatChip label="PDF → MP3" ok={false} delay={Math.round(72 * scale)} size={chipSize} />
    </>
  );
  return (
    <SceneFade duration={duration}>
      <Background tone="light" />
      {vertical ? (
        <>
          <AbsoluteFill style={{ top: 190, padding: "0 70px", alignItems: "center" }}>
            <Caption lines={captions.formats} size={72} secondaryScale={1} />
          </AbsoluteFill>
          <div style={{ position: "absolute", top: 560, left: 90 }}>
            <PhoneFrame height={phoneHeight}>
              <Shot name="shot-2-ready.png" />
            </PhoneFrame>
          </div>
          <div style={{ position: "absolute", top: 900, left: 90 + phoneWidth(phoneHeight) - 120, display: "flex", flexDirection: "column", gap: 28, alignItems: "flex-start" }}>
            {chips}
          </div>
        </>
      ) : (
        <>
          <AbsoluteFill style={{ left: 140, width: 900, top: 200, justifyContent: "flex-start" }}>
            <Caption lines={captions.formats} size={78} align="left" secondaryScale={1} />
            <div style={{ marginTop: 70, display: "flex", flexWrap: "wrap", gap: 28 }}>{chips}</div>
          </AbsoluteFill>
          <div style={{ position: "absolute", top: 90, left: 1180 }}>
            <PhoneFrame height={phoneHeight}>
              <Shot name="shot-2-ready.png" />
            </PhoneFrame>
          </div>
        </>
      )}
    </SceneFade>
  );
};
