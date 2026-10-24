# Site légal de Converto

Pages statiques (confidentialité, accessibilité, mentions légales, index) en 7 langues, servies par `nginx:alpine`.
Aucun cookie, aucun script ni police tiers : la page de confidentialité demandée par l'App Store et Google Play, plus une page de test privée (`test.html`) protégée par un code.

## Déployer
```
cp .env.example .env     # puis ajuster AUTHOR, CONTACT_EMAIL, APP_NAME, DOMAIN
docker compose up -d --build
```
Il faut le réseau Docker externe `web` et un Traefik avec l'entrypoint `websecure` et le certresolver `le`, comme pour `under-construction`. `www.<DOMAIN>` redirige en 301 vers le domaine nu.

URLs à donner aux stores : `https://<DOMAIN>/confidentialite.html` (obligatoire), `…/accessibilite.html`, `…/mentions-legales.html`.

## Page de test privée (`/test.html`)
Formulaire d'inscription au test, non référencé (noindex), caché derrière un code d'accès. Le code débloque le formulaire ; les liens du test (groupe Google et lien Play) n'apparaissent qu'après l'envoi. Adresse à donner : `https://<DOMAIN>/test.html`.

Les réponses sont stockées dans **Firestore**, via l'API REST (pas de SDK, pas de cookie, pas de stockage navigateur). Mise en place, une seule fois :
1. Console Firebase, projet `converto-32e1e` : **Firestore Database** → créer la base en mode production, dans une **région européenne** (ex. `eur3` ou `europe-west1`). La page de confidentialité annonce un hébergement en Europe : ce choix la rend vraie, et il est définitif.
2. Publier les règles : `cd web && npx firebase-tools deploy --only firestore:rules` (ou coller `firestore.rules` dans l'onglet Règles de la console).
3. Créer le document de code : collection `access`, **ID du document = le code** (majuscules, chiffres et tirets, 4 à 32 caractères, ex. `CONVERTO-26`), avec deux champs texte : `groupUrl` (lien du groupe Google) et `testUrl` (lien de participation de la Play Console). Un code = un document ; supprimer le document désactive le code.
4. Dans `.env`, `FIREBASE_PROJECT_ID` et `FIREBASE_API_KEY` (déjà dans `.env.example`), puis `docker compose up -d --build`.
5. Google Cloud Console → API et services → Identifiants : restreindre la clé API aux référents HTTP `https://<DOMAIN>/*` et à l'API Cloud Firestore.
6. Lire les réponses : console Firebase → Firestore → collection `responses` (export possible). Les règles interdisent toute lecture depuis un navigateur.

À savoir :
- Les liens ne sont pas vraiment secrets : toute personne qui a le code peut les lire (ce sont de toute façon des liens publics Google). Le code sert à filtrer l'accès au formulaire, pas à protéger un secret.
- Les règles valident chaque réponse (champs, tailles, code existant). Tests : `cd web/tests && npm install && npm test` (émulateur Firestore, nécessite Java).
- Données collectées : plateforme, usages, motivation, intention de téléchargement, et en option prénom et e-mail avec consentement. La page de confidentialité annonce une conservation de 12 mois maximum après la sortie : supprime les réponses à ce moment-là.
- Aucun Google Analytics n'est utilisé (le `measurementId` de la config Firebase est volontairement ignoré).

## Référencement
- Seule la page d'accueil est indexée (titre, description, Open Graph, Twitter, données structurées `MobileApplication`) ; les pages légales sont `noindex, follow`, donc absentes du sitemap.
- `robots.txt` et `sitemap.xml` sont générés au démarrage du conteneur à partir de `SITE_URL`.
- `test.html` n'est ni dans `robots.txt` ni dans le sitemap, et aucune page n'y renvoie : un `robots.txt` est public et révélerait son adresse. Elle est protégée par `noindex, nofollow` (balise et en-tête `X-Robots-Tag`) ; ses scripts le sont aussi.
- Une fois en ligne : déclarer le site dans Google Search Console et Bing Webmaster Tools, puis y soumettre `https://<DOMAIN>/sitemap.xml`. Quand l'app sera publiée, ajouter ses liens de store dans la page d'accueil pour qu'ils pèsent dans le référencement.

## Modifier le contenu
Les textes viennent des mêmes tableaux que l'application. Ne modifie pas les `.html` à la main :
1. éditer `tool/strings_about.py` (textes de l'app et pages) ou `tool/strings_web.py` (textes propres au site) ;
2. `python3 tool/gen_web.py` depuis la racine du projet régénère les pages ;
3. `docker compose up -d --build`.

La date « Dernière mise à jour » affichée est `UPDATED` dans `tool/gen_web.py` : à changer quand les textes légaux changent.

Les valeurs `AUTHOR`, `CONTACT_EMAIL` et l'URL du site sont injectées au démarrage du conteneur (`docker/40-site-config.sh`), qui génère aussi `robots.txt` et `sitemap.xml`.
La langue s'adapte au navigateur (`lang.js`), et reste accessible sans JavaScript via les liens de langue (français par défaut).

## À vérifier
- L'hébergeur affiché dans les mentions légales est OVH, comme pour le portfolio ; à modifier dans `tool/strings_about.py` (clé `aboutLegalBody`) si le site est ailleurs.
- `access_log` est désactivé dans nginx ; Traefik ou l'hébergeur peuvent garder leurs propres journaux, ce que la page de confidentialité mentionne.
