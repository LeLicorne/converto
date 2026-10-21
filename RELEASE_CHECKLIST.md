# Checklist de publication

État : le code, les textes, les captures et le site légal sont prêts. Il reste les étapes qui demandent ton identité ou tes comptes.

## Décisions actées
- Nom : **Converto**. Identifiant : **`com.baptistelore.converto`** (Android et iOS, ne peut plus changer après le premier envoi). Version : **1.0.0 (build 1)**, dans `pubspec.yaml`.
- Éditeur : LO RE Baptiste, contact `contact@baptiste-lore.com`, personne physique à titre non professionnel, hébergeur OVH (méthode LCEN art. 6 III-2 : pas d'adresse publiée). Valeurs dans `lib/core/publisher.dart` et `web/.env`.
- Gratuit, sans achat, sans pub, sans compte, sans réseau. Android 8+ (API 26), iOS 16+.

## 1. Android : signer et produire le bundle
À faire une seule fois (la clé sert à toutes les futures mises à jour).

1. Créer la clé d'upload, depuis la racine du projet (la commande pose des questions : retiens le mot de passe) :
   ```
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Créer `android/key.properties` (fichier non versionné ; `storeFile` est relatif au dossier `android/`) :
   ```
   storePassword=<mot de passe du keystore>
   keyPassword=<mot de passe de la clé>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. **Sauvegarder** `android/upload-keystore.jks` et `android/key.properties` dans ton gestionnaire de mots de passe ou sur un disque sûr. Avec Play App Signing, perdre cette clé est récupérable (Google peut la réinitialiser), mais avec délai et démarches.
4. Produire le bundle :
   ```
   flutter build appbundle --release
   ```
   Résultat : `build/app/outputs/bundle/release/app-release.aab` (environ 130 Mo ; Google Play ne livre à chaque téléphone que ses propres architectures, soit environ 60 Mo). Sans `key.properties`, le build s'arrête avec un message explicite : c'est voulu, pour ne jamais produire un bundle signé en debug.
5. Vérifier la signature (doit afficher `jar verified`) :
   ```
   jarsigner -verify -certs build/app/outputs/bundle/release/app-release.aab
   ```

Ce flux a été testé de bout en bout avec une clé jetable (supprimée) : le bundle est bien signé avec la clé fournie.

## 2. Google Play Console
- [ ] **Compte** : conserve le compte existant (`contact.barelo@gmail.com`), invite `contact@baptiste-lore.com` comme administrateur (Utilisateurs et autorisations). Le propriétaire d'un compte ne peut pas être changé ; il faudrait un nouveau compte (25 $) puis un transfert d'app.
- [ ] **Statut professionnel (« trader »)** : la Console le demande. S'il est « professionnel », Google affiche publiquement ton adresse et ton téléphone sur la fiche. À apprécier selon ta situation.
- [ ] **E-mail de contact public** de la fiche : `contact@baptiste-lore.com`.
- [ ] **Créer l'app** : nom Converto, langue par défaut français, type « Application », « Gratuite ». Play App Signing est activé par défaut : accepte-le.
- [ ] **URL de politique de confidentialité** : `https://<DOMAIN>/confidentialite.html` (voir section 3).
- [ ] **Questionnaires** (Sécurité des données, Public cible, Annonces, Classification du contenu) : réponses prêtes dans `store/app-privacy-answers.md`.
- [ ] **Fiche principale** (par langue) : textes dans `store/listing/<langue>.md` (titre ≤ 30, description courte ≤ 80, description complète ≤ 4000, limites vérifiées par `tool/gen_store.py`).
- [ ] **Visuels** : icône `store/graphics/play-icon-512.png` ; image de présentation `store/graphics/play-feature-graphic-1024x500.png` ; captures téléphone `store/screenshots/android-phone-1080x1920/<langue>/` (PNG sans transparence, rapport 9:16, 2 à 8 par langue).
- [ ] **Test fermé** : un compte personnel récent doit réunir **12 testeurs pendant 14 jours** avant de passer en production. Téléverse le `.aab` sur la piste « Test fermé » et invite les testeurs.
- [ ] Déclarations demandées en fin de parcours : accessibilité (déclaration disponible dans l'app, écran ⓘ, et sur le site), application non destinée aux enfants, aucune publicité.

## 3. Site légal (obligatoire pour les deux stores)
- [ ] Déployer le dossier `web/` : `cd web && cp .env.example .env`, ajuster `DOMAIN` (proposition : `converto.baptiste-lore.com`), puis `docker compose up -d --build`. Détails dans `web/README.md`.
- [ ] Vérifier que `https://<DOMAIN>/confidentialite.html` répond, puis le coller dans la Console.

## 4. iOS (plus tard)
- [ ] Compte **Apple Developer** (99 $/an) et création de l'app dans App Store Connect avec l'identifiant `com.baptistelore.converto`.
- [ ] Dans Xcode (`open ios/Runner.xcworkspace`) : Signing & Capabilities, choisir ton équipe.
- [ ] `flutter build ipa --release`, puis envoi avec Transporter ou Xcode Organizer. La compilation de la version release a été vérifiée (`flutter build ios --release --no-codesign`).
- [ ] Captures : `store/screenshots/ios-iphone-6.9/` (1320×2868) et `store/screenshots/ios-ipad-13/` (2064×2752).
- [ ] App Privacy et âge : `store/app-privacy-answers.md`. Chiffrement : déjà déclaré (`ITSAppUsesNonExemptEncryption = false`).
- [ ] Rapport de confidentialité Xcode (Product › Archive › Generate Privacy Report) cohérent avec `ios/Runner/PrivacyInfo.xcprivacy`.

## 5. Contrôles avant d'envoyer
Déjà vérifiés : `flutter analyze` propre ; `flutter test` (73 tests) ; 14 tests d'intégration sur simulateur iOS ; app testée sur iOS et Android par toi ; build Android release ; manifeste Android sans réseau ni accès aux médias ; alignement 16 Ko des bibliothèques natives.

À refaire si tu modifies le code ou les dépendances :
```
flutter analyze && flutter test
flutter build apk --release --split-per-abi
$ANDROID_HOME/build-tools/<version>/aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
$ANDROID_HOME/build-tools/<version>/zipalign -c -P 16 -v 4 build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```
Attendu : aucune permission `INTERNET`, uniquement `WRITE_EXTERNAL_STORAGE` (limitée à Android 9 et moins) et la permission interne `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` ; `zipalign` répond « Verification successful ».

Recommandé, pas obligatoire :
- [ ] Tester sur un vrai téléphone Android d'entrée de gamme : gros PDF, vidéo, HEIC, annulation, mode avion, TalkBack, texte à 200 %.
- [ ] Faire relire les mentions légales par un juriste. Aucune loi ne l'impose ; c'est utile surtout pour la formule « à titre non professionnel ».
- [ ] Audit d'accessibilité formel (RGAA/WCAG 2.1 AA) si tu veux déclarer une conformité ; sinon la mention « audit non réalisé » reste exacte.

## 6. Quand quelque chose change
| Tu modifies | Relance |
|---|---|
| Textes de l'app (`tool/strings_*.py`) | `python3 tool/gen_arb.py && flutter gen-l10n`, puis `python3 tool/gen_web.py` et `python3 tool/gen_store.py` |
| Pages légales ou date de mise à jour (`UPDATED` dans `tool/gen_web.py`) | `python3 tool/gen_web.py`, puis redéployer `web/` |
| Interface | refaire les captures (`tool/screenshots/`, voir `README.md`) |
| Version | `pubspec.yaml` (`version: 1.0.1+2`) et `lib/core/publisher.dart` (`appVersion`) |
