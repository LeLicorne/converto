import React from "react";
import { AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import captions from "../captions.json";
import { Background } from "../components/Background";
import { SceneFade } from "../components/SceneFade";
import { FONT, SHOW_STORE_LINE, colors } from "../theme";
import type { SceneProps } from "./types";

export const Cta: React.FC<SceneProps> = ({ layout, duration }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const vertical = layout === "vertical";
  const enter = spring({ frame: frame - 4, fps, config: { damping: 15, stiffness: 90 } });
  const text = spring({ frame: frame - 16, fps, config: { damping: 200 }, durationInFrames: 28 });
  const icon = vertical ? 300 : 280;
  return (
    <SceneFade duration={duration} fadeOut={10}>
      <Background tone="brand" />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", flexDirection: "column", gap: vertical ? 56 : 46, padding: "0 80px", fontFamily: FONT, color: colors.white, textAlign: "center" }}>
        <Img
          src={staticFile("icon.png")}
          style={{
            width: icon,
            height: icon,
            borderRadius: icon * 0.22,
            boxShadow: "0 40px 90px rgba(20, 16, 80, 0.45)",
            transform: `scale(${interpolate(enter, [0, 1], [0.4, 1])})`,
            opacity: enter,
          }}
        />
        <div style={{ opacity: text, transform: `translateY(${interpolate(text, [0, 1], [30, 0])}px)` }}>
          <div style={{ fontSize: vertical ? 140 : 130, fontWeight: 700, lineHeight: 1 }}>{captions.cta[0]}</div>
          <div style={{ marginTop: 30, fontSize: vertical ? 50 : 46, opacity: 0.9, maxWidth: vertical ? 820 : 1100 }}>{captions.cta[1]}</div>
          {SHOW_STORE_LINE && (
            <div style={{ marginTop: 44, fontSize: vertical ? 54 : 50, fontWeight: 700 }}>Disponible sur Google Play</div>
          )}
        </div>
      </AbsoluteFill>
    </SceneFade>
  );
};
