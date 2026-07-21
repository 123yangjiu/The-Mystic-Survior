import os, glob, re

base = r"D:\project\The-Mystic-Survior二世\The-Mystic-Survior"

asset_files = set()
for ext in ["*.png","*.jpg","*.jpeg","*.gif","*.wav","*.mp3","*.ogg","*.json"]:
    for f in glob.glob(os.path.join(base, "**", ext), recursive=True):
        if "\\android\\" in f or "\\.godot\\" in f:
            continue
        rel = os.path.relpath(f, base)
        res_path = "res://" + rel.replace(os.sep, "/")
        asset_files.add(res_path)

referenced = set()
for ext in ["*.gd", "*.tscn", "*.tres", "*.cfg", "*.godot"]:
    for f in glob.glob(os.path.join(base, "**", ext), recursive=True):
        if "\\android\\" in f or "\\.godot\\" in f:
            continue
        try:
            with open(f, "r", encoding="utf-8") as fh:
                content = fh.read()
        except:
            continue
        # Match res:// paths (handling spaces inside quotes)
        for match in re.finditer(r'res://[^"\n)]+', content):
            ref = match.group(0).strip()
            ref = ref.replace("\\", "/")
            referenced.add(ref)

total_size = 0
unreferenced = []
for asset in sorted(asset_files):
    found = any(asset.lower() == r.lower() for r in referenced)
    if not found:
        full_path = os.path.join(base, asset.replace("res://", "").replace("/", os.sep))
        size = os.path.getsize(full_path) if os.path.exists(full_path) else 0
        total_size += size
        unreferenced.append((asset, size))

print("=== UNUSED ASSETS SUMMARY ===")
print("Total asset files:", len(asset_files))
print("Potentially unused:", len(unreferenced))
total_mb = total_size / 1024 / 1024
print("Total wasted space: {} bytes ({:.2f} MB)".format(total_size, total_mb))
print()
print("--- LARGEST UNUSED FILES ---")
for asset, size in sorted(unreferenced, key=lambda x: -x[1])[:20]:
    mb = size / 1024 / 1024
    fname = asset.split("/")[-1]
    print("  {:8.2f} MB - {} ({})".format(mb, fname, asset))
