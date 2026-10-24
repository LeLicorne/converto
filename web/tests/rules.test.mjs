import { assertFails, assertSucceeds, initializeTestEnvironment } from "@firebase/rules-unit-testing";
import { addDoc, collection, deleteDoc, doc, getDoc, getDocs, setDoc, updateDoc } from "firebase/firestore";
import { readFileSync } from "node:fs";
import { after, before, beforeEach, test } from "node:test";

let env;
const base = { code: "CONVERTO-26", platform: "android", uses: ["pdf", "photos"], why: "Pour mes cours", wouldDownload: "yes", consent: false };

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-converto",
    firestore: { rules: readFileSync(new URL("../firestore.rules", import.meta.url), "utf8"), host: "127.0.0.1", port: 8080 },
  });
});
after(async () => env.cleanup());
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "access", "CONVERTO-26"), { groupUrl: "https://groups.google.com/g/x", testUrl: "https://play.google.com/apps/testing/y" });
    await setDoc(doc(context.firestore(), "responses", "existing"), { ...base });
  });
});

const db = () => env.unauthenticatedContext().firestore();
const create = (data) => addDoc(collection(db(), "responses"), data);

test("un visiteur peut lire un code précis mais pas lister les codes", async () => {
  await assertSucceeds(getDoc(doc(db(), "access", "CONVERTO-26")));
  await assertFails(getDocs(collection(db(), "access")));
});

test("un visiteur ne peut pas écrire dans access", async () => {
  await assertFails(setDoc(doc(db(), "access", "NOUVEAU-CODE"), { groupUrl: "https://evil.example" }));
  await assertFails(updateDoc(doc(db(), "access", "CONVERTO-26"), { testUrl: "https://evil.example" }));
});

test("une réponse valide est acceptée", async () => {
  await assertSucceeds(create(base));
  await assertSucceeds(create({ ...base, platform: "ios", uses: [], wouldDownload: "maybe" }));
  await assertSucceeds(create({ ...base, firstName: "Ada", email: "ada@example.fr", consent: true }));
});

test("un code d'accès inconnu est refusé", async () => {
  await assertFails(create({ ...base, code: "FAUX-CODE" }));
});

test("les champs invalides ou en trop sont refusés", async () => {
  await assertFails(create({ ...base, platform: "windows" }));
  await assertFails(create({ ...base, uses: ["pdf", "hack"] }));
  await assertFails(create({ ...base, uses: ["pdf", "photos", "media", "docs", "pdf"] }));
  await assertFails(create({ ...base, why: "ab" }));
  await assertFails(create({ ...base, why: "x".repeat(1501) }));
  await assertFails(create({ ...base, wouldDownload: "peut-être" }));
  await assertFails(create({ ...base, admin: true }));
  await assertFails(create({ ...base, consent: "oui" }));
});

test("prénom et e-mail exigent le consentement", async () => {
  await assertFails(create({ ...base, email: "ada@example.fr", consent: false }));
  await assertFails(create({ ...base, firstName: "Ada", consent: false }));
  await assertFails(create({ ...base, email: "x", consent: true }));
  await assertFails(create({ ...base, firstName: "A".repeat(81), consent: true }));
});

test("champs obligatoires manquants refusés", async () => {
  const { why, ...withoutWhy } = base;
  await assertFails(create(withoutWhy));
});

test("les réponses ne se lisent, modifient ni suppriment depuis le navigateur", async () => {
  await assertFails(getDoc(doc(db(), "responses", "existing")));
  await assertFails(getDocs(collection(db(), "responses")));
  await assertFails(updateDoc(doc(db(), "responses", "existing"), { why: "modifié" }));
  await assertFails(deleteDoc(doc(db(), "responses", "existing")));
});

test("une collection inconnue est inaccessible", async () => {
  await assertFails(setDoc(doc(db(), "autre", "x"), { a: 1 }));
  await assertFails(getDoc(doc(db(), "autre", "x")));
});
