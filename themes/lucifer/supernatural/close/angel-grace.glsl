#version 320 es
// @duration 0.85
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

vec4 over(vec4 base, vec3 color, float alpha) {
    alpha = clamp(alpha, 0.0, 1.0);
    return vec4(color * alpha, alpha) + base * (1.0 - alpha);
}
vec4 sourceAt(vec2 uv) {
    vec2 at = window_rect.xy + uv * window_rect.zw;
    if (any(lessThan(at, vec2(0))) || any(greaterThan(at, vec2(1)))) return vec4(0);
    return texture(tex, at);
}

float fracture(vec2 p) {
    vec2 cell = floor(p), f = fract(p);
    float first = 10.0, second = 10.0;
    for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
        vec2 id = cell + vec2(x, y);
        vec2 center = vec2(x, y) + 0.18 + 0.64 * vec2(hash(id), hash(id + 17.4)) - f;
        float d = dot(center, center);
        if (d < first) { second = first; first = d; } else { second = min(second, d); }
    }
    return (sqrt(second) - sqrt(first)) * 0.5;
}
void main() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1);
    float collapse = smoothstep(0.35, 0.87, t);
    float scale = max(0.018, 1.0 - collapse);
    vec2 origin = p / scale;
    vec2 sampleUV = origin / vec2(aspect, 1) + 0.5;
    vec4 src = sourceAt(sampleUV);
    vec2 distortion = vec2(noise(origin * 19.0), noise(origin * 21.0 + 8.0)) - 0.5;
    float cracks = fracture(origin * 4.4 + distortion * 0.14 + seed * 7.0);
    float ignite = smoothstep(0.015, 0.17, t);
    float spread = 1.0 - smoothstep(t * 3.2 - 0.1, t * 3.2 + 0.24, length(origin));
    float line = exp(-cracks * 140.0) * spread * ignite;
    float bloom = exp(-cracks * 22.0) * spread * ignite;
    float whiten = smoothstep(0.22, 0.72, t) * 0.86;
    src.rgb = mix(src.rgb, vec3(0.56, 0.83, 1.0) * src.a, whiten);
    src = over(src, vec3(0.19, 0.55, 1.0), bloom * 0.70 * src.a);
    src = over(src, vec3(0.90, 0.98, 1.0), line * 0.95 * src.a);
    src *= 1.0 - smoothstep(0.50, 0.83, t);
    float light = exp(-length(p) * mix(8.0, 42.0, collapse)) * smoothstep(0.25, 0.65, t) * (1.0 - smoothstep(0.73, 1.0, t));
    src = over(src, vec3(0.20, 0.60, 1.0), light * 0.65);
    float ribbon = exp(-abs(p.y - sin(p.x * 12.0 + t * 6.0) * 0.035) * 125.0 - abs(p.x) * 6.0);
    float tail = smoothstep(0.42, 0.68, t) * (1.0 - smoothstep(0.76, 1.0, t));
    src = over(src, vec3(0.60, 0.86, 1.0), ribbon * tail * 0.6);
    float spark = exp(-length(p * vec2(1, 1.8)) * 105.0);
    float flare = exp(-abs(p.y) * 240.0 - abs(p.x) * 11.0) * 0.40 + spark;
    src = over(src, vec3(0.88, 0.97, 1.0), flare * smoothstep(0.58, 0.8, t) * (1.0 - smoothstep(0.82, 1.0, t)));
    fragColor = src * (1.0 - step(0.9999, t));
}
