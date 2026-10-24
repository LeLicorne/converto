import { accessUrl, isValidCode, normalizeCode, parseAccessDoc, responsesUrl, toFirestoreFields, validate } from "./test-logic.js";

const config = window.CONVERTO ?? {};
const $ = (id) => document.getElementById(id);

const stepCode = $("step-code");
const stepForm = $("step-form");
const stepDone = $("step-done");

let unlockedCode = "";
let links = { groupUrl: "", testUrl: "" };

const show = (section, focusId) => {
  for (const item of [stepCode, stepForm, stepDone]) item.hidden = item !== section;
  $(focusId).focus();
};

const setError = (id, message) => {
  const node = $(id);
  node.textContent = message ?? "";
  node.hidden = !message;
};

const available = () => Boolean(config.projectId && config.apiKey && config.baseUrl);

// ---- Étape 1 : le code ----
$("code-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  setError("code-error", "");
  if (!available()) return setError("code-error", "Cette page n'est pas encore configurée. Réessaie plus tard.");
  const code = normalizeCode($("code").value);
  if (!isValidCode(code)) return setError("code-error", "Ce code ne semble pas valide.");
  const button = $("code-submit");
  button.disabled = true;
  try {
    const response = await fetch(accessUrl(config, code));
    if (response.status === 404 || response.status === 403) {
      await new Promise((resolve) => setTimeout(resolve, 800));
      return setError("code-error", "Code incorrect.");
    }
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    links = parseAccessDoc(await response.json());
    unlockedCode = code;
    show(stepForm, "step-form-title");
  } catch {
    setError("code-error", "Impossible de vérifier le code pour le moment. Vérifie ta connexion et réessaie.");
  } finally {
    button.disabled = false;
  }
});

// ---- Étape 2 : le formulaire ----
const radio = (name) => document.querySelector(`input[name="${name}"]:checked`)?.value ?? "";

for (const input of document.querySelectorAll('input[name="platform"]')) {
  input.addEventListener("change", () => {
    const store = input.value === "ios" ? "l'App Store" : "Google Play";
    $("download-legend").textContent = `Si Converto est disponible sur ${store}, tu la télécharges ?`;
  });
}

$("signup-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  const fieldErrors = ["platform", "uses", "why", "wouldDownload", "firstName", "email", "consent"];
  for (const name of [...fieldErrors, "form"]) setError(`${name}-error`, "");

  const data = {
    platform: radio("platform"),
    uses: [...document.querySelectorAll('input[name="uses"]:checked')].map((input) => input.value),
    why: $("why").value,
    wouldDownload: radio("wouldDownload"),
    firstName: $("firstName").value,
    email: $("email").value,
    consent: $("consent").checked,
  };
  const { ok, errors } = validate(data);
  if (!ok) {
    for (const [name, message] of Object.entries(errors)) setError(`${name}-error`, message);
    const first = fieldErrors.find((name) => errors[name]);
    document.querySelector(`#${first}-error`)?.scrollIntoView({ block: "center" });
    return;
  }

  if ($("website").value) return finish(data);

  const button = $("form-submit");
  button.disabled = true;
  try {
    const response = await fetch(responsesUrl(config), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ fields: toFirestoreFields(unlockedCode, data) }),
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    finish(data);
  } catch {
    setError("form-error", "L'envoi a échoué. Vérifie ta connexion et réessaie.");
    button.disabled = false;
  }
});

// ---- Étape 3 : merci et consignes ----
const finish = (data) => {
  const android = data.platform === "android";
  $("done-android").hidden = !android;
  $("done-ios").hidden = android;
  if (android) {
    for (const [id, url] of [["group-link", links.groupUrl], ["test-link", links.testUrl]]) {
      const link = $(id);
      link.hidden = !url;
      if (url) link.href = url;
    }
    $("links-missing").hidden = Boolean(links.groupUrl && links.testUrl);
  } else {
    $("ios-contact").hidden = !String(data.email ?? "").trim();
  }
  show(stepDone, "step-done-title");
};
