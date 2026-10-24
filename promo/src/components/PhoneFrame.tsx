import React from "react";

const BEZEL = 14;
const SCREEN_RATIO = 1080 / 1920;

export const phoneWidth = (height: number) => (height - BEZEL * 2) * SCREEN_RATIO + BEZEL * 2;

export const PhoneFrame: React.FC<{ height: number; children: React.ReactNode }> = ({
  height,
  children,
}) => {
  const screenHeight = height - BEZEL * 2;
  const screenWidth = screenHeight * SCREEN_RATIO;
  return (
    <div
      style={{
        width: screenWidth + BEZEL * 2,
        height,
        borderRadius: 72,
        background: "#15131C",
        padding: BEZEL,
        boxSizing: "border-box",
        boxShadow: "0 50px 100px rgba(38, 32, 112, 0.35), 0 12px 30px rgba(38, 32, 112, 0.25)",
      }}
    >
      <div
        style={{
          position: "relative",
          width: screenWidth,
          height: screenHeight,
          borderRadius: 58,
          overflow: "hidden",
          background: "#fff",
        }}
      >
        {children}
      </div>
    </div>
  );
};
