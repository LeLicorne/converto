import assert from "node:assert/strict";
import { test } from "node:test";
import {
  accessUrl,
  isValidCode,
  normalizeCode,
  parseAccessDoc,
  responsesUrl,
  toFirestoreFields,
  validate,
} from "./test-logic.js";

const valid = { platform: "android", uses: ["pdf"], why: "Pour mes cours", wouldDownload: "yes", consent: false };

test("le code est normalisé et validé", () => {
  assert.equal(normalizeCode("  conv erto-26 "), "CONVERTO-26");
  assert.equal(isValidCode("CONVERTO-26"), true);
  for (const bad of ["", "ab", "A/B/C/D", "a".repeat(40), "ÉCOLE"]) assert.equal(isValidCode(normalizeCode(bad)), false, bad);
});

test("une réponse complète est acceptée", () => {
  assert.deepEqual(validate(valid), { ok: true, errors: {} });
});

test("les champs obligatoires sont contrôlés", () => {
  const result = validate({ ...valid, platform: "windows", why: " ", wouldDownload: "peut" });
  assert.equal(result.ok, false);
  assert.deepEqual(Object.keys(result.errors).sort(), ["platform", "why", "wouldDownload"]);
});

test("le consentement est exigé dès qu'un prénom ou un e-mail est fourni", () => {
  assert.ok(validate({ ...valid, email: "a@b.fr" }).errors.consent);
  assert.ok(validate({ ...valid, firstName: "Ada" }).errors.consent);
  assert.equal(validate({ ...valid, email: "a@b.fr", consent: true }).ok, true);
  assert.ok(validate({ ...valid, email: "pas-un-mail", consent: true }).errors.email);
});

test("les usages inconnus sont refusés", () => {
  assert.ok(validate({ ...valid, uses: ["pdf", "hack"] }).errors.uses);
});

test("les champs facultatifs vides sont omis du document", () => {
  const fields = toFirestoreFields("CODE1", { ...valid, firstName: " ", email: "" });
  assert.deepEqual(Object.keys(fields).sort(), ["code", "consent", "platform", "uses", "why", "wouldDownload"]);
  assert.deepEqual(fields.uses, { arrayValue: { values: [{ stringValue: "pdf" }] } });
  assert.deepEqual(fields.consent, { booleanValue: false });
  const withContact = toFirestoreFields("CODE1", { ...valid, firstName: "Ada", email: "ada@x.fr", consent: true });
  assert.equal(withContact.email.stringValue, "ada@x.fr");
});

test("les adresses de l'API sont bien formées", () => {
  const config = { baseUrl: "https://firestore.googleapis.com", projectId: "mon-projet", apiKey: "AB CD" };
  assert.equal(
    accessUrl(config, "CODE-1"),
    "https://firestore.googleapis.com/v1/projects/mon-projet/databases/(default)/documents/access/CODE-1?key=AB%20CD"
  );
  assert.ok(responsesUrl(config).endsWith("/documents/responses?key=AB%20CD"));
});

test("seuls les liens https sont repris du document d'accès", () => {
  const doc = { fields: { groupUrl: { stringValue: "https://groups.google.com/g/x" }, testUrl: { stringValue: "javascript:alert(1)" } } };
  assert.deepEqual(parseAccessDoc(doc), { groupUrl: "https://groups.google.com/g/x", testUrl: "" });
  assert.deepEqual(parseAccessDoc({}), { groupUrl: "", testUrl: "" });
});
