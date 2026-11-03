hl.env("XCURSOR_THEME", "catppuccin-macchiato-red-cursors")
hl.env("HYPRCURSOR_THEME", "catppuccin-macchiato-red-cursors")

hl.config({
    general = {
        gaps_in = 7,
        gaps_out = 18,
        border_size = 3,
        col = {
            active_border = {
                colors = { "rgba(f32746ff)", "rgba(580f28ff)", "rgba(ff9aa4ff)", "rgba(a01632ff)" },
                angle = 45,
            },
            inactive_border = "rgba(48212ddd)",
        },
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 34,
            render_power = 3,
            color = "rgba(950c2845)",
        },
        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            vibrancy = 0.08,
        },
    },
})

for _, class in ipairs({ "kitty", "firefox" }) do
    hl.window_rule({
        match = { class = "^(" .. class .. ")$" },
        opacity = "1.0 override 1.0 override 1.0 override",
    })
end

hl.layer_rule({
    match = { namespace = "^dms:.*" },
    blur = true,
    ignore_alpha = 0.2,
})
