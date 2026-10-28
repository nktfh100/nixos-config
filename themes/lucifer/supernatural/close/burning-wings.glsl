#version 320 es
// @duration 1.05
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float progress;
uniform float seed;
uniform vec4 window_rect;
uniform vec2 surface_size;
const float PI = 3.14159265359;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + 1.0), f.x), f.y);
}
float fbm(vec2 p) {
    float n = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) { n += a * noise(p); p = mat2(1.6, 1.2, -1.2, 1.6) * p + 2.3; a *= 0.5; }
    return n;
}
float segment(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b - a;
    return length(p - a - ab * clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0));
}
vec4 over(vec4 base, vec3 color, float alpha) {
    alpha = clamp(alpha, 0.0, 1.0);
    return vec4(color * alpha, alpha) + base * (1.0 - alpha);
}

float feather(vec2 p, vec2 a, vec2 b, float width) {
    vec2 axis = b - a;
    float u = clamp(dot(p - a, axis) / dot(axis, axis), 0.0, 1.0);
    float profile = pow(sin(PI * u), 0.7) * width;
    return length(p - a - axis * u) - profile;
}
float wings(vec2 p) {
    p.x = abs(p.x);
    float d = 10.0;
    for (int i = 0; i < 15; i++) {
        float s = float(i) / 14.0;
        vec2 a = vec2(0.06 + 0.65 * s, 0.10 - 0.53 * s);
        vec2 b = vec2(0.17 + 0.99 * s, 0.55 - 1.05 * s + 0.08 * sin(s * PI));
        d = min(d, feather(p, a, b, mix(0.045, 0.031, s)));
    }
    d = min(d, segment(p, vec2(0.06, 0.12), vec2(0.34, -0.23)) - 0.057);
    d = min(d, segment(p, vec2(0.34, -0.23), vec2(0.71, -0.43)) - 0.034);
    return d;
}
void main() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1);
    float size = min(aspect / 1.85, 1.15);
    vec2 q = p / size;
    q.y += 0.035;
    float ash = fbm(q * 25.0 + seed * 30.0);
    float d = wings(q) + (ash - 0.5) * 0.010;
    float release = smoothstep(0.08, 0.34, t);
    vec4 src = texture(tex, v_texcoord);
    float flash = smoothstep(0.02, 0.13, t) * (1.0 - smoothstep(0.13, 0.28, t));
    src.rgb = mix(src.rgb, vec3(0.83, 0.90, 1.0) * src.a, flash * 0.68);
    src *= 1.0 - release;
    float silhouette = 1.0 - smoothstep(-0.001, 0.004, d);
    float trace = exp(-abs(d) * 180.0);
    float spread = smoothstep(abs(q.x) * 0.16 + 0.06, abs(q.x) * 0.16 + 0.2, t);
    float erosion = smoothstep(t * 2.3 - 1.3, t * 2.3 - 1.12, ash);
    float fade = 1.0 - smoothstep(0.67, 1.0, t);
    src = over(src, vec3(0.025, 0.018, 0.026), silhouette * release * erosion * fade * 0.94);
    float hot = (1.0 - smoothstep(0.30, 0.66, t)) * spread * release;
    src = over(src, vec3(0.63, 0.20, 0.045), exp(-abs(d) * 48.0) * hot * 0.45);
    src = over(src, mix(vec3(0.94, 0.30, 0.07), vec3(1.0, 0.77, 0.35), ash), trace * hot * 0.95);
    float ember = silhouette * smoothstep(0.61, 0.75, ash) * release * fade;
    src = over(src, vec3(0.91, 0.24, 0.035), ember * 0.65);
    fragColor = src * (1.0 - step(0.9999, t));
}
