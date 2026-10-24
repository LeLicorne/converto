import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { FONT, colors } from "../theme";

type Props = { label: string; ok: boolean; delay: number; size: number };

export const FormatChip: React.FC<Props> = ({ label, ok, delay, size }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const enter = spring({ frame: frame - delay, fps, config: { damping: 200 }, durationInFrames: 24 });
  const stroke = ok ? colors.indigo : "#6B6678";
  return (
    <div
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: size * 0.3,
        padding: `${size * 0.28}px ${size * 0.6}px`,
        borderRadius: 999,
        background: ok ? colors.container : "#ECE8F2",
        color: ok ? colors.deep : "#6B6678",
        fontFamily: FONT,
        fontSize: size,
        fontWeight: 700,
        textDecoration: ok ? "none" : "line-through",
        boxShadow: "0 14px 36px rgba(38, 32, 112, 0.16)",
        opacity: enter,
        transform: `translateX(${interpolate(enter, [0, 1], [40, 0])}px)`,
      }}
    >
      <svg width={size * 0.9} height={size * 0.9} viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth={3} strokeLinecap="round" strokeLinejoin="round">
        {ok ? <path d="M4 12.5l5 5L20 6.5" /> : <path d="M5 5l14 14M19 5L5 19" />}
      </svg>
      <span>{label}</span>
    </div>
  );
};
