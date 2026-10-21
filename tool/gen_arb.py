import json, os, sys
sys.path.insert(0, os.path.dirname(__file__))
import strings_core
import strings_about  # noqa: F401
from strings_core import S, LANGS

out = os.path.join(os.path.dirname(__file__), "..", "lib", "l10n")
for lang in LANGS:
    data = {"@@locale": lang}
    for key, entry in S.items():
        data[key] = entry[lang]
        if lang == "en" and entry["_meta"]:
            data["@" + key] = entry["_meta"]
    with open(os.path.join(out, f"app_{lang}.arb"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
print(len(S), "keys")
