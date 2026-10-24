import React from "react";
import { AbsoluteFill } from "remotion";
import captions from "../captions.json";
import { Background } from "../components/Background";
import { Caption } from "../components/Caption";
import { PhoneFrame, phoneWidth } from "../components/PhoneFrame";
import { SceneFade } from "../components/SceneFade";
import { Shot } from "../components/Shot";
import { TapRipple } from "../components/TapRipple";
import { colors } from "../theme";
import type { SceneProps } from "./types";

export const Pick: React.FC<SceneProps> = ({ layout, duration }) => {
  const vertical = layout === "vertical";
  const phoneHeight = vertical ? 1100 : 900;
  const phone = (
    <PhoneFrame height={phoneHeight}>
      <Shot name="shot-1-idle.png" />
      <TapRipple x={50} y={42} start={vertical ? 52 : 70} size={vertical ? 96 : 84} />
    </PhoneFrame>
  );
  return (
    <SceneFade duration={duration}>
      <Background tone="light" />
      {vertical ? (
        <>
          <AbsoluteFill style={{ top: 190, padding: "0 80px", alignItems: "center" }}>
            <Caption lines={captions.pick} size={80} />
          </AbsoluteFill>
          <div style={{ position: "absolute", top: 560, left: (1080 - phoneWidth(phoneHeight)) / 2 }}>{phone}</div>
        </>
      ) : (
        <>
          <AbsoluteFill style={{ left: 140, width: 800, justifyContent: "center" }}>
            <Caption lines={captions.pick} size={84} align="left" color={colors.ink} />
          </AbsoluteFill>
          <div style={{ position: "absolute", top: 90, left: 1180 }}>{phone}</div>
        </>
      )}
    </SceneFade>
  );
};
