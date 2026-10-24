import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { FONT, colors } from "../theme";

export type PillIcon = "wifi" | "ads" | "account" | "free";

const Icon: React.FC<{ kind: PillIcon; size: number }> = ({ kind, size }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={colors.white} strokeWidth={1.8} strokeLinecap="round" strokeLinejoin="round">
    {kind === "wifi" && (
      <>
        <path d="M2 8.8a15 15 0 0 1 20 0" />
        <path d="M5 12.5a10 10 0 0 1 14 0" />
        <path d="M8.5 16a5 5 0 0 1 7 0" />
        <circle cx="12" cy="19.5" r="1" fill={colors.white} />
        <path d="M3 3l18 18" />
      </>
    )}
    {kind === "ads" && (
      <>
        <rect x="3" y="6" width="18" height="12" rx="2" />
        <text x="12" y="14.6" fontSize="6.4" fontWeight="700" textAnchor="middle" fill={colors.white} stroke="none" fontFamily="Noto, sans-serif">AD</text>
        <path d="M3 3l18 18" />
      </>
    )}
    {kind === "account" && (
      <>
        <circle cx="12" cy="8" r="3.5" />
        <path d="M5 20c0-4 3-6 7-6s7 2 7 6" />
        <path d="M3 3l18 18" />
      </>
    )}
    {kind === "free" && (
      <>
        <circle cx="12" cy="12" r="9" />
        <text x="12" y="14.8" fontSize="7.4" fontWeight="700" textAnchor="middle" fill={colors.white} stroke="none" fontFamily="Noto, sans-serif">0 €</text>
      </>
    )}
  </svg>
);

export const Pill: React.FC<{ icon: PillIcon; text: string; delay: number; size: number }> = ({
  icon,
  text,
  delay,
  size,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const enter = spring({ frame: frame - delay, fps, config: { damping: 200 }, durationInFrames: 26 });
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: size * 0.45,
        padding: `${size * 0.42}px ${size * 0.8}px`,
        borderRadius: 999,
        background: "rgba(255, 255, 255, 0.14)",
        border: "2px solid rgba(255, 255, 255, 0.32)",
        color: colors.white,
        fontFamily: FONT,
        fontSize: size,
        fontWeight: 700,
        opacity: enter,
        transform: `translateY(${interpolate(enter, [0, 1], [40, 0])}px)`,
      }}
    >
      <Icon kind={icon} size={size * 1.25} />
      <span>{text}</span>
    </div>
  );
};
