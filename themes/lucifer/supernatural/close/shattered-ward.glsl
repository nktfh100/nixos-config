#version 320 es
// @duration 0.50
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

float segment(vec2 p, vec2 a, vec2 b) {
    vec2 ab = b - a;
    return length(p - a - ab * clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0));
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

float ward(vec2 p) {
    float d = abs(length(p) - 78.0 / 240.0);
    d = min(d, segment(p, vec2(-0.150000, -0.179167), vec2(0.120833, -0.179167)));
    d = min(d, segment(p, vec2(-0.062500, -0.179167), vec2(-0.058333, 0.000000)));
    d = min(d, segment(p, vec2(-0.058333, 0.000000), vec2(0.120833, -0.137500)));
    d = min(d, segment(p, vec2(0.120833, -0.137500), vec2(0.112500, 0.158333)));
    d = min(d, segment(p, vec2(0.112500, 0.158333), vec2(-0.066667, 0.187500)));
    d = min(d, segment(p, vec2(-0.091667, -0.391667), vec2(0.000000, -0.500000)));
    d = min(d, segment(p, vec2(0.000000, -0.500000), vec2(0.095833, -0.391667)));
    d = min(d, segment(p, vec2(0.095833, -0.391667), vec2(-0.091667, -0.391667)));
    d = min(d, segment(p, vec2(-0.437500, 0.320833), vec2(-0.482161, 0.294971)));
    d = min(d, segment(p, vec2(-0.482161, 0.294971), vec2(-0.515885, 0.288932)));
    d = min(d, segment(p, vec2(-0.515885, 0.288932), vec2(-0.538281, 0.297542)));
    d = min(d, segment(p, vec2(-0.538281, 0.297542), vec2(-0.548958, 0.315625)));
    d = min(d, segment(p, vec2(-0.548958, 0.315625), vec2(-0.547526, 0.338005)));
    d = min(d, segment(p, vec2(-0.547526, 0.338005), vec2(-0.533594, 0.359505)));
    d = min(d, segment(p, vec2(-0.533594, 0.359505), vec2(-0.506771, 0.374951)));
    d = min(d, segment(p, vec2(-0.506771, 0.374951), vec2(-0.466667, 0.379167)));
    d = min(d, segment(p, vec2(-0.466667, 0.379167), vec2(-0.446305, 0.374471)));
    d = min(d, segment(p, vec2(-0.446305, 0.374471), vec2(-0.428776, 0.364258)));
    d = min(d, segment(p, vec2(-0.428776, 0.364258), vec2(-0.413786, 0.349650)));
    d = min(d, segment(p, vec2(-0.413786, 0.349650), vec2(-0.401042, 0.331771)));
    d = min(d, segment(p, vec2(-0.401042, 0.331771), vec2(-0.390251, 0.311743)));
    d = min(d, segment(p, vec2(-0.390251, 0.311743), vec2(-0.381120, 0.290690)));
    d = min(d, segment(p, vec2(-0.381120, 0.290690), vec2(-0.373356, 0.269735)));
    d = min(d, segment(p, vec2(-0.373356, 0.269735), vec2(-0.366667, 0.250000)));
    d = min(d, segment(p, vec2(-0.441667, 0.316667), vec2(-0.433105, 0.334440)));
    d = min(d, segment(p, vec2(-0.433105, 0.334440), vec2(-0.423177, 0.350260)));
    d = min(d, segment(p, vec2(-0.423177, 0.350260), vec2(-0.412077, 0.364128)));
    d = min(d, segment(p, vec2(-0.412077, 0.364128), vec2(-0.400000, 0.376042)));
    d = min(d, segment(p, vec2(-0.400000, 0.376042), vec2(-0.387142, 0.386003)));
    d = min(d, segment(p, vec2(-0.387142, 0.386003), vec2(-0.373698, 0.394010)));
    d = min(d, segment(p, vec2(-0.373698, 0.394010), vec2(-0.359863, 0.400065)));
    d = min(d, segment(p, vec2(-0.359863, 0.400065), vec2(-0.345833, 0.404167)));
    d = min(d, segment(p, vec2(0.308333, 0.229167), vec2(0.330599, 0.236816)));
    d = min(d, segment(p, vec2(0.330599, 0.236816), vec2(0.350521, 0.247396)));
    d = min(d, segment(p, vec2(0.350521, 0.247396), vec2(0.368099, 0.261100)));
    d = min(d, segment(p, vec2(0.368099, 0.261100), vec2(0.383333, 0.278125)));
    d = min(d, segment(p, vec2(0.383333, 0.278125), vec2(0.396224, 0.298665)));
    d = min(d, segment(p, vec2(0.396224, 0.298665), vec2(0.406771, 0.322917)));
    d = min(d, segment(p, vec2(0.406771, 0.322917), vec2(0.414974, 0.351074)));
    d = min(d, segment(p, vec2(0.414974, 0.351074), vec2(0.420833, 0.383333)));
    d = min(d, segment(p, vec2(0.420833, 0.383333), vec2(0.316667, 0.445833)));
    d = min(d, segment(p, vec2(0.316667, 0.445833), vec2(0.412500, 0.462500)));
    d = min(d, segment(p, vec2(0.412500, 0.462500), vec2(0.437500, 0.533333)));
    return d;
}
vec2 shardCenter(float id, float aspect) {
    vec2 cell = vec2(mod(id, 4.0), floor(id / 4.0));
    vec2 jitter = vec2(hash(vec2(id, 3.1)), hash(vec2(id, 8.7)));
    return ((cell + 0.18 + jitter * 0.64) / vec2(4, 3) - 0.5) * vec2(aspect, 1);
}
void main() {
    float elapsed = clamp(progress, 0.0, 1.0) * 0.50;
    float t = clamp((elapsed - 0.16) / 0.34, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1);
    float flight = pow(smoothstep(0.22, 0.98, t), 1.7);
    float gap = smoothstep(0.19, 0.38, t) * 0.01;
    vec2 q = p;
    float mask = 1.0;
    float seam = 10.0;
    float identity = 0.0;
    if (elapsed >= 0.20) {
        mask = 0.0;
        for (int i = 0; i < 12; i++) {
            float id = float(i);
            vec2 center = shardCenter(id, aspect);
            vec2 direction = normalize(center + vec2(0.001));
            float turn = (hash(vec2(id, 6.3)) - 0.5) * flight * 1.0;
            vec2 moved = p - center - direction * flight * (0.42 + hash(vec2(id, 4.2)) * 0.5) - vec2(0, flight * flight * 0.22);
            vec2 local = mat2(cos(turn), -sin(turn), sin(turn), cos(turn)) * moved + center;
            if (any(greaterThan(abs(local - center), vec2(aspect * 0.34, 0.48)))) continue;
            float edge = 10.0;
            for (int j = 0; j < 12; j++) {
                if (j == i) continue;
                vec2 other = shardCenter(float(j), aspect);
                vec2 ab = other - center;
                edge = min(edge, dot((other + center) * 0.5 - local, normalize(ab)));
            }
            if (edge >= 0.0) {
                q = local;
                mask = smoothstep(gap, gap + 0.002, edge);
                seam = edge;
                identity = id;
            }
        }
    }
    float dissolve = 1.0 - smoothstep(0.61 + identity * 0.01, 0.98, t);
    vec4 src = sourceAt(q / vec2(aspect, 1) + 0.5) * mask;
    float draw = smoothstep(0.0, 0.075, elapsed);
    float d = ward(q / (min(aspect, 1.0) * 0.88));
    float line = exp(-d * 360.0) * draw * mask;
    float glow = exp(-d * 60.0) * draw * mask;
    src.rgb *= 1.0 - draw * 0.26;
    src = over(src, vec3(0.80, 0.25, 0.09), glow * 0.42);
    src = over(src, vec3(1.0, 0.79, 0.45), line * 0.97);
    float cracks = exp(-seam * 250.0) * smoothstep(0.13, 0.21, t) * (1.0 - smoothstep(0.26, 0.53, t));
    src = over(src, vec3(1.0, 0.89, 0.68), cracks * src.a * 0.85);
    float rim = exp(-abs(seam - gap) * 360.0) * smoothstep(0.22, 0.4, t) * src.a;
    src = over(src, vec3(0.73, 0.48, 0.24), rim * 0.45);
    fragColor = src * dissolve * (1.0 - step(0.9999, t));
}
