import os, glob, re

base = r"D:\project\The-Mystic-Survior二世\The-Mystic-Survior"

# Search for Brand New reference
mt = os.path.join(base, "scene", "\u5927\u573a\u666f", "maintheme.tscn")
if os.path.exists(mt):
    with open(mt, "r", encoding="utf-8") as fh:
        content = fh.read()
    for match in re.finditer(r"res://[^\s\"\')]+", content):
        if "Brand" in match.group(0):
            print("Reference found:", repr(match.group(0)))

# Check the exact res path
ext = "*.wav"
for f in glob.glob(os.path.join(base, "**", ext), recursive=True):
    if "Brand New" in f:
        rel = os.path.relpath(f, base)
        res_path = "res://" + rel.replace(os.sep, "/")
        print("Asset res path:", repr(res_path))

print("Comparing...")
asset = "res://sucai/back_music/Brand New_0.wav"
ref = "res://sucai/back_music/Brand New_0.wav"
print("Same:", asset == ref)
