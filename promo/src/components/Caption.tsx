import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { FONT, colors } from "../theme";

type Props = {
  lines: string[];
  size: number;
  color?: string;
  align?: "left" | "center";
  delay?: number;
  stagger?: number;
  secondaryScale?: number;
};

export const Caption: React.FC<Props> = ({
  lines,
  size,
  color = colors.ink,
  align = "center",
  delay = 0,
  stagger = 5,
  secondaryScale = 0.62,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return (
    <div style={{ fontFamily: FONT, textAlign: align }}>
      {lines.map((line, index) => {
        const progress = spring({
          frame: frame - delay - index * stagger,
          fps,
          config: { damping: 200 },
          durationInFrames: 11,
        });
        const primary = index === 0;
        return (
          <div
            key={line}
            style={{
              fontSize: primary ? size : size * secondaryScale,
              fontWeight: primary ? 700 : 400,
              lineHeight: 1.18,
              marginTop: primary ? 0 : size * 0.22,
              color,
              opacity: interpolate(progress, [0, 1], [0, primary ? 1 : 0.88]),
              transform: `translateY(${interpolate(progress, [0, 1], [22, 0])}px)`,
            }}
          >
            {line}
          </div>
        );
      })}
    </div>
  );
};
