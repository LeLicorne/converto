import React from "react";
import { AbsoluteFill } from "remotion";
import captions from "../captions.json";
import { Background } from "../components/Background";
import { Caption } from "../components/Caption";
import { Pill } from "../components/Pill";
import { SceneFade } from "../components/SceneFade";
import { colors } from "../theme";
import type { SceneProps } from "./types";

export const Privacy: React.FC<SceneProps> = ({ layout, duration }) => {
  const vertical = layout === "vertical";
  const size = vertical ? 58 : 52;
  const gap = vertical ? 34 : 36;
  const step = vertical ? 10 : 14;
  const first = 16;
  return (
    <SceneFade duration={duration}>
      <Background tone="dark" />
      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
          gap: vertical ? 110 : 90,
          padding: vertical ? "0 60px" : "0 200px",
        }}
      >
        <Caption lines={captions.privacy} size={vertical ? 84 : 88} color={colors.white} />
        <div
          style={{
            display: vertical ? "flex" : "grid",
            flexDirection: "column",
            gridTemplateColumns: "repeat(2, auto)",
            justifyContent: "center",
            justifyItems: "start",
            alignItems: "center",
            gap,
          }}
        >
          <Pill icon="wifi" text="Hors ligne" delay={first} size={size} />
          <Pill icon="ads" text="Sans pub" delay={first + step} size={size} />
          <Pill icon="account" text="Sans compte" delay={first + step * 2} size={size} />
          <Pill icon="free" text="Gratuit" delay={first + step * 3} size={size} />
        </div>
      </AbsoluteFill>
    </SceneFade>
  );
};
