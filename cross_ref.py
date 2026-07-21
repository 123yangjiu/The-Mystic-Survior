import os, glob, re

base = r'D:\project\The-Mystic-Survior二世\The-Mystic-Survior'

# 1. Collect all asset files
asset_files = set()
extensions = ['*.png','*.jpg','*.jpeg','*.gif','*.wav','*.mp3','*.ogg','*.json']
for ext in extensions:
    for f in glob.glob(os.path.join(base, '**', ext), recursive=True):
        if '\\android\\' in f or '\\.godot\\' in f:
            continue
        rel = os.path.relpath(f, base)
        res_path = 'res://' + rel.replace(os.sep, '/')
        asset_files.add(res_path)

print('Total asset files found:', len(asset_files))

# 2. Search for res:// references in code files
code_extensions = ['*.gd', '*.tscn', '*.tres']
referenced_assets = set()
for ext in code_extensions:
    for f in glob.glob(os.path.join(base, '**', ext), recursive=True):
        if '\\android\\' in f or '\\.godot\\' in f:
            continue
        try:
            with open(f, 'r', encoding='utf-8') as fh:
                content = fh.read()
        except:
            try:
                with open(f, 'r', encoding='utf-16') as fh:
                    content = fh.read()
            except:
                continue
        for match in re.finditer(r'res://[^\s"\')]+', content):
            ref = match.group(0)
            ref = ref.replace('\\', '/')
            referenced_assets.add(ref)

print('Unique res:// references found:', len(referenced_assets))

# 3. Find unreferenced assets
unreferenced = []
for asset in sorted(asset_files):
    found = asset in referenced_assets
    if not found:
        for ref in referenced_assets:
            if asset.lower() == ref.lower():
                found = True
                break
    if not found:
        full_path = os.path.join(base, asset.replace('res://', '').replace('/', os.sep))
        size = os.path.getsize(full_path) if os.path.exists(full_path) else 0
        unreferenced.append((asset, size))

print('\n=== UNREFERENCED ASSET FILES ===')
print('Found', len(unreferenced), 'potentially unused files:\n')
for u, size in unreferenced:
    print(u, '(Size:', size, 'bytes)')
