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
        // Rugido: muchas ondas rapidas, con deformacion fuerte y fade out al terminar.
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;
        float radius = length(p);
        vec2 direction = p / max(radius, 0.0001);

        float phase = Time * 2.15;
        float waves = 0.0;
        waves += exp(-abs(radius - fract(phase + 0.00) * 1.55) * 58.0) * 1.00;
        waves += exp(-abs(radius - fract(phase + 0.14) * 1.55) * 58.0) * 0.92;
        waves += exp(-abs(radius - fract(phase + 0.28) * 1.55) * 58.0) * 0.84;
        waves += exp(-abs(radius - fract(phase + 0.42) * 1.55) * 58.0) * 0.76;
        waves += exp(-abs(radius - fract(phase + 0.56) * 1.55) * 58.0) * 0.68;
        waves += exp(-abs(radius - fract(phase + 0.70) * 1.55) * 58.0) * 0.60;
        waves += exp(-abs(radius - fract(phase + 0.84) * 1.55) * 58.0) * 0.52;
        waves = clamp(waves, 0.0, 2.8);

        float pulse = sin(radius * 52.0 - Time * 34.0);
        float ripple = sin(radius * 25.0 - Time * 17.0);
        float displacement = pulse * waves * 0.135 + ripple * waves * 0.055;

        vec2 distorted = p + direction * displacement;
        distorted += vec2(
            sin(p.y * 31.0 - Time * 25.0),
            cos(p.x * 27.0 + Time * 23.0)
        ) * waves * 0.012;
        distorted.x /= aspect;

        vec2 shifted = center + distorted;
        float chroma = waves * 0.025;
        vec3 color;
        color.r = sampleColor(shifted + direction * chroma).r;
        color.g = sampleColor(shifted).g;
        color.b = sampleColor(shifted - direction * chroma).b;

        float ringLight = clamp(waves * 0.62, 0.0, 1.0);
        color += vec3(1.0, 0.92, 0.70) * ringLight * 0.24;

        float centerPulse = exp(-radius * 12.0) * (0.5 + 0.5 * sin(Time * 25.0));
        color += vec3(1.0, 0.80, 0.45) * centerPulse * 0.25;

        // Progress is 1 during the effect and approaches 0 during the last ticks.
        float fadeOut = smoothstep(0.0, 0.90, clamp(Progress, 0.0, 1.0));
        fadeOut = fadeOut * fadeOut * (3.0 - 2.0 * fadeOut);
        color = mix(original, color, fadeOut);

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    if(m == 15){
        // Glitch: bloques, tearing, saltos verticales, RGB split, flashes y ruido temporal.
        float frame = floor(Time * 28.0);
        float coarseFrame = floor(Time * 12.0);
        float row = floor(uv.y * InSize.y / 2.0);
        float blockRow = floor(uv.y * 34.0);
        float column = floor(uv.x * 48.0);

        float tearSeed = hash21(vec2(row, frame));
        float tear = step(0.62, tearSeed);
        float hugeTear = step(0.91, hash21(vec2(floor(uv.y * 12.0), coarseFrame)));

        float offsetX = (hash21(vec2(row + 11.0, frame + 7.0)) - 0.5) * 0.28 * tear;
        offsetX += (hash21(vec2(blockRow + 91.0, coarseFrame)) - 0.5) * 0.42 * hugeTear;

        float offsetY = (hash21(vec2(column + 37.0, frame + 19.0)) - 0.5) * 0.035 * tear;
        vec2 glitchUv = uv + vec2(offsetX, offsetY);

        float blockSeed = hash21(vec2(floor(uv.x * 22.0), blockRow + coarseFrame * 2.0));
        float blockGlitch = step(0.73, blockSeed);
        vec2 blockOffset = vec2(
            (hash21(vec2(blockSeed * 91.0, coarseFrame)) - 0.5) * 0.20,
            (hash21(vec2(blockSeed * 37.0, frame)) - 0.5) * 0.05
        ) * blockGlitch;
        glitchUv += blockOffset;

        float microTear = step(0.78, hash21(vec2(floor(uv.y * 180.0), frame)));
        glitchUv.x += (hash21(vec2(floor(uv.y * 180.0), coarseFrame + 13.0)) - 0.5) * 0.055 * microTear;

        float channelShift = 0.008 + 0.035 * max(tear, hugeTear);
        vec3 color;
        color.r = sampleColor(glitchUv + vec2(channelShift, 0.0)).r;
        color.g = sampleColor(glitchUv + vec2((hash21(vec2(row, frame + 3.0)) - 0.5) * 0.018, 0.0)).g;
        color.b = sampleColor(glitchUv - vec2(channelShift * 1.25, 0.0)).b;

        float invert = step(0.965, hash21(vec2(blockRow, frame * 0.73)));
        color = mix(color, 1.0 - color, invert * 0.72);

        float flash = step(0.955, hash21(vec2(frame, 71.0)));
        color += vec3(1.0) * flash * 0.28;

        float scan = 1.0 - 0.10 * step(0.5, fract(uv.y * InSize.y * 0.5));
        float flicker = 0.78 + 0.22 * hash21(vec2(frame, coarseFrame + 44.0));
        color *= scan * flicker;

        float noise = hash21(floor(uv * InSize.xy * 0.45) + frame);
        color += (noise - 0.5) * 0.055;

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
        // Viaje entre realidades: vortice continuo, celeste/morado y entrada con una gran onda.
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;

        float radius = length(p);
        float angle = atan(p.y, p.x);
        float spin = Time * 3.7;
        float travel = Time * 2.25;

        // Distorsion polar agresiva y siempre rotando.
        float twist = 0.34 * sin(radius * 15.0 - travel * 1.7)
                    + 0.16 * sin(angle * 7.0 + spin)
                    + 0.09 * sin(radius * 38.0 + spin * 1.8);
        float radialWarp = 1.0 + 0.18 * sin(travel + radius * 13.0) * smoothstep(0.03, 0.95, radius);

        float c = cos(twist);
        float s = sin(twist);
        vec2 rotated = vec2(p.x * c - p.y * s, p.x * s + p.y * c) * radialWarp;

        vec2 warped = rotated;
        warped += (rotated / max(length(rotated), 0.0001))
            * sin(angle * 11.0 - spin * 1.4 + radius * 24.0)
            * 0.075 * smoothstep(0.04, 0.92, radius);
        warped.x /= aspect;

        vec2 radial = p / max(radius, 0.0001);
        float chroma = 0.008 + radius * 0.030;

        vec3 color;
        color.r = sampleColor(center + warped + radial * chroma).r;
        color.g = sampleColor(center + warped).g;
        color.b = sampleColor(center + warped - radial * chroma).b;

        // Bañar todo el entorno con celeste y morado.
        float blueMask = 0.5 + 0.5 * sin(angle * 4.0 + spin + radius * 10.0);
        vec3 realityTint = mix(
            vec3(0.20, 0.82, 1.0),
            vec3(0.58, 0.12, 1.0),
            blueMask
        );
        float tintStrength = 0.38 + 0.20 * sin(travel * 0.8 + radius * 6.0);
        color = mix(color, color * 0.48 + realityTint * 0.62, clamp(tintStrength, 0.28, 0.68));

        // Rayos y anillos que giran a diferentes velocidades.
        float raysA = pow(max(0.0, sin(angle * 18.0 - spin * 1.3 + radius * 29.0)), 7.0);
        float raysB = pow(max(0.0, sin(angle * 31.0 + spin * 1.9 - radius * 41.0)), 11.0);
        float rings = pow(max(0.0, sin(radius * 52.0 - travel * 4.0 + angle * 3.0)), 8.0);

        color += vec3(0.10, 0.72, 1.0) * raysA * 0.55;
        color += vec3(0.62, 0.08, 1.0) * raysB * 0.48;
        color += vec3(0.35, 0.70, 1.0) * rings * 0.30;

        float core = exp(-radius * 17.0);
        float corePulse = 0.78 + 0.22 * sin(travel * 7.0);
        color += vec3(0.72, 0.94, 1.0) * core * corePulse * 1.25;
        color += vec3(0.38, 0.10, 1.0) * exp(-radius * 6.0) * 0.45;

        float ringRadius = 0.16 + 0.045 * sin(travel * 1.7);
        float ring = exp(-abs(radius - ringRadius) * 68.0);
        color += mix(vec3(0.20, 0.92, 1.0), vec3(0.70, 0.12, 1.0), 0.5 + 0.5 * sin(spin)) * ring * 0.75;

        // Onda gigante de entrada desde el centro + fade in.
        float intro = clamp(Progress, 0.0, 1.0);
        float introRadius = intro * 1.38;
        float introWave = exp(-abs(radius - introRadius) * 72.0);
        float introGlow = exp(-abs(radius - introRadius) * 18.0);
        float introFade = smoothstep(0.0, 1.0, intro);
        color += vec3(0.34, 0.90, 1.0) * introWave * 1.20;
        color += vec3(0.48, 0.10, 1.0) * introGlow * 0.34;
        color = mix(original, color, introFade);

        float vignette = smoothstep(0.30, 1.0, radius);
        color *= 1.0 - vignette * 0.16;

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
