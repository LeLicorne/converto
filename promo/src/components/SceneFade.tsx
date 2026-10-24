import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";

type Props = {
  duration: number;
  children: React.ReactNode;
  /** Coup de zoom qui se pose sur l'impact, au début de la scène. */
  punch?: boolean;
  fadeOut?: number;
};

/** Coupe franche sur le temps fort : pas de fondu d'entrée, la scène arrive pleine avec un léger zoom qui se pose. */
export const SceneFade: React.FC<Props> = ({ duration, children, punch = true, fadeOut = 0 }) => {
  const frame = useCurrentFrame();
  const scale = punch
    ? interpolate(frame, [0, 10], [1.04, 1], { extrapolateRight: "clamp", easing: (t) => 1 - (1 - t) ** 3 })
    : 1;
  const leaving =
    fadeOut > 0
      ? interpolate(frame, [duration - fadeOut, duration], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })
      : 1;
  return <AbsoluteFill style={{ opacity: leaving, transform: `scale(${scale})` }}>{children}</AbsoluteFill>;
};
