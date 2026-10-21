# Converto (nom provisoire)

Convertisseur de fichiers mobile (iOS + Android), 100 % local : aucune pub, aucun compte, aucun suivi, aucune permission réseau.
Éditeur : LO RE Baptiste. Flutter 3.47 / Dart 3.13.

## Utilisation de l'app
1. Choisir un fichier (ou plusieurs, pour fusionner) : le format est détecté par son contenu.
2. Choisir le format cible : seules les conversions possibles sont proposées.
3. Régler les options (ex. PDF multi-pages → une image par page ou une seule image continue).
4. Enregistrer, partager ou ouvrir le résultat.

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

## Architecture
- `lib/features/convert/domain` : formats, options, jobs, erreurs.
- `lib/features/convert/engines` : un fichier par famille de convertisseurs (image, PDF, documents, données, archives, FFmpeg).
- `lib/features/convert/registry` : **source de vérité** de ce qui est proposé ; ajouter un format = ajouter un convertisseur + sa traduction.
- `lib/features/convert/application` : machine à états Riverpod (`ConversionController`).
- `lib/features/{home,result,settings}` : écrans. `lib/l10n` : ARB générés (7 langues).

## Commandes
```
flutter pub get
python3 tool/gen_arb.py && flutter gen-l10n     # après modification des textes (tool/strings_*.py)
python3 tool/gen_store.py                        # fiches store
python3 tool/gen_web.py                          # pages web légales (dossier web/)
flutter analyze && flutter test                  # 68 tests (unitaires, contrôleur, widgets, accessibilité)
flutter test integration_test -d <appareil>      # moteurs natifs (PDFium, FFmpeg, WebP) sur simulateur/émulateur
flutter run
flutter build appbundle --release                # Android (voir RELEASE_CHECKLIST.md pour la signature)
flutter build ipa --release                      # iOS
```
Les tests d'intégration lancés avec `--no-dds` affichent une ligne « loading … [E] » finale : c'est un artefact de l'outil, les tests eux-mêmes sont listés avec leur résultat.

## Site légal (web/)
Pages de confidentialité, d'accessibilité et mentions légales en 7 langues, déployables avec `docker compose` (voir `web/README.md`).

## Publication
Voir `RELEASE_CHECKLIST.md` (comptes, signature, hébergement des pages légales) et `store/` (fiches localisées, réponses « App Privacy » / « Data safety »).

## Licences tierces notables
FFmpeg (LGPL 3.0, build « full » sans composants GPL), PDFium (BSD/Apache), Noto Sans (SIL OFL 1.1). Écran « Licences open source » dans l'app.
