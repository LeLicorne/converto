import React from "react";
import { Audio, Composition, Sequence, staticFile } from "remotion";
import "./fonts";
import { Cta } from "./scenes/Cta";
import { Formats } from "./scenes/Formats";
import { Hook } from "./scenes/Hook";
import { Options } from "./scenes/Options";
import { Pick } from "./scenes/Pick";
import { Privacy } from "./scenes/Privacy";
import { Layout, OVERLAP, fps, scenesFor, sizeFor, totalFrames } from "./theme";

const ORDER = [
  ["hook", Hook],
  ["pick", Pick],
  ["formats", Formats],
  ["options", Options],
  ["privacy", Privacy],
  ["cta", Cta],
] as const;

const Ad: React.FC<{ layout: Layout }> = ({ layout }) => {
  const scenes = scenesFor(layout);
  let from = 0;
  return (
    <>
      <Audio src={staticFile(layout === "vertical" ? "music-9x16.wav" : "music-16x9.wav")} />
      {ORDER.map(([key, Scene], index) => {
        const duration = scenes[key];
        const element = (
          <Sequence
            key={key}
            from={from}
            durationInFrames={duration + (index < ORDER.length - 1 ? OVERLAP : 0)}
          >
            <Scene layout={layout} duration={duration} />
          </Sequence>
        );
        from += duration;
        return element;
      })}
    </>
  );
};

export const Root: React.FC = () => (
  <>
    <Composition
      id="ConvertoVertical"
      component={Ad}
      defaultProps={{ layout: "vertical" as Layout }}
      durationInFrames={totalFrames("vertical")}
      fps={fps}
      {...sizeFor("vertical")}
    />
    <Composition
      id="ConvertoWide"
      component={Ad}
      defaultProps={{ layout: "wide" as Layout }}
      durationInFrames={totalFrames("wide")}
      fps={fps}
      {...sizeFor("wide")}
    />
  </>
);
