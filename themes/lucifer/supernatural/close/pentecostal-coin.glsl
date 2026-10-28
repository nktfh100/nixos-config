#version 320 es
// @duration 0.72
precision highp float;
precision highp int;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float progress;
uniform float seed;
uniform vec4 window_rect;
uniform vec2 surface_size;
const float PI = 3.14159265359;
const uint LETTERS[324] = uint[324](
    0u, 0u, 29360320u, 27263456u, 53478304u, 102237968u, 267912712u, 201591820u, 403053572u, 32271u, 0u, 0u,
    0u, 0u, 236455934u, 471342104u, 236461080u, 236455928u, 404232216u, 404240408u, 471341080u, 2046u, 0u, 0u,
    0u, 0u, 1009782752u, 806107160u, 925708u, 393230u, 917518u, 806092812u, 472913944u, 2016u, 0u, 0u,
    0u, 0u, 118227455u, 403442700u, 940316684u, 806107148u, 940324876u, 403445772u, 118230028u, 511u, 0u, 0u,
    0u, 0u, 404234238u, 1576984u, 68682776u, 102238200u, 1573912u, 270008344u, 270012440u, 8190u, 0u, 0u,
    0u, 0u, 540033020u, 3153968u, 137365552u, 137367536u, 3147824u, 3145776u, 3145776u, 252u, 0u, 0u,
    0u, 0u, 1009782752u, 806105112u, 925708u, 393230u, 1879981070u, 1879863308u, 946892824u, 4064u, 0u, 0u,
    0u, 0u, 940342335u, 940324876u, 940324876u, 940326908u, 940324876u, 940324876u, 940324876u, 31807u, 0u, 0u,
    0u, 0u, 25167840u, 25166208u, 25166208u, 25166208u, 25166208u, 25166208u, 25166208u, 2016u, 0u, 0u,
    0u, 0u, 12583920u, 12583104u, 12583104u, 12583104u, 12583104u, 12583104u, 12583104u, 12583104u, 15073478u, 124u,
    0u, 0u, 404257918u, 51905560u, 14156184u, 7864440u, 30933240u, 119014296u, 471338520u, 30846u, 0u, 0u,
    0u, 0u, 3145980u, 3145776u, 3145776u, 3145776u, 3145776u, 540016688u, 808464432u, 16380u, 0u, 0u,
    0u, 0u, 1879568391u, 2014279695u, 1947827229u, 1915844121u, 1903260465u, 1893822945u, 1879142593u, 63495u, 0u, 0u,
    0u, 0u, 807205903u, 808726588u, 820260980u, 830747076u, 923022212u, 1006910980u, 939801604u, 12319u, 0u, 0u,
    0u, 0u, 236454896u, 403053580u, 805777414u, 805515271u, 805777415u, 403058694u, 236460044u, 1008u, 0u, 0u,
    0u, 0u, 472911868u, 942684208u, 942684208u, 267394096u, 3145776u, 3145776u, 3145776u, 252u, 0u, 0u,
    0u, 0u, 236454896u, 403053580u, 805777414u, 805515271u, 805777415u, 403058694u, 236460044u, 50332656u, 201330432u, 0u,
    0u, 0u, 236455934u, 404233240u, 471341080u, 66587672u, 236455704u, 471338008u, 941103128u, 61566u, 0u, 0u,
    0u, 0u, 473434080u, 404232216u, 3670040u, 132121072u, 469769984u, 403183616u, 205002776u, 2032u, 0u, 0u,
    0u, 0u, 566640638u, 562176390u, 25166208u, 25166208u, 25166208u, 25166208u, 25166208u, 2016u, 0u, 0u,
    0u, 0u, 269253695u, 269225996u, 269225996u, 269225996u, 269225996u, 403443724u, 242751516u, 2032u, 0u, 0u,
    0u, 0u, 269384735u, 404494348u, 202901532u, 70255672u, 40896048u, 56623968u, 29360608u, 192u, 0u, 0u,
    0u, 0u, 2176967047u, 3284255169u, 1130578755u, 656630563u, 641082919u, 471744022u, 470555676u, 3084u, 0u, 0u,
    0u, 0u, 203177535u, 37225496u, 32506736u, 29360352u, 60817888u, 119014160u, 202116616u, 16159u, 0u, 0u,
    0u, 0u, 404503614u, 204998680u, 39847024u, 29361120u, 25166272u, 25166208u, 29360512u, 2016u, 0u, 0u,
    0u, 0u, 470564860u, 234888204u, 117442048u, 25166720u, 14680256u, 3145840u, 538714168u, 16380u, 0u, 0u,
    0u, 0u, 25166208u, 25166208u, 8388992u, 0u, 0u, 0u, 0u, 0u, 0u, 0u
);
const int INSCRIPTIONS[91] = int[91](8, 13, 27, 6, 14, 3, 22, 4, 26, 17, 4, 27, 3, 0, 12, 13, 4, 3, 22, 4, 27, 19, 17, 20, 18, 19, 12, 14, 17, 13, 8, 13, 6, 27, 18, 19, 0, 17, 1, 4, 4, 11, 25, 4, 1, 20, 1, 18, 4, 17, 15, 4, 13, 19, 3, 17, 0, 6, 14, 13, 11, 20, 2, 8, 5, 4, 17, 18, 0, 19, 0, 13, 5, 0, 19, 7, 4, 17, 18, 14, 13, 7, 14, 11, 24, 27, 6, 7, 14, 18, 19);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float segment(vec2 p, vec2 a, vec2 b) {
    vec2 axis = b - a;
    return length(p - a - axis * clamp(dot(p - a, axis) / dot(axis, axis), 0.0, 1.0));
}
float stroke(float distance, float width) {
    return 1.0 - smoothstep(width, width + 0.009, distance);
}
float letterPixel(ivec2 pixel, int letter) {
    if (letter > 26 || any(lessThan(pixel, ivec2(0))) || any(greaterThanEqual(pixel, ivec2(16, 24)))) return 0.0;
    int bit = pixel.y * 16 + pixel.x;
    return float((LETTERS[letter * 12 + bit / 32] >> uint(bit % 32)) & 1u);
}
float glyph(vec2 p, int letter) {
    vec2 grid = p * vec2(16, 24) - 0.5;
    ivec2 cell = ivec2(floor(grid));
    vec2 f = fract(grid);
    return mix(mix(letterPixel(cell, letter), letterPixel(cell + ivec2(1, 0), letter), f.x), mix(letterPixel(cell + ivec2(0, 1), letter), letterPixel(cell + ivec2(1, 1), letter), f.x), f.y);
}
float textLine(vec2 p, vec2 center, float height, int offset, int count) {
    vec2 local = (p - center) / vec2(height * 0.58, height) + vec2(float(count) * 0.5, 0.5);
    if (local.y < 0.0 || local.y > 1.0 || local.x < 0.0 || local.x >= float(count)) return 0.0;
    int index = int(floor(local.x));
    return glyph(vec2(fract(local.x), local.y), INSCRIPTIONS[offset + index]);
}
float inscription(vec2 p, bool damned) {
    float ink = textLine(p, vec2(0, -0.79), 0.14, 0, 6);
    ink = max(ink, damned ? textLine(p, vec2(0, -0.65), 0.115, 6, 12) : textLine(p, vec2(0, -0.65), 0.115, 18, 8));
    vec2 bottom = vec2(atan(p.x, p.y) * 0.87, length(p) - 0.86);
    ink = max(ink, textLine(bottom, vec2(0), 0.13, 26, 12));
    if (damned) {
        ink = max(ink, textLine(p, vec2(0, -0.48), 0.076, 38, 9));
        ink = max(ink, textLine(p, vec2(-0.58, 0.03), 0.086, 47, 7));
        ink = max(ink, textLine(p, vec2(0.59, 0.03), 0.086, 54, 6));
        ink = max(ink, textLine(p, vec2(-0.40, 0.55), 0.082, 60, 7));
        ink = max(ink, textLine(p, vec2(0.40, 0.55), 0.082, 67, 5));
    } else {
        ink = max(ink, textLine(p, vec2(0, -0.49), 0.09, 72, 6));
        ink = max(ink, textLine(p, vec2(-0.47, 0.29), 0.09, 78, 3));
        ink = max(ink, textLine(p, vec2(0.41, 0.29), 0.075, 81, 10));
    }
    return ink;
}
float goat(vec2 p) {
    vec2 q = vec2(abs(p.x), p.y);
    float face = (1.0 - smoothstep(0.13, 0.15, q.x + max(q.y - 0.03, 0.0) * 0.27)) * smoothstep(-0.23, -0.18, q.y) * (1.0 - smoothstep(0.33, 0.37, q.y));
    face *= 0.48 + 0.24 * exp(-q.x * 19.0) + 0.2 * exp(-length((q - vec2(0.09, 0.02)) * vec2(15, 6)));
    float horns = 0.0;
    for (int i = 0; i < 9; i++) {
        float a = float(i) / 9.0, b = float(i + 1) / 9.0;
        vec2 first = mix(mix(vec2(0.105, -0.15), vec2(0.16, -0.32), a), mix(vec2(0.16, -0.32), vec2(0.33, -0.43), a), a);
        vec2 last = mix(mix(vec2(0.105, -0.15), vec2(0.16, -0.32), b), mix(vec2(0.16, -0.32), vec2(0.33, -0.43), b), b);
        horns = max(horns, stroke(segment(q, first, last), mix(0.036, 0.005, a)) * (0.52 + 0.18 * sin(a * 65.0)));
    }
    vec2 ear = q - vec2(0.255, -0.015);
    ear.y += ear.x * 0.30;
    float ears = (1.0 - smoothstep(0.85, 1.0, length(ear / vec2(0.14, 0.041)))) * 0.57;
    float eyes = exp(-length((q - vec2(0.083, 0.035)) * vec2(43, 80)));
    float nostril = exp(-length((q - vec2(0.035, 0.265)) * vec2(90, 55)));
    float beard = stroke(segment(q, vec2(0.035, 0.30), vec2(0, 0.43)), 0.008) * 0.45;
    return max(max(face, ears), max(horns, beard)) * (1.0 - eyes * 0.92 - nostril * 0.75);
}
float crucifix(vec2 p) {
    float cross = max(stroke(segment(p, vec2(0, -0.38), vec2(0, 0.43)), 0.034), stroke(segment(p, vec2(-0.25, -0.18), vec2(0.25, -0.18)), 0.033)) * 0.28;
    float body = stroke(segment(p, vec2(0, -0.10), vec2(0.015, 0.15)), 0.047);
    body = max(body, stroke(length((p - vec2(0.015, -0.22)) * vec2(1, 0.8)), 0.044));
    body = max(body, stroke(segment(p, vec2(0, -0.10), vec2(-0.24, -0.18)), 0.019));
    body = max(body, stroke(segment(p, vec2(0, -0.10), vec2(0.24, -0.18)), 0.019));
    body = max(body, stroke(segment(p, vec2(-0.025, 0.16), vec2(0.018, 0.37)), 0.022));
    body = max(body, stroke(segment(p, vec2(0.04, 0.16), vec2(0.018, 0.37)), 0.020));
    return max(cross, body * 0.77);
}
float relief(vec2 p, bool damned) {
    float radius = length(p);
    float rim = exp(-pow((radius - 0.955) * 70.0, 2.0)) * 0.58;
    float emblem = 10.0;
    if (damned) {
        for (int i = 0; i < 10; i++) {
            float a = PI * 0.5 + float(i) * PI * 0.2;
            float b = a + PI * 0.2;
            float ra = mod(float(i), 2.0) < 1.0 ? 0.81 : 0.34;
            float rb = mod(float(i), 2.0) < 1.0 ? 0.34 : 0.81;
            emblem = min(emblem, segment(p, vec2(cos(a), sin(a)) * ra, vec2(cos(b), sin(b)) * rb));
        }
    } else {
        emblem = min(segment(p, vec2(0, -0.43), vec2(-0.57, 0.51)), min(segment(p, vec2(-0.57, 0.51), vec2(0.57, 0.51)), segment(p, vec2(0.57, 0.51), vec2(0, -0.43))));
    }
    float figure = damned ? goat(p) : crucifix(p);
    return max(rim, max(stroke(emblem, 0.012) * 0.49, max(figure, inscription(p, damned) * 0.55)));
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
    vec2 p = (uv - 0.5) * vec2(aspect, 1);
    float fold = smoothstep(0.0, 0.32, t);
    float floatUp = sin(smoothstep(0.25, 1.0, t) * PI) * 0.045;
    p.y += floatUp;
    float rotation = smoothstep(0.39, 0.91, t) * PI * 1.5;
    float facing = cos(rotation);
    float faceWidth = max(abs(facing), 0.015);
    float thickness = abs(sin(rotation)) * 0.075;
    float tilt = sin(rotation * 0.75) * 0.14;
    p = mat2(cos(tilt), -sin(tilt), sin(tilt), cos(tilt)) * p;
    vec2 extent = mix(vec2(aspect, 1.0) * 0.5, vec2(0.145), fold);
    vec2 q = p / (extent * vec2(faceWidth, 1));
    float curl = (1.0 - fold) * fold * (q.y * 0.65 + 0.3);
    q = mat2(cos(curl), -sin(curl), sin(curl), cos(curl)) * q;
    float shape = mix(max(abs(q.x), abs(q.y)), length(q), fold);
    if (shape > 1.1 && length(p / (extent * vec2(faceWidth + thickness, 1))) > 1.1) { fragColor = vec4(0); return; }
    float aa = max(fwidth(shape), 0.003);
    float mask = 1.0 - smoothstep(1.0 - aa, 1.0 + aa, shape);
    vec2 faceUV = q;
    float height = relief(faceUV, facing >= 0.0);
    float dx = dFdx(height) / max(length(dFdx(faceUV)), 0.005);
    float dy = dFdy(height) / max(length(dFdy(faceUV)), 0.005);
    vec3 normal = normalize(vec3(-dx * 0.075, -dy * 0.075, 1));
    vec3 light = normalize(vec3(-0.55, -0.65, 0.8));
    float diffuse = max(dot(normal, light), 0.0);
    float specular = pow(max(dot(reflect(-light, normal), vec3(0, 0, 1)), 0.0), 18.0);
    float grain = hash(floor(faceUV * 290.0));
    float tarnish = 0.018 + grain * 0.035;
    vec3 metal = mix(vec3(0.12, 0.115, 0.105), vec3(0.49, 0.475, 0.435), smoothstep(0.04, 0.62, height));
    metal *= 0.42 + diffuse * 0.82;
    metal += vec3(0.86, 0.83, 0.74) * specular * (0.18 + height * 0.45) + tarnish;
    float reflection = exp(-pow((faceUV.x * 0.6 + faceUV.y * 0.2 - sin(rotation) * 0.95) * 3.0, 2.0));
    metal += vec3(0.19, 0.17, 0.125) * reflection;
    vec2 sourceUV = clamp(q * 0.5 + 0.5, 0.0, 1.0);
    vec4 source = texture(tex, window_rect.xy + sourceUV * window_rect.zw) * mask;
    float mint = smoothstep(0.13, 0.32, t);
    vec4 coin = mix(source, vec4(metal * mask, mask), mint);
    float edgeRadius = length(p / (extent * vec2(faceWidth + thickness, 1)));
    float edgeAA = max(fwidth(edgeRadius), 0.003);
    float edgeMask = (1.0 - smoothstep(1.0 - edgeAA, 1.0 + edgeAA, edgeRadius)) * mint;
    float edgeLight = 0.22 + 0.27 * exp(-pow(q.y * 1.5 + 0.3, 2.0));
    float edgeGrooves = 0.85 + 0.15 * sin(p.y / extent.y * 145.0);
    vec4 rim = vec4(vec3(0.72, 0.68, 0.57) * edgeLight * edgeGrooves * edgeMask, edgeMask);
    coin = coin + rim * (1.0 - coin.a);
    coin *= 1.0 - smoothstep(0.90, 0.97, t);
    float glint = exp(-abs(p.x) * 450.0 - abs(p.y) * 35.0) + exp(-abs(p.y) * 650.0 - abs(p.x) * 80.0);
    float lastLight = smoothstep(0.90, 0.95, t) * (1.0 - smoothstep(0.95, 1.0, t));
    fragColor = over(coin, vec3(0.92, 0.85, 0.67), glint * lastLight * 0.6);
}
