#!/bin/sh
# Génère les pages HTML (placeholders remplacés), robots.txt et sitemap.xml depuis l'env à chaque démarrage.
set -eu

WEB=/usr/share/nginx/html
TPL=/opt/templates

AUTHOR=${AUTHOR:-LO RE Baptiste}
CONTACT_EMAIL=${CONTACT_EMAIL:-contact@baptiste-lore.com}
SITE_URL=$(printf '%s' "${SITE_URL:-https://converto.baptiste-lore.com}" | sed 's|/*$||')

hesc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'; }
sesc() { sed -e 's/[\\&|]/\\&/g'; }

for tpl in "$TPL"/*.html; do
  page="$WEB/$(basename "$tpl")"
  cp "$tpl" "$page"
  for pair in "AUTHOR=$AUTHOR" "CONTACT_EMAIL=$CONTACT_EMAIL" "SITE_URL=$SITE_URL"; do
    key=${pair%%=*}
    val=$(hesc "${pair#*=}" | sesc)
    sed -i "s|{{$key}}|$val|g" "$page"
  done
done

printf 'User-agent: *\nAllow: /\n\nSitemap: %s/sitemap.xml\n' "$SITE_URL" > "$WEB/robots.txt"
cat > "$WEB/sitemap.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>$(hesc "$SITE_URL")/</loc><lastmod>$(date +%F)</lastmod></url>
</urlset>
XML
