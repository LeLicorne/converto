import html, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from strings_core import S, LANGS
import strings_about  # noqa: F401
from strings_store import LISTING, KEYWORDS, LANG_NAMES

ROOT = os.path.join(os.path.dirname(__file__), "..", "store")
PUBLISHER = "LO RE Baptiste"
ADDRESS = "36 rue Bougère, 49100 Angers, France"
CONTACT = "contact@baptiste-lore.com"

def fill(text):
    return text.replace("{publisher}", PUBLISHER).replace("{address}", ADDRESS).replace("{contact}", CONTACT)

def paragraphs(text):
    return "".join(f"<p>{html.escape(fill(p)).replace(chr(10), '<br>')}</p>" for p in text.split("\n\n"))

os.makedirs(os.path.join(ROOT, "listing"), exist_ok=True)
for l in LANGS:
    d = LISTING[l]
    with open(os.path.join(ROOT, "listing", f"{l}.md"), "w", encoding="utf-8") as f:
        f.write(f"# {LANG_NAMES[l]}\n\n- **Name** (30 max): {S['appName'][l]}\n- **Subtitle** (30 max): {d['subtitle']} ({len(d['subtitle'])})\n- **Short description** (80 max, Google Play): {d['short']} ({len(d['short'])})\n- **Keywords** (100 max, App Store): {KEYWORDS[l]} ({len(KEYWORDS[l])})\n\n## Description\n\n{d['long']}\n")
    for k, v in (("subtitle", d["subtitle"]), ("short", d["short"])):
        limit = 30 if k == "subtitle" else 80
        assert len(v) <= limit, (l, k, len(v))
    assert len(KEYWORDS[l]) <= 100, (l, "keywords", len(KEYWORDS[l]))
    assert len(d["long"]) <= 4000, (l, "long")
print("store files written")
