#version 320 es
// @duration 0.32
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
float fbm(vec2 p) { return noise(p) * 0.57 + noise(p * 2.03 + 7.0) * 0.28 + noise(p * 4.11 + 17.0) * 0.15; }
vec4 over(vec4 base, vec3 color, float alpha) {
    alpha = clamp(alpha, 0.0, 1.0);
    return vec4(color * alpha, alpha) + base * (1.0 - alpha);
}
vec4 sourceAt(vec2 uv) {
    if (any(lessThan(uv, vec2(0))) || any(greaterThan(uv, vec2(1)))) return vec4(0);
    return texture(tex, window_rect.xy + uv * window_rect.zw);
}
float segment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}
float wings(vec2 p, float unfold) {
    p.x = abs(p.x);
    p.x /= mix(0.18, 1.0, unfold);
    float shape = 0.0;
    for (int i = 0; i < 11; i++) {
        float f = float(i) / 10.0;
        vec2 a = vec2(0.04 + f * 0.49, 0.12 - sin(f * 2.5) * 0.25);
        vec2 b = a + vec2(0.10 + f * 0.16, 0.25 - f * 0.40);
        vec2 d = b - a, q = p - (a + b) * 0.5;
        vec2 local = vec2(dot(q, normalize(vec2(-d.y, d.x))), dot(q, normalize(d)));
        float feather = length(local / vec2(mix(0.033, 0.016, f), length(d) * 0.65));
        shape = max(shape, 1.0 - smoothstep(0.8, 1.06, feather));
    }
    return shape;
}
void main() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    if (any(lessThan(textureSize(tex, 0), ivec2(2)))) {
        fragColor = vec4(0);
        return;
    }
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1.0);
    vec4 original = texture(tex, v_texcoord);
    float envelope = smoothstep(0.0, 0.10, t) * (1.0 - smoothstep(0.65, 1.0, t));
    vec4 result = vec4(0);
    float appear = smoothstep(0.04, 0.85, t);
    float scale = mix(0.92, 1.0, appear);
    vec2 q = (uv - 0.5) / scale + 0.5;
    vec4 src = sourceAt(q);
    result = mix(vec4(vec3(0.50, 0.018, 0.065) * src.a, src.a), src, smoothstep(0.12, 0.87, t));
    result *= smoothstep(0.0, 0.20, t);
    float edge = min(min(q.x, 1.0 - q.x), min(q.y, 1.0 - q.y));
    result = over(result, vec3(1.0, 0.09, 0.19), exp(-max(edge, 0.0) * 100.0) * src.a * envelope * 0.70);
    fragColor = mix(result, original, smoothstep(0.90, 1.0, t));
}
