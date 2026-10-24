import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { FONT, colors } from "../theme";

type Props = {
  label: string;
  tint: string;
  x: number;
  y: number;
  size: number;
  rotate: number;
  phase: number;
  delay: number;
};

export const FileChip: React.FC<Props> = ({ label, tint, x, y, size, rotate, phase, delay }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const enter = spring({ frame: frame - delay, fps, config: { damping: 18, stiffness: 90 } });
  const float = Math.sin(frame / 26 + phase) * 14;
  const width = size;
  const height = size * 1.25;
  return (
    <div
      style={{
        position: "absolute",
        left: x - width / 2,
        top: y - height / 2 + float,
        width,
        height,
        borderRadius: size * 0.14,
        background: colors.white,
        boxShadow: "0 24px 60px rgba(38, 32, 112, 0.22)",
        transform: `rotate(${rotate}deg) scale(${interpolate(enter, [0, 1], [0.5, 1])})`,
        opacity: enter,
        overflow: "hidden",
        fontFamily: FONT,
      }}
    >
      <div style={{ height: "30%", background: tint }} />
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          height: "70%",
          fontSize: size * 0.24,
          fontWeight: 700,
          color: colors.ink,
          letterSpacing: 1,
        }}
      >
        {label}
      </div>
    </div>
  );
};
