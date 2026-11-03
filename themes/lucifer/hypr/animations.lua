hl.config({ animations = { enabled = true } })

hl.curve("descend", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("vanish", { type = "bezier", points = { { 0.7, 0 }, { 0.84, 0 } } })
hl.curve("glide", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "descend", style = "popin 78%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "vanish", style = "popin 100%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "descend" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 90, bezier = "linear", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "glide", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "descend", style = "slidefadevert 15%" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "descend", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "vanish", style = "fade" })

hl.layer_rule({
    match = { namespace = "^(selection|hyprpicker)$" },
    no_anim = true,
})
