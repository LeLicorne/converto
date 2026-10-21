# Site légal de Converto

Pages statiques (confidentialité, accessibilité, mentions légales, index) en 7 langues, servies par `nginx:alpine`.
Aucun cookie, aucun script ni police tiers, aucun formulaire : la page de confidentialité demandée par l'App Store et Google Play.

## Déployer
```
cp .env.example .env     # puis ajuster AUTHOR, CONTACT_EMAIL, APP_NAME, DOMAIN
docker compose up -d --build
```
Il faut le réseau Docker externe `web` et un Traefik avec les entrypoint `websecure` et le certresolver `le`, comme pour `under-construction`. `www.<DOMAIN>` redirige en 301 vers le domaine nu.

URLs à donner aux stores : `https://<DOMAIN>/confidentialite.html` (obligatoire), `…/accessibilite.html`, `…/mentions-legales.html`.

## Modifier le contenu
Les textes viennent des mêmes tableaux que l'application. Ne modifie pas les `.html` à la main :
1. éditer `tool/strings_about.py` (textes de l'app et pages) ou `tool/strings_web.py` (textes propres au site) ;
2. `python3 tool/gen_web.py` depuis la racine du projet régénère les pages ;
3. `docker compose up -d --build`.

Les valeurs `AUTHOR`, `CONTACT_EMAIL` et l'URL du site sont injectées au démarrage du conteneur (`docker/40-site-config.sh`), qui génère aussi `robots.txt` et `sitemap.xml`.
La langue s'adapte au navigateur (`lang.js`), et reste accessible sans JavaScript via les liens de langue (français par défaut).

## À vérifier
- L'hébergeur affiché dans les mentions légales est OVH, comme pour le portfolio ; à modifier dans `tool/strings_about.py` (clé `aboutLegalBody`) si le site est ailleurs.
- `access_log` est désactivé dans nginx ; Traefik ou l'hébergeur peuvent garder leurs propres journaux, ce que la page de confidentialité mentionne.
