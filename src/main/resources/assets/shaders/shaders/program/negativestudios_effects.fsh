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
        // Rugido: varias ondas de choque fuertes que salen del centro.
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;
        float radius = length(p);
        vec2 direction = p / max(radius, 0.0001);

        float phase = Time * 0.72;
        float wave1 = exp(-abs(radius - fract(phase) * 1.45) * 42.0);
        float wave2 = exp(-abs(radius - fract(phase + 0.28) * 1.45) * 42.0);
        float wave3 = exp(-abs(radius - fract(phase + 0.56) * 1.45) * 42.0);
        float waves = wave1 + wave2 * 0.72 + wave3 * 0.48;

        float pulse = sin(radius * 38.0 - Time * 13.0);
        float displacement = pulse * waves * 0.105;
        displacement += sin(radius * 19.0 - Time * 8.0) * waves * 0.045;

        vec2 distorted = p + direction * displacement;
        distorted.x /= aspect;

        vec2 shifted = center + distorted;
        float chroma = waves * 0.018;
        vec3 color;
        color.r = sampleColor(shifted + direction * chroma).r;
        color.g = sampleColor(shifted).g;
        color.b = sampleColor(shifted - direction * chroma).b;

        float ringLight = clamp(waves, 0.0, 1.0);
        color += vec3(0.95, 0.92, 0.78) * ringLight * 0.16;

        float centerPulse = exp(-radius * 13.0) * (0.5 + 0.5 * sin(Time * 18.0));
        color += vec3(1.0, 0.86, 0.62) * centerPulse * 0.20;

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    if(m == 15){
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

    if(m == 17){
        // Viaje entre realidades: tunel de energia alrededor del Punto Zero.
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;

        float radius = length(p);
        float angle = atan(p.y, p.x);
        float travel = Time * 1.65;

        float swirl = sin(angle * 5.0 + radius * 17.0 - travel * 3.0);
        vec2 warped = p + (p / max(radius, 0.0001)) * swirl * 0.035 * smoothstep(0.05, 0.9, radius);
        warped *= 1.0 + 0.12 * smoothstep(0.05, 0.8, radius) * sin(travel + radius * 8.0);
        warped.x /= aspect;

        float chroma = 0.004 + radius * 0.014;
        vec2 radial = normalize(p + vec2(0.0001));
        vec3 color;
        color.r = sampleColor(center + warped + radial * chroma).r;
        color.g = sampleColor(center + warped).g;
        color.b = sampleColor(center + warped - radial * chroma).b;

        float rayPattern = sin(angle * 22.0 + radius * 34.0 - travel * 5.0);
        float rays = pow(max(rayPattern, 0.0), 10.0);
        float radialFade = smoothstep(0.03, 0.95, radius);
        color += vec3(0.05, 0.28, 0.95) * rays * radialFade * 0.42;
        color += vec3(0.34, 0.05, 0.95) * pow(max(-rayPattern, 0.0), 12.0) * radialFade * 0.24;

        float core = exp(-radius * 19.0);
        float corePulse = 0.78 + 0.22 * sin(travel * 8.0);
        color += vec3(0.72, 0.90, 1.0) * core * corePulse * 0.95;
        color += vec3(0.18, 0.40, 1.0) * exp(-radius * 7.0) * 0.35;

        float ring = exp(-abs(radius - (0.18 + 0.035 * sin(travel * 2.0))) * 55.0);
        color += vec3(0.40, 0.78, 1.0) * ring * 0.45;

        float vignette = smoothstep(0.35, 0.95, radius);
        color *= 1.0 - vignette * 0.22;

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
