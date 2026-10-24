import { continueRender, delayRender, staticFile } from "remotion";

if (typeof document !== "undefined") {
  const handle = delayRender("polices Noto Sans");
  const faces = [
    new FontFace("Noto", `url(${staticFile("NotoSans-Regular.ttf")})`, { weight: "400" }),
    new FontFace("Noto", `url(${staticFile("NotoSans-Bold.ttf")})`, { weight: "700" }),
  ];
  Promise.all(faces.map((face) => face.load()))
    .then((loaded) => {
      loaded.forEach((face) => document.fonts.add(face));
      continueRender(handle);
    })
    .catch((error) => {
      console.error(error);
      continueRender(handle);
    });
}
