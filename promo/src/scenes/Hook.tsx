import React from "react";
import { AbsoluteFill } from "remotion";
import captions from "../captions.json";
import { Background } from "../components/Background";
import { Caption } from "../components/Caption";
import { FileChip } from "../components/FileChip";
import { SceneFade } from "../components/SceneFade";
import type { SceneProps } from "./types";

const CHIPS = [
  { label: "PDF", tint: "#E5484D" },
  { label: "HEIC", tint: "#3E63DD" },
  { label: "DOCX", tint: "#2B6CB0" },
  { label: "MKV", tint: "#8E4EC6" },
  { label: "CSV", tint: "#30A46C" },
  { label: "WEBP", tint: "#F76B15" },
];

const POSITIONS = {
  vertical: [
    [230, 560], [830, 520], [170, 1290], [880, 1260], [560, 1530], [560, 330],
  ],
  wide: [
    [330, 250], [1560, 220], [250, 830], [1680, 840], [960, 920], [960, 150],
  ],
} as const;

export const Hook: React.FC<SceneProps> = ({ layout, duration }) => {
  const vertical = layout === "vertical";
  const size = vertical ? 190 : 200;
  return (
    <SceneFade duration={duration} punch={false}>
      <Background tone="light" />
      {CHIPS.map((chip, index) => (
        <FileChip
          key={chip.label}
          label={chip.label}
          tint={chip.tint}
          x={POSITIONS[layout][index][0]}
          y={POSITIONS[layout][index][1]}
          size={size}
          rotate={[-8, 7, 6, -6, 4, -4][index]}
          phase={index * 1.3}
          delay={4 + index * 5}
        />
      ))}
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", padding: vertical ? "0 90px" : "0 380px" }}>
        <Caption lines={captions.hook} size={vertical ? 96 : 92} delay={4} />
      </AbsoluteFill>
    </SceneFade>
  );
};
