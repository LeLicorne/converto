import React from "react";
import { Img, staticFile } from "remotion";

export const Shot: React.FC<{ name: string; opacity?: number }> = ({ name, opacity = 1 }) => (
  <Img
    src={staticFile(name)}
    style={{
      position: "absolute",
      inset: 0,
      width: "100%",
      height: "100%",
      objectFit: "cover",
      opacity,
    }}
  />
);
