import React from "react";
import { interpolate, useCurrentFrame } from "remotion";
import { colors } from "../theme";

export const TapRipple: React.FC<{ x: number; y: number; start: number; size: number }> = ({
  x,
  y,
  start,
  size,
}) => {
  const frame = useCurrentFrame() - start;
  if (frame < 0 || frame > 40) return null;
  const ring = interpolate(frame, [0, 28], [0.4, 1.7], { extrapolateRight: "clamp" });
  const ringOpacity = interpolate(frame, [0, 28], [0.9, 0], { extrapolateRight: "clamp" });
  const dot = interpolate(frame, [0, 8, 14, 40], [0, 1, 0.85, 0], { extrapolateRight: "clamp" });
  return (
    <div style={{ position: "absolute", left: `${x}%`, top: `${y}%` }}>
      <div
        style={{
          position: "absolute",
          width: size * 2,
          height: size * 2,
          left: -size,
          top: -size,
          borderRadius: "50%",
          border: `6px solid ${colors.indigo}`,
          transform: `scale(${ring})`,
          opacity: ringOpacity,
        }}
      />
      <div
        style={{
          position: "absolute",
          width: size,
          height: size,
          left: -size / 2,
          top: -size / 2,
          borderRadius: "50%",
          background: "rgba(79, 70, 229, 0.35)",
          border: `4px solid ${colors.indigo}`,
          transform: `scale(${dot})`,
        }}
      />
    </div>
  );
};
