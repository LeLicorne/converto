import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import captions from "../captions.json";
import { Background } from "../components/Background";
import { Caption } from "../components/Caption";
import { PhoneFrame, phoneWidth } from "../components/PhoneFrame";
import { SceneFade } from "../components/SceneFade";
import { Shot } from "../components/Shot";
import type { SceneProps } from "./types";

const Screens: React.FC<{ duration: number }> = ({ duration }) => {
  const frame = useCurrentFrame();
  const u = duration / 90;
  const ramp = (from: number, to: number) =>
    interpolate(frame, [from * u, to * u], [0, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    });
  return (
    <>
      <Shot name="shot-3-options.png" />
      <Shot name="shot-4-running.png" opacity={ramp(30, 38)} />
      <Shot name="shot-5-done.png" opacity={ramp(58, 66)} />
    </>
  );
};

export const Options: React.FC<SceneProps> = ({ layout, duration }) => {
  const vertical = layout === "vertical";
  const phoneHeight = vertical ? 1100 : 900;
  const phone = (
    <PhoneFrame height={phoneHeight}>
      <Screens duration={duration} />
    </PhoneFrame>
  );
  return (
    <SceneFade duration={duration}>
      <Background tone="light" />
      {vertical ? (
        <>
          <AbsoluteFill style={{ top: 190, padding: "0 70px", alignItems: "center" }}>
            <Caption lines={captions.options} size={72} />
          </AbsoluteFill>
          <div style={{ position: "absolute", top: 560, left: (1080 - phoneWidth(phoneHeight)) / 2 }}>{phone}</div>
        </>
      ) : (
        <>
          <AbsoluteFill style={{ left: 140, width: 820, justifyContent: "center" }}>
            <Caption lines={captions.options} size={78} align="left" />
          </AbsoluteFill>
          <div style={{ position: "absolute", top: 90, left: 1180 }}>{phone}</div>
        </>
      )}
    </SceneFade>
  );
};
