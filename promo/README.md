# Publicité animée de Converto (Remotion)

Deux vidéos en français, ton calme et rassurant, générées par du code :
- `ConvertoVertical` : 1080×1920, 20 s, pour Reels, TikTok, Shorts.
- `ConvertoWide` : 1920×1080, 30 s, pour la fiche Google Play (via YouTube) et le site.

## Commandes
```
cd promo
npm install
npm run studio            # aperçu interactif
npm run render            # les deux vidéos dans out/ (MP4 H.264, 30 i/s)
npm run render:vertical   # out/converto-9x16-20s.mp4
npm run render:wide       # out/converto-16x9-30s.mp4
npm run srt               # sous-titres out/converto-fr-9x16.srt et out/converto-fr-16x9.srt
npm run check             # vérification TypeScript
```
Image fixe pour une miniature : `npx remotion still ConvertoWide out/miniature.png --frame=480`.

## Musique
La musique est **originale**, composée par code (`scripts/music.mjs`, aucun échantillon externe, donc aucun droit à gérer). Trois styles au choix :
- **`pro`** (par défaut) : pub de produit tech, sobre et net. **Un seul beat continu à 120 BPM du début à la fin, sans coupure ni changement de tempo** : grosse caisse sèche, caisse claire, charleston, basse pulsée avec sous-grave, arpège de synthé étouffé en ping-pong. Les scènes ajoutent seulement des couches par-dessus (accords courts, charleston plus serré, motif de trois notes). Aucune cloche, aucun triangle, aucune nappe « d'église ». Tous les changements de scène tombent exactement sur un temps.
- **`warm`** : feel-good (ukulélé, marimba, claps, thème sifflé).
- **`electro`** : synthés « supersaw » et grosse caisse 808.

Aux changements d'écran, le style `pro` ajoute **par-dessus le beat** (sans jamais l'interrompre) un roulement de caisse claire dont les intervalles se resserrent (accélération), un souffle ascendant, puis un léger accent de cymbale sur le temps fort. La scène confidentialité est le « drop » : charleston en doubles-croches, accords plus forts, motif plus présent.

```
npm run music                      # style pro : régénère public/music-9x16.wav et public/music-16x9.wav (ignorés par git)
node scripts/music.mjs --style=warm      # ou --style=electro
npm run render       # régénère la musique (style pro) puis les deux vidéos
npx remotion render ConvertoWide out/sans-son.mp4 --muted   # rendu sans musique
```
Réglages en tête de `scripts/music.mjs` : tempos et instruments par scène (`SCENES`), accords (`PROGRESSION`), niveau (`TARGET_RMS_DB`, `PEAK`). Niveau actuel : environ −16 LUFS, crête réelle sous −0,5 dBFS. Si les scènes changent de durée dans `timing.json`, relancer `npm run music`.

## Enchaînement des scènes
Les scènes se **coupent net** sur le temps fort de la musique (pas de fondu, pas d'écran vide) : la nouvelle scène arrive pleine, avec un léger zoom qui se pose en 10 images, et son texte entre en quelques images. Pour un enchaînement par fondu, augmenter `OVERLAP` dans `src/theme.ts` et ajouter un fondu d'entrée dans `src/components/SceneFade.tsx`.

## Où modifier quoi
- `src/captions.json` : tous les textes affichés (aussi utilisés pour les sous-titres).
- `src/timing.json` : durée de chaque scène, en images (30 i/s), pour les deux formats. La durée totale des vidéos s'en déduit.
- `src/theme.ts` : couleurs, police, et `SHOW_STORE_LINE` (voir ci-dessous).
- `src/scenes/` : les six scènes (accroche, choix du fichier, formats, options, confidentialité, final).
- `public/` : captures de l'app (Android, français), icône, police Noto Sans. Pour changer une capture, remplacer le fichier en gardant le nom.

## Formulaire de test (Google Form)
Pour diriger les gens de la story vers un formulaire (Android / iPhone, avec instructions de test pour Android), voir `google-form/README.md` : un script remplit ton formulaire existant (ou en crée un) en un clic.

## Avant de publier la vidéo
- **Mention « Disponible sur Google Play »** : désactivée tant que l'app n'est pas publiée. Passer `SHOW_STORE_LINE` à `true` dans `src/theme.ts`, puis refaire le rendu. Le badge officiel de Google est soumis à sa charte : ici, texte seul.
- **Musique** : originale (voir la section « Musique »). Pour la remplacer par un morceau tiers, n'utiliser qu'une musique libre de droits dont tu conserves la licence, la placer dans `public/` et pointer `<Audio>` dans `src/Root.tsx` vers ce fichier.
- **Affirmations** : « hors ligne », « sans pub », « sans compte », « gratuit » doivent rester vraies (fiche Play, pages légales, application).
- **Licence Remotion** : gratuite pour un particulier ou une très petite entreprise ; à revérifier sur remotion.dev si la situation change.
- La police Noto Sans est sous licence SIL OFL (`public/OFL.txt`).

## Zones de sécurité (9:16)
Le texte reste hors des 150 px du haut et des 250 px du bas, pour ne pas passer sous l'interface de Reels ou TikTok.
