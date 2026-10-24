// Logique pure de la page de test : validation et conversion vers le format de l'API REST de Firestore.
// Aucun accès au navigateur ici, pour pouvoir la tester avec Node.

export const USES = ["photos", "pdf", "media", "docs"];
export const PLATFORMS = ["android", "ios"];
export const DOWNLOAD_CHOICES = ["yes", "maybe", "no"];

export const normalizeCode = (raw) => String(raw ?? "").trim().toUpperCase().replace(/\s+/g, "");

export const isValidCode = (code) => /^[A-Z0-9-]{4,32}$/.test(code);

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

/** Renvoie { ok, errors } où errors associe un identifiant de champ à un message en français. */
export const validate = (data) => {
  const errors = {};
  if (!PLATFORMS.includes(data.platform)) errors.platform = "Choisis ton téléphone.";
  const uses = Array.isArray(data.uses) ? data.uses : [];
  if (!uses.every((use) => USES.includes(use))) errors.uses = "Choix invalide.";
  const why = String(data.why ?? "").trim();
  if (why.length < 3) errors.why = "Dis-nous en quelques mots pourquoi tu voudrais l'appli.";
  else if (why.length > 1500) errors.why = "1 500 caractères au maximum.";
  if (!DOWNLOAD_CHOICES.includes(data.wouldDownload)) errors.wouldDownload = "Choisis une réponse.";
  const firstName = String(data.firstName ?? "").trim();
  const email = String(data.email ?? "").trim();
  if (firstName.length > 80) errors.firstName = "80 caractères au maximum.";
  if (email && (!EMAIL.test(email) || email.length > 200)) errors.email = "Cette adresse e-mail ne semble pas valide.";
  if ((firstName || email) && data.consent !== true) {
    errors.consent = "Coche la case pour que je puisse utiliser ton prénom ou ton e-mail.";
  }
  return { ok: Object.keys(errors).length === 0, errors };
};

const text = (value) => ({ stringValue: value });

/** Convertit une réponse validée en champs Firestore (REST). Les champs facultatifs vides sont omis. */
export const toFirestoreFields = (code, data) => {
  const fields = {
    code: text(code),
    platform: text(data.platform),
    uses: { arrayValue: { values: (data.uses ?? []).map(text) } },
    why: text(String(data.why).trim()),
    wouldDownload: text(data.wouldDownload),
    consent: { booleanValue: data.consent === true },
  };
  const firstName = String(data.firstName ?? "").trim();
  const email = String(data.email ?? "").trim();
  if (firstName) fields.firstName = text(firstName);
  if (email) fields.email = text(email);
  return fields;
};

const documentsUrl = (config) =>
  `${config.baseUrl}/v1/projects/${encodeURIComponent(config.projectId)}/databases/(default)/documents`;

export const accessUrl = (config, code) =>
  `${documentsUrl(config)}/access/${encodeURIComponent(code)}?key=${encodeURIComponent(config.apiKey)}`;

export const responsesUrl = (config) => `${documentsUrl(config)}/responses?key=${encodeURIComponent(config.apiKey)}`;

/** Extrait les liens du test d'un document « access » Firestore ; une chaîne vide si absent. */
export const parseAccessDoc = (json) => {
  const read = (name) => String(json?.fields?.[name]?.stringValue ?? "");
  const safe = (url) => (/^https:\/\//.test(url) ? url : "");
  return { groupUrl: safe(read("groupUrl")), testUrl: safe(read("testUrl")) };
};
