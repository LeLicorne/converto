(() => {
  "use strict";
  const supported = ["fr", "en", "es", "de", "it", "pt", "nl"];
  const current = location.hash.slice(1);
  if (supported.includes(current) || current === "content") return;
  for (const tag of navigator.languages || [navigator.language || "fr"]) {
    const code = tag.slice(0, 2).toLowerCase();
    if (supported.includes(code)) {
      if (code !== "fr") location.replace("#" + code);
      return;
    }
  }
})();
