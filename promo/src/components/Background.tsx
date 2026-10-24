import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { colors } from "../theme";

export const Background: React.FC<{ tone: "light" | "dark" | "brand" }> = ({ tone }) => {
  const frame = useCurrentFrame();
  const drift = (phase: number) => Math.sin(frame / 80 + phase) * 40;
  if (tone === "light") {
    return (
      <AbsoluteFill style={{ background: colors.bg }}>
        <div
          style={{
            position: "absolute",
            width: 900,
            height: 900,
            left: -250 + drift(0),
            top: -200 + drift(1),
            borderRadius: "50%",
            background: colors.container,
            opacity: 0.7,
            filter: "blur(110px)",
          }}
        />
        <div
          style={{
            position: "absolute",
            width: 800,
            height: 800,
            right: -250 + drift(2),
            bottom: -200 + drift(3),
            borderRadius: "50%",
            background: "#CFC8FF",
            opacity: 0.6,
            filter: "blur(120px)",
          }}
        />
      </AbsoluteFill>
    );
  }
  const gradient =
    tone === "dark"
      ? `linear-gradient(160deg, ${colors.deep}, #3A2FB0)`
      : `linear-gradient(135deg, ${colors.indigo}, ${colors.violet})`;
  return <AbsoluteFill style={{ background: gradient }} />;
};
