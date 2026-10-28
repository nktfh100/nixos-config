#version 320 es
// @duration 0.45
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float progress;
uniform float seed;
uniform vec4 window_rect;
uniform vec2 surface_size;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + 1.0), f.x), f.y);
}
vec4 over(vec4 base, vec3 color, float alpha) {
    alpha = clamp(alpha, 0.0, 1.0);
    return vec4(color * alpha, alpha) + base * (1.0 - alpha);
}

void main() {
    float t = clamp(progress, 0.0, 1.0);
    if (t <= 0.0) { fragColor = texture(tex, v_texcoord); return; }
    if (t >= 1.0) { fragColor = vec4(0); return; }
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = uv * vec2(aspect, 1);
    float front = mix(-0.11, 1.18, smoothstep(0.06, 0.85, t));
    float curl = noise(vec2(p.x * 13.0 + seed, p.y * 7.0 + t * 5.0));
    float detail = noise(p * 42.0 + vec2(0, t * 10.0));
    float field = 1.0 - uv.y - front + (curl - 0.5) * 0.11 + (detail - 0.5) * 0.025;
    float inside = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
    vec4 src = texture(tex, v_texcoord);
    float charred = 1.0 - smoothstep(0.008, 0.07, field);
    src.rgb *= 1.0 - charred * 0.88;
    src *= smoothstep(-0.002, 0.012, field);
    float heat = smoothstep(0.08, 0.20, t) * (1.0 - smoothstep(0.76, 0.88, t)) * inside;
    float flame = exp(-abs(field + 0.018) * 36.0) * (0.6 + detail * 0.4);
    src = over(src, vec3(0.80, 0.12, 0.015), flame * heat * 0.85);
    src = over(src, vec3(1.0, 0.52, 0.11), exp(-abs(field) * 120.0) * heat);
    src = over(src, vec3(1.0, 0.90, 0.57), exp(-abs(field) * 340.0) * heat * 0.9);
    vec2 saltGrid = vec2(p.x * 240.0, (uv.y - 0.976) * 400.0);
    vec2 saltCell = floor(saltGrid);
    float grain = length(fract(saltGrid) - vec2(0.25 + hash(saltCell) * 0.5, 0.5));
    float salt = (1.0 - smoothstep(0.13, 0.34, grain)) * exp(-abs(uv.y - 0.976) * 220.0) * inside;
    float saltLife = smoothstep(0.0, 0.07, t) * (1.0 - smoothstep(0.19, 0.36, t));
    src = over(src, vec3(0.94, 0.91, 0.80), salt * saltLife);
    for (int i = 0; i < 48; i++) {
        float id = float(i);
        float birth = 0.12 + hash(vec2(id, seed + 2.0)) * 0.60;
        float life = (t - birth) / 0.27;
        float birthFront = mix(-0.11, 1.18, smoothstep(0.06, 0.85, birth));
        vec2 origin = vec2(hash(vec2(id, 4.7)) * aspect, 1.0 - birthFront);
        vec2 drift = vec2(sin(id * 4.3) * 0.10 * life, -0.16 * life);
        vec2 delta = p - origin - drift;
        float fleck = exp(-length(delta * vec2(1.0, 1.6)) * (450.0 + hash(vec2(id, 8.1)) * 250.0));
        float fade = smoothstep(0.0, 0.10, life) * (1.0 - smoothstep(0.18, 1.0, life));
        vec3 ash = mix(vec3(0.64, 0.61, 0.56), vec3(1.0, 0.49, 0.11), 1.0 - smoothstep(0.0, 0.25, life));
        src = over(src, ash, fleck * fade * 0.85);
    }
    fragColor = src * (1.0 - smoothstep(0.94, 1.0, t));
}
