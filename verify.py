import os, glob, re

base = r"D:\project\The-Mystic-Survior二世\The-Mystic-Survior"

checks = [
    "sucai/background/2.png",
    "sucai/background/3.png",
    "sucai/background/4.png",
    "sucai/sound/wolf.wav",
    "sucai/sound/wolf_sound.wav",
    "sucai/UI/ability_card.png",
    "sucai/UI/ball.png",
    "sucai/UI/checkbutton.png",
    "sucai/png/death.png",
    "sucai/png/idle.png",
    "sucai/back_music/Failure Sound WAV.wav",
]

code_exts = ["*.gd", "*.tscn", "*.tres"]
for rel in checks:
    res_path = "res://" + rel.replace("\\", "/")
    filename = rel.split("/")[-1]
    found = False
    for ext in code_exts:
        for f in glob.glob(os.path.join(base, "**", ext), recursive=True):
            if "\\android\\" in f or "\\.godot\\" in f:
                continue
            try:
                with open(f, "r", encoding="utf-8") as fh:
                    content = fh.read()
            except:
                continue
            if res_path in content:
                found = True
                break
            # Also check for uid reference in .godot folder
        if found:
            break
    if found:
        print("REFERENCED:", rel)
    else:
        print("NOT REFERENCED:", rel)
