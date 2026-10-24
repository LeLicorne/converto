# Converto

Convertisseur de fichiers mobile (iOS + Android), 100 % local : aucune pub, aucun compte, aucun suivi, aucune permission réseau.
Éditeur : LO RE Baptiste. Flutter 3.47 / Dart 3.13. Identifiant : `com.baptistelore.converto`, version 1.0.0.

## Utilisation de l'app
1. Choisir un fichier (ou plusieurs, pour fusionner) : le format est détecté par son contenu.
2. Choisir le format cible : seules les conversions possibles sont proposées.
3. Régler les options (ex. PDF multi-pages → une image par page ou une seule image continue).
4. Enregistrer, partager ou ouvrir le résultat.

L'interface s'adapte aux tablettes (deux colonnes à partir de 840 pt) et existe en 7 langues (fr, en, es, de, it, pt, nl), suivant la langue du téléphone.

## Conversions
| Source | Cibles |
|---|---|
| Images (JPG, PNG, WebP, GIF, BMP, TIFF, HEIC, AVIF) | JPG, PNG, WebP, GIF, BMP, TIFF, PDF (un PDF ou un par image) |
| PDF | PNG/JPG/WebP (par page ou image continue, DPI, pages choisies), texte, fusion, extraction/rotation, ZIP |
| Markdown, HTML, texte, DOCX | PDF, texte (HTML pour Markdown/texte) |
| CSV, JSON, XLSX | CSV, JSON, XLSX dans tous les sens |
| Audio (MP3, AAC, M4A, WAV, FLAC, OGG, Opus, AIFF) | les autres formats audio |
| Vidéo (MP4, MOV, MKV, WebM) | MP4, MOV, MKV, WebM, GIF animé, audio |
| ZIP | extraction ; tout fichier → ZIP |

Limites connues : DOCX → PDF/texte récupère le texte et les titres, pas la mise en page ; les PDF générés couvrent les alphabets latin, grec et cyrillique (pas le chinois, le japonais ni les emoji) ; la conversion s'interrompt si l'app est quittée (l'écran reste allumé pendant le calcul).

## Architecture
- `lib/features/convert/domain` : formats, options, jobs, erreurs.
- `lib/features/convert/engines` : un fichier par famille de convertisseurs (image, PDF, documents, données, archives, FFmpeg).
- `lib/features/convert/registry` : **source de vérité** de ce qui est proposé ; ajouter un format = ajouter un convertisseur + sa traduction.
- `lib/features/convert/application` : machine à états Riverpod (`ConversionController`).
- `lib/features/{home,result,settings,pick}` : écrans et sélection de fichiers. `lib/core` : thème, mise en page adaptative, constantes d'éditeur. `lib/l10n` : ARB générés.
- `tool/` : générateurs (textes, fiches store, site web, captures, visuels). `store/` : fiches, captures, visuels. `web/` : site légal (Docker). `promo/` : publicité animée.

## Commandes
```
flutter pub get
python3 tool/gen_arb.py && flutter gen-l10n     # après modification des textes (tool/strings_*.py)
python3 tool/gen_store.py                        # fiches store (store/listing)
python3 tool/gen_web.py                          # pages du site légal (web/)
flutter analyze && flutter test                  # 73 tests (unitaires, contrôleur, widgets, accessibilité, tablette)
flutter test integration_test -d <appareil>      # moteurs natifs (PDFium, FFmpeg, WebP, HEIC) sur simulateur/émulateur
flutter run
flutter build appbundle --release                # Android, voir RELEASE_CHECKLIST.md (signature obligatoire)
flutter build ipa --release                      # iOS, voir RELEASE_CHECKLIST.md
```
Les tests d'intégration lancés avec `--no-dds` affichent une ligne « loading … [E] » finale : c'est un artefact de l'outil, les tests eux-mêmes sont listés avec leur résultat.
Si `flutter run` sur iOS échoue sur « Dart Development Service », ajoute `--no-dds`.

## Captures et visuels des stores
Les captures sont dans `store/screenshots/` (Android 1080×1920, iPhone 6.9″ 1320×2868, iPad 13″ 2064×2752 ; 5 écrans × 7 langues) et les visuels Play dans `store/graphics/`.
Pour les régénérer après un changement d'interface :
```
flutter build ios --simulator --debug -t tool/screenshots/main.dart && ./tool/screenshots/ios.sh
flutter build apk --debug --target-platform android-arm64 -t tool/screenshots/main.dart && adb install -r build/app/outputs/flutter-apk/app-debug.apk && ./tool/screenshots/android.sh
dart run tool/flatten_screenshots.dart                 # retire le canal alpha exigé par Google Play
flutter test tool/graphics --update-goldens            # visuel de présentation Play
```
Prérequis : simulateurs iPhone 16 Pro Max et iPad Pro 13″ (identifiants dans `tool/screenshots/ios.sh`), émulateur Android arm64 démarré avec `-partition-size 4096`. Le point d'entrée `tool/screenshots/main.dart` ne fait pas partie de l'app publiée.

## Publicité animée (promo/)
Vidéos de présentation en français (9:16 de 20 s et 16:9 de 30 s) générées avec Remotion : `cd promo && npm install && npm run render`. Détails et réglages dans `promo/README.md`.

## Site légal (web/)
Pages de confidentialité, d'accessibilité et mentions légales en 7 langues, déployables avec `docker compose` (voir `web/README.md`).

## Publication
Voir `RELEASE_CHECKLIST.md` (signature, Play Console, site, iOS) et `store/` (fiches localisées, réponses « App Privacy » / « Data safety »).

## Licences tierces notables
FFmpeg (LGPL 3.0, build « full » sans composants GPL), PDFium (BSD/Apache), Noto Sans (SIL OFL 1.1). Écran « Licences open source » dans l'app.
