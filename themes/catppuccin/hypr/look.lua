local sapphire = "rgb(7dc4e4)"
local lavender = "rgb(b7bdf8)"

hl.env("XCURSOR_THEME", "catppuccin-macchiato-blue-cursors")
hl.env("HYPRCURSOR_THEME", "catppuccin-macchiato-blue-cursors")

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = { colors = { sapphire, lavender }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})

hl.layer_rule({
    match = { namespace = "^dms:.*" },
    blur = true,
    ignore_alpha = 0.2,
})
