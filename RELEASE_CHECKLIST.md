# Checklist de publication

Tout le code est prêt ; il reste ce qui exige votre identité, vos comptes ou une décision de votre part.

## 1. À décider / fournir (une seule fois)
- [ ] **Nom commercial** définitif (vérifier la disponibilité : App Store, Google Play, INPI/EUIPO). Il faut alors remplacer « Converto » dans `lib/l10n` (clé `appName`), `ios/Runner/*.lproj/InfoPlist.strings`, `android/app/src/main/res/values/strings.xml`, `ios/Runner/Info.plist` et `tool/strings_core.py`, puis relancer `python3 tool/gen_arb.py && flutter gen-l10n && python3 tool/gen_store.py`.
- [ ] **Identifiant d'application** : `com.baptistelore.converto` (à adapter au nom, avant la première publication — il ne peut plus changer ensuite). Android : `android/app/build.gradle.kts` (`namespace`, `applicationId`) et dossier Kotlin `MainActivity` ; iOS : `PRODUCT_BUNDLE_IDENTIFIER` dans Xcode.
- [ ] **Adresse e-mail de contact** publique et **identité de l'éditeur** : `lib/core/publisher.dart` et `tool/gen_store.py` (`CONTACT`, `PUBLISHER`). Les mentions légales d'un éditeur particulier exigent en principe nom et adresse (ou celle de l'hébergeur de la page web) ; à valider avec un juriste.
- [ ] **Icône** de l'app (1024×1024 sans transparence) : remplacer via `flutter_launcher_icons` ou à la main (Xcode AppIcon, `mipmap-*`). L'icône Flutter par défaut est encore en place.

## 2. Comptes et signatures
- [ ] Compte **Apple Developer** (99 $/an), création de l'app dans App Store Connect, certificats/profils (Xcode › Signing & Capabilities, équipe + identifiant).
- [ ] Compte **Google Play Console** (25 $ une fois). Compte existant sous contact.barelo@gmail.com : le conserver, y inviter contact@baptiste-lore.com comme administrateur (Utilisateurs et autorisations) et renseigner contact@baptiste-lore.com comme e-mail de contact public de la fiche. Le propriétaire du compte ne peut pas être changé ; pour un propriétaire sous le domaine, il faudrait un nouveau compte (25 $) puis un transfert d'app. Un compte personnel récent doit mener un **test fermé : 12 testeurs pendant 14 jours** avant de pouvoir publier en production.
- [ ] Android : créer la clé de signature (`keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`), renseigner `android/key.properties` (non versionné), puis `flutter build appbundle --release`. Activer Play App Signing.
- [ ] iOS : `flutter build ipa --release`, envoi via Xcode Organizer ou Transporter.

## 3. Pages web publiques (obligatoires pour les deux stores)
- [ ] Déployer le dossier `web/` (voir `web/README.md` : `cp .env.example .env`, ajuster `DOMAIN`, `docker compose up -d --build`).
- [ ] Coller `https://<DOMAIN>/confidentialite.html` comme URL de confidentialité dans Google Play Console (et App Store Connect plus tard). Ajouter les deux autres URLs si la console le propose.

## 4. Fiches
- [ ] Textes localisés dans `store/listing/<langue>.md` (nom, sous-titre, description courte/longue, mots-clés). Les limites de caractères sont vérifiées par `tool/gen_store.py`.
- [ ] Captures d'écran localisées (iPhone 6,9" et 6,5", iPad 13" si iPad, téléphone Android 16:9, tablette 7" et 10" recommandées). Générer depuis les simulateurs : `xcrun simctl io booted screenshot`.
- [ ] Questionnaires : suivre `store/app-privacy-answers.md`.

## 5. Contrôles avant envoi
- [ ] `flutter analyze` et `flutter test` verts ; `flutter test integration_test -d <simulateur>` vert.
- [ ] Manifeste Android fusionné sans `INTERNET` : `./gradlew :app:processReleaseMainManifest` puis lire `build/app/intermediates/merged_manifests/release/.../AndroidManifest.xml`.
- [ ] Rapport de confidentialité Xcode (Archive › Generate Privacy Report) cohérent avec `PrivacyInfo.xcprivacy`.
- [ ] Test sur appareils réels (au moins un iPhone et un Android d'entrée de gamme) : PDF volumineux, vidéo, HEIC, annulation, rotation, mode avion, VoiceOver et TalkBack, texte à 200 %.
- [ ] Audit d'accessibilité formel (RGAA / WCAG 2.1 AA) si vous souhaitez déclarer une conformité ; sinon conserver la mention « audit non réalisé ».
- [ ] Relecture juridique des mentions légales, de la politique de confidentialité et de la déclaration d'accessibilité.
