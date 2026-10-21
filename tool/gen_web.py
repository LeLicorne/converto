import html, os, re, shutil, sys
sys.path.insert(0, os.path.dirname(__file__))
from strings_core import S, LANGS
import strings_about  # noqa: F401
from strings_store import LANG_NAMES
from strings_web import W

ROOT = os.path.join(os.path.dirname(__file__), "..", "web")
DEFAULT_LANG = "fr"
UPDATED = "2026-10-21"
ORDER = [DEFAULT_LANG] + [l for l in LANGS if l != DEFAULT_LANG]

PAGES = {
    "confidentialite": ("aboutPrivacy", "aboutPrivacyBody", True),
    "accessibilite": ("aboutAccessibility", "aboutAccessibilityBody", False),
    "mentions-legales": ("aboutLegal", "aboutLegalBody", False),
}

def fill(text):
    text = text.replace("{publisher}", "{{AUTHOR}}").replace("{contact}", "{{CONTACT_EMAIL}}")
    return text

def para(text):
    out = []
    for p in fill(text).split("\n\n"):
        esc = html.escape(p, quote=False).replace("\n", "<br>")
        esc = esc.replace("{{CONTACT_EMAIL}}", '<a href="mailto:{{CONTACT_EMAIL}}">{{CONTACT_EMAIL}}</a>')
        out.append(f"<p>{esc}</p>")
    return "".join(out)

def nav(lang_active=None):
    items = "".join(f'<li><a href="#{l}" hreflang="{l}" lang="{l}">{LANG_NAMES[l]}</a></li>' for l in ORDER)
    return f'<nav class="langs" aria-label="{html.escape(W["language"][DEFAULT_LANG])} / Language"><ul>{items}</ul></nav>'

def shell(title, description, canonical, body, noindex):
    robots = "noindex, follow" if noindex else "index, follow"
    return f'''<!doctype html>
<html lang="{DEFAULT_LANG}">
<head>
<!-- Les valeurs entre doubles accolades sont remplacées au démarrage du conteneur (docker/40-site-config.sh). Fichier généré par tool/gen_web.py : ne pas modifier à la main. -->
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<meta name="description" content="{html.escape(description)}">
<meta name="robots" content="{robots}">
<link rel="canonical" href="{{{{SITE_URL}}}}/{canonical}">
<meta name="color-scheme" content="light dark">
<meta name="theme-color" content="#4f46e5">
<link rel="icon" href="assets/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="assets/apple-touch-icon.png">
<link rel="stylesheet" href="style.css">
</head>
<body>
<a class="skip" href="#content">{html.escape(W["skip"][DEFAULT_LANG])}</a>
<main id="content" class="doc">
<header class="brand"><img src="assets/favicon.svg" alt="" width="40" height="40"><span>Converto</span></header>
{nav()}
<div class="langs-content">
{body}
</div>
</main>
<script src="lang.js"></script>
</body>
</html>
'''

def section(lang, inner):
    return f'<section id="{lang}" class="lang" lang="{lang}">{inner}</section>'

def build_doc(slug, title_key, body_key, with_site_note):
    secs = ""
    for l in ORDER:
        inner = f'<p class="back"><a href="./">{html.escape(W["back"][l])}</a></p>'
        inner += f'<h1>{html.escape(S[title_key][l])}</h1>'
        inner += f'<p class="meta">{html.escape(W["updated"][l].format(date=UPDATED))}</p>'
        inner += para(S[body_key][l])
        if with_site_note:
            inner += f'<h2>{html.escape(W["siteHeading"][l])}</h2>' + para(W["siteNote"][l])
        secs += section(l, inner)
    title = f'{S[title_key][DEFAULT_LANG]} — Converto'
    return shell(title, S[title_key][DEFAULT_LANG] + " — Converto", f"{slug}.html", secs, True)

def build_index():
    secs = ""
    for l in ORDER:
        links = "".join(
            f'<li><a href="{slug}.html#{l}">{html.escape(S[tk][l])}</a></li>'
            for slug, (tk, _, _) in PAGES.items()
        )
        inner = f'<h1>Converto</h1><p>{html.escape(W["intro"][l])}</p><ul class="docs">{links}</ul>'
        secs += section(l, inner)
    return shell("Converto", W["intro"][DEFAULT_LANG], "", secs, False)

os.makedirs(ROOT, exist_ok=True)
for slug, (tk, bk, note) in PAGES.items():
    with open(os.path.join(ROOT, f"{slug}.html"), "w", encoding="utf-8") as f:
        f.write(build_doc(slug, tk, bk, note))
with open(os.path.join(ROOT, "index.html"), "w", encoding="utf-8") as f:
    f.write(build_index())
print("web pages written")
