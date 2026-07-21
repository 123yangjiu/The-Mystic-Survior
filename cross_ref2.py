import os, glob, re

base = r"D:\project\The-Mystic-Survior二世\The-Mystic-Survior"

# Collect all asset files
asset_files = set()
extensions = ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.wav", "*.mp3", "*.ogg", "*.json"]
for ext in extensions:
    for f in glob.glob(os.path.join(base, "**", ext), recursive=True):
        if "\\android\\" in f or "\\.godot\\" in f:
            continue
        rel = os.path.relpath(f, base)
        res_path = "res://" + rel.replace(os.sep, "/")
        asset_files.add(res_path)

print("Total asset files found:", len(asset_files))

# Search for references - match full res:// paths (including those with spaces in quotes)
code_extensions = ["*.gd", "*.tscn", "*.tres"]
referenced_assets = set()
for ext in code_extensions:
    for f in glob.glob(os.path.join(base, "**", ext), recursive=True):
        if "\\android\\" in f or "\\.godot\\" in f:
            continue
        try:
            with open(f, "r", encoding="utf-8") as fh:
                content = fh.read()
        except:
            try:
                with open(f, "r", encoding="utf-16") as fh:
                    content = fh.read()
            except:
                continue
        # Match paths inside quotes (common in tscn/tres) or after load/preload in gd
        for match in re.finditer(r'res://[^"\')]+', content):
            ref = match.group(0).strip()
            ref = ref.replace("\\", "/")
            referenced_assets.add(ref)

print("Unique res:// references found:", len(referenced_assets))

# Find unreferenced assets
unreferenced = []
for asset in sorted(asset_files):
    # Direct check (case-insensitive)
    found = any(asset.lower() == ref.lower() for ref in referenced_assets)
    if not found:
        unreferenced.append(asset)

print("\n=== UNREFERENCED ASSET FILES ===")
print("Found", len(unreferenced), "potentially unused files:\n")

# Also get file sizes
for u in unreferenced:
    full_path = os.path.join(base, u.replace("res://", "").replace("/", os.sep))
    size = os.path.getsize(full_path) if os.path.exists(full_path) else 0
    print(u, "(Size:", size, "bytes)")

# Categorize them
print("\n\n=== BY CATEGORY ===")
music = [u for u in unreferenced if "back_music" in u]
sound = [u for u in unreferenced if "sound" in u and "back_music" not in u]
background = [u for u in unreferenced if "background" in u]
enemy = [u for u in unreferenced if "enemy" in u]
icon = [u for u in unreferenced if "icon" in u]
ui_assets = [u for u in unreferenced if "UI" in u or "ui" in u]
achievement = [u for u in unreferenced if "achievement" in u]
png = [u for u in unreferenced if "png" in u and u.startswith("res://sucai/png/")]
greenfire = [u for u in unreferenced if "Green Fire" in u]
witch = [u for u in unreferenced if "\u5973\u5deb\u5e08" in u]
grassland = [u for u in unreferenced if "\u8349\u5730\u57ce\u5821" in u]
dungeon = [u for u in unreferenced if "\u8ff7\u4f60\u5730\u7262" in u]
scene_ability = [u for u in unreferenced if u.startswith("res://scene/ability/")]
video = [u for u in unreferenced if "video" in u]

categories = [
    ("Music (back_music)", music),
    ("Sound effects (sound/)", sound),
    ("Background images", background),
    ("Enemy sprites", enemy),
    ("Icons", icon),
    ("UI assets", ui_assets),
    ("Achievement images", achievement),
    ("PNG animations (sucai/png/)", png),
    ("Green Fire sprites", greenfire),
    ("Witch sprites", witch),
    ("Grassland castle tileset", grassland),
    ("Mini dungeon tileset", dungeon),
    ("Scene ability assets", scene_ability),
    ("Video screenshots", video),
]

all_other = set(unreferenced)
for name, cat_list in categories:
    for item in cat_list:
        if item in all_other:
            all_other.remove(item)

for name, cat_list in categories:
    if cat_list:
        print("\n---", name, "(" + str(len(cat_list)) + " files) ---")
        for item in cat_list:
            full_path = os.path.join(base, item.replace("res://", "").replace("/", os.sep))
            size = os.path.getsize(full_path) if os.path.exists(full_path) else 0
            print("  " + item.split("/")[-1], "-", size, "bytes")

if all_other:
    print("\n--- Other (" + str(len(all_other)) + " files) ---")
    for item in sorted(all_other):
        print("  " + item)
