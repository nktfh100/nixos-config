import colorsys
from pathlib import Path
import re
import sys


colors = {
    "#180b14": "#181926",
    "#19050e": "#181926",
    "#1c1019": "#1e2030",
    "#21101c": "#24273a",
    "#21141e": "#24273a",
    "#261522": "#24273a",
    "#33202b": "#363a4f",
    "#341526": "#363a4f",
    "#38212e": "#363a4f",
    "#481323": "#363a4f",
    "#482232": "#363a4f",
    "#4c172c": "#363a4f",
    "#512035": "#494d64",
    "#51283b": "#494d64",
    "#512a3c": "#494d64",
    "#532536": "#494d64",
    "#542039": "#494d64",
    "#563040": "#494d64",
    "#583044": "#494d64",
    "#593143": "#494d64",
    "#613146": "#5b6078",
    "#624352": "#5b6078",
    "#633049": "#5b6078",
    "#663046": "#5b6078",
    "#6c2338": "#5b6078",
    "#6e5360": "#6e738d",
    "#77243c": "#6e738d",
    "#794155": "#6e738d",
    "#894059": "#7f849c",
    "#8fd18a": "#a6da95",
    "#91536a": "#7f849c",
    "#987184": "#939ab7",
    "#b698a6": "#a5adcb",
    "#bd9eac": "#a5adcb",
    "#be5470": "#7dc4e4",
    "#c7aab7": "#b8c0e0",
    "#c84861": "#8aadf4",
    "#d8b9c5": "#b8c0e0",
    "#dc4a57": "#8aadf4",
    "#df8d9e": "#91d7e3",
    "#e33955": "#8aadf4",
    "#e34562": "#8aadf4",
    "#ecd5de": "#cad3f5",
    "#ecdce3": "#cad3f5",
    "#f2859c": "#b7bdf8",
    "#f7edf0": "#cad3f5",
    "#f9eaf0": "#cad3f5",
    "#ff4d5e": "#ed8796",
    "#ff5364": "#8aadf4",
    "#ff566d": "#8aadf4",
    "#ff687e": "#8aadf4",
    "#ff7b8d": "#b7bdf8",
    "#ff8796": "#b7bdf8",
    "#ff8fa2": "#b7bdf8",
    "#ff91a4": "#b7bdf8",
    "#ff9bb0": "#c6a0f6",
    "#ffc7b7": "#f5bde6",
    "#ffe6ee": "#cad3f5",
    "#ffe7ec": "#cad3f5",
    "#ffe7ed": "#cad3f5",
}

pattern = re.compile(r"#[0-9a-fA-F]{6}\b")
directory = Path(sys.argv[1])

for path in directory.rglob("*.qml"):
    original = path.read_text()

    def qml_color(match):
        color = match.group().lower()
        if color not in colors:
            raise SystemExit(f"Unmapped DMS color {color} in {path}")
        return colors[color]

    updated = pattern.sub(qml_color, original)
    path.write_text(updated)

for path in directory.rglob("*.svg"):
    original = path.read_text()

    def cool_color(match):
        color = match.group()[1:]
        red, green, blue = (
            int(color[index : index + 2], 16) / 255 for index in (0, 2, 4)
        )
        _, saturation, value = colorsys.rgb_to_hsv(red, green, blue)
        cold = colorsys.hsv_to_rgb(
            0.625, max(0.16, saturation * 0.68), max(0.12, value)
        )
        return "#" + "".join(f"{round(channel * 255):02x}" for channel in cold)

    path.write_text(pattern.sub(cool_color, original))

manifest = directory / "plugin.json"
manifest_text = manifest.read_text()
manifest.write_text(manifest_text.replace("Infernal controls", "Catppuccin controls"))
