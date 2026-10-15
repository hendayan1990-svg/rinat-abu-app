"""Fast pre-release regression checks. Requires Python 3 and Node.js."""
import json
import pathlib
import re
import subprocess
import tempfile
from zipfile import ZipFile

root = pathlib.Path(__file__).resolve().parents[1]
html = (root / 'docs/index.html').read_text(encoding='utf-8')
script = re.search(r'<script>\s*(.*?)</script>', html, flags=re.S)
assert script, 'No storefront inline JavaScript found'
with tempfile.TemporaryDirectory() as tmp:
    path = pathlib.Path(tmp) / 'storefront.js'
    path.write_text(script.group(1), encoding='utf-8')
    subprocess.run(['node', '--check', str(path)], check=True)

strings = json.loads((root / 'assets/i18n.json').read_text(encoding='utf-8'))
web_strings = (root / 'docs/i18n-data.js').read_text(encoding='utf-8')
assert web_strings.startswith('window.RINAT_TRANSLATIONS=')
assert json.loads(web_strings.split('=', 1)[1].rstrip(';\n')) == strings
for key in ('עגלה', 'הוספה לעגלה +', 'פירוט החיוב לפי אתר רינת'):
    assert all(strings[key].get(lang) for lang in ('en', 'ar', 'ru')), key

catalog = json.loads((root / 'assets/products.json').read_text(encoding='utf-8'))
assert len(catalog) > 400
missing = [str(p['id']) for p in catalog if not (root / 'assets/catalog' / (str(p['id']) + '.img')).exists()]
assert not missing, f'Offline image files missing: {missing[:10]}'
main = (root / 'src/com/rinatabu/app/MainActivity.java').read_text(encoding='utf-8')
assert '"gifts","cart","updates"' in main
assert '"total_shipping"' in main and '"total_discount"' in main and '"line_total_tax"' in main
manifest = (root / 'AndroidManifest.xml').read_text(encoding='utf-8')
assert 'versionName="0.5.1-preview"' in manifest
apk = root / 'output/RINAT-ABU-0.5.1-preview.apk'
if apk.exists():
    with ZipFile(apk) as z:
        assert 'classes.dex' in z.namelist()
        assert 'assets/catalog/' + str(catalog[0]['id']) + '.img' in z.namelist()
print(json.dumps({'status': 'PASS', 'products': len(catalog), 'offline_images': len(catalog), 'translations': len(strings), 'apk_found': apk.exists()}))
