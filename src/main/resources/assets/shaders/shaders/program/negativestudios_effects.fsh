#version 150
uniform sampler2D DiffuseSampler;
out vec4 fragColor;
uniform vec2 InSize;
uniform float Mode;
uniform float Progress;
uniform float Time;
in vec2 texCoord;
in vec2 oneTexel;

vec3 sampleColor(vec2 uv){
    return texture(DiffuseSampler, clamp(uv, 0.0, 1.0)).rgb;
}

float hash21(vec2 p){
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main(){
    vec2 uv = texCoord;
    vec3 original = sampleColor(uv);
    int m = int(Mode + 0.5);

    if(m == 10){
        float t = clamp(Progress, 0.0, 1.0);
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;
        float r = length(p);
        float edge = smoothstep(0.02, 0.95, r);

        float twist = t * 9.0 * (1.0 - smoothstep(0.03, 1.15, r));
        twist += t * 2.5 * smoothstep(0.30, 1.15, r);
        float cs = cos(twist);
        float sn = sin(twist);
        vec2 rotated = vec2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);

        float pull = t * 0.48 * smoothstep(0.05, 1.0, r);
        float sourceRadius = r * (1.0 + pull);
        sourceRadius += t * 0.14 * sin(r * 14.0 - t * 12.0) * edge;

        vec2 source = rotated;
        float rotatedRadius = length(source);
        source *= sourceRadius / max(rotatedRadius, 0.0001);
        source.x /= aspect;
        vec3 color = sampleColor(center + source);

        float coreRadius = 0.32 * t;
        float coreSoftness = 0.045 + 0.025 * t;
        float coreMask = 1.0 - smoothstep(coreRadius, coreRadius + coreSoftness, r);
        float coreStrength = smoothstep(0.0, 0.18, t);
        color *= 1.0 - coreMask * coreStrength;

        float vignette = smoothstep(0.28, 1.05, r);
        color *= 1.0 - t * 0.78 * vignette;

        float fade = smoothstep(0.82, 1.0, t);
        fade *= fade;
        color = mix(color, vec3(0.0), fade);

        fragColor = vec4(color, 1.0);
        return;
    }

    if(m == 11 || m == 12){
        float edgeDistance = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
        float edgeWidth = 0.24;
        float edgeGlow = 1.0 - smoothstep(0.0, edgeWidth, edgeDistance);
        edgeGlow = pow(clamp(edgeGlow, 0.0, 1.0), 1.35);

        float cornerX = abs(uv.x - 0.5) * 2.0;
        float cornerY = abs(uv.y - 0.5) * 2.0;
        float cornerBoost = mix(1.0, 1.18, pow(cornerX * cornerY, 1.5));
        edgeGlow *= cornerBoost;

        vec3 glowColor = (m == 11)
            ? vec3(0.03, 1.0, 0.08)
            : vec3(1.0, 0.025, 0.025);

        vec3 color = original + glowColor * pow(edgeGlow, 1.8) * 0.82;
        float border = 1.0 - smoothstep(0.0, 0.055, edgeDistance);
        color += glowColor * border * 0.28;

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    if(m == 13){
        vec3 redTint = vec3(1.0, 0.0, 0.0);
        fragColor = vec4(mix(original, redTint, 0.10), 1.0);
        return;
    }

    if(m == 14){
        // Rugido: ondas de distorsion que nacen en el centro y se expanden.
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;
        float radius = length(p);

        float waveTime = fract(Time * 0.55);
        float waveRadius = waveTime * 1.25;
        float distanceToWave = abs(radius - waveRadius);
        float wave = exp(-distanceToWave * 55.0) * (1.0 - waveTime * 0.35);

        float direction = sin(radius * 30.0 - Time * 10.0);
        float displacement = direction * wave * 0.045;

        vec2 distorted = p;
        distorted *= 1.0 + displacement;
        distorted.x /= aspect;

        // Una segunda onda mas suave evita que parezca un simple anillo.
        float wave2Radius = fract(Time * 0.55 + 0.34) * 1.25;
        float wave2 = exp(-abs(radius - wave2Radius) * 70.0) * 0.018;
        distorted += normalize(p + vec2(0.0001)) * wave2 * sin(radius * 45.0 - Time * 14.0);

        fragColor = vec4(sampleColor(center + distorted), 1.0);
        return;
    }

    if(m == 15){
        // Glitch: parpadeo, desplazamientos de lineas y separacion de canales.
        float line = floor(uv.y * InSize.y / 3.0);
        float seed = hash21(vec2(line, floor(Time * 18.0)));
        float block = step(0.72, seed);
        float offset = (hash21(vec2(line + 17.0, floor(Time * 13.0))) - 0.5) * 0.16 * block;

        vec2 glitchUv = uv;
        glitchUv.x += offset;

        float band = step(0.92, hash21(vec2(floor(uv.y * 45.0), floor(Time * 10.0))));
        glitchUv.x += (hash21(vec2(floor(Time * 31.0), floor(uv.y * 20.0))) - 0.5) * 0.07 * band;

        vec3 color = sampleColor(glitchUv);
        float channelShift = 0.012 * block;
        color.r = sampleColor(glitchUv + vec2(channelShift, 0.0)).r;
        color.b = sampleColor(glitchUv - vec2(channelShift, 0.0)).b;

        float flicker = 1.0 - 0.10 * step(0.88, hash21(vec2(floor(Time * 24.0), 71.0)));
        float scan = 1.0 - 0.035 * step(0.5, fract(uv.y * InSize.y * 0.5));
        color *= flicker * scan;

        if(block > 0.5){
            color = mix(color, color.bgr, 0.12);
        }

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    if(m == 16){
        // Terremoto: el nivel del efecto controla la intensidad del temblor.
        float strength = clamp(Progress, 1.0, 10.0);
        float normalizedStrength = strength / 10.0;
        float shakeX = (sin(Time * 47.0) * 0.55 + sin(Time * 79.0) * 0.45) * 0.0045 * strength;
        float shakeY = (cos(Time * 53.0) * 0.55 + sin(Time * 91.0) * 0.45) * 0.0045 * strength;

        vec2 shakeUv = uv + vec2(shakeX, shakeY);
        vec3 color = sampleColor(shakeUv);

        float edgeFade = smoothstep(0.0, 0.07 + normalizedStrength * 0.05,
            min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
        color *= mix(0.94, 1.0, edgeFade);

        fragColor = vec4(color, 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
