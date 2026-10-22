#version 150
uniform sampler2D DiffuseSampler;
out vec4 fragColor;
uniform vec2 InSize;
uniform float Mode;
uniform float Progress;
uniform float Time;
uniform float ShaderTime;
uniform float Fade;
uniform float UseAbsorcion;
uniform float UseGreenGlow;
uniform float UseRedGlow;
uniform float UseRedFilter;
uniform float UseRugido;
uniform float UseGlitch;
uniform float UseTerremoto;
uniform float UseViaje;
uniform float UseCine;
uniform float UseVHS;
uniform float UseSangre;
uniform float UseDormir;
uniform float AbsorcionProgress;
uniform float RugidoProgress;
uniform float TerremotoStrength;
uniform float ViajeProgress;
uniform float ViajeFade;
uniform float SangreProgress;
uniform float SangreFade;
uniform float DormirProgress;
uniform float DormirOutro;
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

float bloodBlob(vec2 uv, vec2 center, vec2 scale) {
    vec2 d = (uv - center) * scale;
    return exp(-dot(d, d) * 2.35);
}

float blinkPulse(float t, float startTime) {
    float closeLid = smoothstep(startTime, startTime + 0.045, t);
    float openLid = 1.0 - smoothstep(startTime + 0.105, startTime + 0.19, t);
    return closeLid * openLid;
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
        // Viaje entre realidades: el giro usa varias velocidades independientes.
        // Asi no hay un ciclo corto visible que reinicie toda la escena de golpe.
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;

        float radius = length(p);
        float angle = atan(p.y, p.x);

        // Tres capas con velocidades distintas mantienen el movimiento girando de forma continua.
        float spinA = ShaderTime * 0.83;
        float spinB = ShaderTime * 1.37;
        float spinC = ShaderTime * 2.11;
        float travelA = ShaderTime * 1.19;
        float travelB = ShaderTime * 1.73;

        // Distorsion polar agresiva, pero con fases desacopladas para evitar un loop corto.
        float twist = 0.34 * sin(radius * 15.0 - travelA)
                    + 0.16 * sin(angle * 7.0 + spinA)
                    + 0.09 * sin(radius * 38.0 + spinB)
                    + 0.055 * sin(angle * 13.0 - spinC + radius * 9.0);
        float radialWarp = 1.0
            + 0.18 * sin(travelB + radius * 13.0)
            + 0.045 * sin(travelA * 1.31 + angle * 5.0);

        float c = cos(twist);
        float s = sin(twist);
        vec2 rotated = vec2(p.x * c - p.y * s, p.x * s + p.y * c) * radialWarp;

        // La textura interna rota de verdad alrededor del centro en varias capas.
        float internalAngleA = angle - spinA;
        float internalAngleB = angle + spinB;
        float internalAngleC = angle - spinC;

        vec2 warped = rotated;
        warped += (rotated / max(length(rotated), 0.0001))
            * sin(internalAngleA * 11.0 + radius * 24.0 - travelA * 0.72)
            * 0.075 * smoothstep(0.04, 0.92, radius);
        warped += (rotated / max(length(rotated), 0.0001))
            * sin(internalAngleB * 7.0 - radius * 31.0 + travelB)
            * 0.030 * smoothstep(0.06, 0.90, radius);
        warped.x /= aspect;

        vec2 radial = p / max(radius, 0.0001);
        float chroma = 0.008 + radius * 0.030;

        vec3 color;
        color.r = sampleColor(center + warped + radial * chroma).r;
        color.g = sampleColor(center + warped).g;
        color.b = sampleColor(center + warped - radial * chroma).b;

        // Bañar todo el entorno con celeste y morado, tambien con rotacion desacoplada.
        float blueMask = 0.5
            + 0.5 * sin(internalAngleA * 4.0 + radius * 10.0)
            + 0.15 * sin(internalAngleC * 9.0 - radius * 17.0);
        blueMask = clamp(blueMask, 0.0, 1.0);
        vec3 realityTint = mix(
            vec3(0.20, 0.82, 1.0),
            vec3(0.58, 0.12, 1.0),
            blueMask
        );
        float tintStrength = 0.38 + 0.20 * sin(travelB * 0.83 + radius * 6.0);
        color = mix(color, color * 0.48 + realityTint * 0.62, clamp(tintStrength, 0.28, 0.68));

        // Rayas radiales: el angulo avanza de forma acumulativa y las lineas
        // permanecen siempre presentes. No hay pulsos de intensidad que hagan
        // parecer que la animacion vuelve a empezar.
        float raySpin = ShaderTime * 0.72;
        float rayAngleA = angle - raySpin;
        float rayAngleB = angle + ShaderTime * 0.93;
        float rayAngleC = angle - ShaderTime * 1.17;

        // Se evita abs(cos()), porque duplicaba visualmente el giro cada 180 grados.
        // Las distintas cantidades de rayas son coprimas, asi el patron combinado
        // no vuelve a la misma configuracion durante una vuelta corta.
        float raysA = pow(max(cos(rayAngleA * 17.0 + radius * 29.0), 0.0), 5.0);
        float raysB = pow(max(cos(rayAngleB * 29.0 - radius * 41.0), 0.0), 6.0);
        float raysC = pow(max(cos(rayAngleC * 23.0 + radius * 36.0), 0.0), 5.0);

        float rings = pow(0.5 + 0.5 * cos(radius * 52.0 - travelA * 3.7 + internalAngleB * 3.0), 5.0);

        color += vec3(0.10, 0.72, 1.0) * raysA * 0.42;
        color += vec3(0.62, 0.08, 1.0) * raysB * 0.38;
        color += vec3(0.25, 0.42, 1.0) * raysC * 0.24;
        color += vec3(0.35, 0.70, 1.0) * rings * 0.22;

        float core = exp(-radius * 17.0);
        float corePulse = 0.78 + 0.22 * sin(ShaderTime * 2.97);
        color += vec3(0.72, 0.94, 1.0) * core * corePulse * 1.25;
        color += vec3(0.38, 0.10, 1.0) * exp(-radius * 6.0) * 0.45;

        // El anillo principal mantiene su radio estable; lo que gira es su patron de luz.
        float ringRadius = 0.17;
        float ring = exp(-abs(radius - ringRadius) * 68.0);
        float ringColorPhase = 0.5 + 0.5 * sin(internalAngleC * 5.0 + radius * 12.0);
        color += mix(vec3(0.20, 0.92, 1.0), vec3(0.70, 0.12, 1.0), ringColorPhase) * ring * 0.75;

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

        // Fade in at the beginning and fade back to the unmodified image at the end.
        float fadeAmount = smoothstep(0.0, 1.0, clamp(Fade, 0.0, 1.0));
        color = mix(original, color, fadeAmount);

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }


    if(m == 18){
        vec2 uv = texCoord;
        vec2 sampleUv = uv;
        float t = max(ShaderTime, 0.0);
        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);

        // Earthquake shifts the source coordinates. Color overlays below can then stack on top.
        if(UseTerremoto > 0.5){
            float strength = clamp(TerremotoStrength, 1.0, 10.0);
            float shakeX = (sin(t * 47.0) * 0.55 + sin(t * 79.0) * 0.45) * 0.0045 * strength;
            float shakeY = (cos(t * 53.0) * 0.55 + sin(t * 91.0) * 0.45) * 0.0045 * strength;
            sampleUv += vec2(shakeX, shakeY);
        }

        // Glitch tears individual horizontal bands without replacing other active effects.
        if(UseGlitch > 0.5){
            float frame = floor(t * 28.0);
            float row = floor(uv.y * InSize.y / 2.0);
            float seed = hash21(vec2(row, frame));
            float tear = step(0.62, seed);
            float wideTear = step(0.92, hash21(vec2(floor(uv.y * 14.0), floor(t * 12.0))));
            sampleUv.x += (hash21(vec2(row + 11.0, frame + 7.0)) - 0.5) * 0.12 * tear;
            sampleUv.x += (hash21(vec2(floor(uv.y * 14.0), floor(t * 12.0))) - 0.5) * 0.18 * wideTear;
            sampleUv.y += (hash21(vec2(floor(uv.x * 40.0), frame + 19.0)) - 0.5) * 0.018 * tear;
        }

        // VHS tracking jitter is separate from the glitch effect, so both can be enabled.
        if(UseVHS > 0.5){
            float tracking = sin(uv.y * 29.0 - t * 2.7) * 0.0022;
            float wobble = sin(uv.y * 6.0 + t * 1.4) * 0.0018;
            float trackingBand = step(0.965, hash21(vec2(floor(uv.y * 22.0), floor(t * 5.0))));
            sampleUv.x += tracking + wobble + trackingBand * 0.022;
            sampleUv.y += sin(uv.x * 11.0 + t * 1.2) * 0.0012;
        }

        // Viaje entre Realidades adds its polar twist to the existing source transform.
        float viajeAmount = UseViaje * clamp(ViajeFade, 0.0, 1.0);
        if(viajeAmount > 0.001){
            vec2 center = vec2(0.5);
            vec2 p = sampleUv - center;
            p.x *= aspect;
            float radius = length(p);
            float angle = atan(p.y, p.x);
            float spinA = t * 0.83;
            float spinB = t * 1.37;
            float spinC = t * 2.11;
            float travelA = t * 1.19;
            float travelB = t * 1.73;
            float twist = 0.34 * sin(radius * 15.0 - travelA)
                        + 0.16 * sin(angle * 7.0 + spinA)
                        + 0.09 * sin(radius * 38.0 + spinB)
                        + 0.055 * sin(angle * 13.0 - spinC + radius * 9.0);
            float radialWarp = 1.0
                + 0.18 * sin(travelB + radius * 13.0)
                + 0.045 * sin(travelA * 1.31 + angle * 5.0);
            float cs = cos(twist);
            float sn = sin(twist);
            vec2 warped = vec2(p.x * cs - p.y * sn, p.x * sn + p.y * cs) * radialWarp;
            warped.x /= aspect;
            vec2 travelUv = center + warped;
            sampleUv += (travelUv - sampleUv) * viajeAmount;
        }

        // Absorción contributes a vortex without disabling screen tints or other filters.
        float absorption = UseAbsorcion * clamp(AbsorcionProgress, 0.0, 1.0);
        if(absorption > 0.001){
            vec2 center = vec2(0.5);
            vec2 p = sampleUv - center;
            p.x *= aspect;
            float radius = length(p);
            float twist = absorption * 9.0 * (1.0 - smoothstep(0.03, 1.15, radius))
                        + absorption * 2.5 * smoothstep(0.30, 1.15, radius);
            float cs = cos(twist);
            float sn = sin(twist);
            vec2 rotated = vec2(p.x * cs - p.y * sn, p.x * sn + p.y * cs);
            float sourceRadius = radius * (1.0 + absorption * 0.48 * smoothstep(0.05, 1.0, radius));
            vec2 source = rotated * (sourceRadius / max(length(rotated), 0.0001));
            source.x /= aspect;
            sampleUv += center + source - sampleUv;
        }

        // Rugido adds travelling radial ripples to the same transformed image.
        float rugidoStrength = UseRugido * clamp(RugidoProgress, 0.0, 1.0);
        if(rugidoStrength > 0.001){
            vec2 center = vec2(0.5);
            vec2 p = sampleUv - center;
            p.x *= aspect;
            float radius = length(p);
            vec2 direction = p / max(radius, 0.0001);
            float phase = t * 2.15;
            float waves = 0.0;
            waves += exp(-abs(radius - fract(phase + 0.00) * 1.55) * 58.0) * 1.00;
            waves += exp(-abs(radius - fract(phase + 0.14) * 1.55) * 58.0) * 0.92;
            waves += exp(-abs(radius - fract(phase + 0.28) * 1.55) * 58.0) * 0.84;
            waves = clamp(waves, 0.0, 2.8);
            float displacement = (sin(radius * 52.0 - t * 34.0) * waves * 0.135
                                 + sin(radius * 25.0 - t * 17.0) * waves * 0.055) * rugidoStrength;
            vec2 rippleOffset = direction * displacement;
            rippleOffset.x /= aspect;
            sampleUv += rippleOffset;
        }

        vec3 color = sampleColor(sampleUv);
        if(UseVHS > 0.5){
            float chroma = 0.0025;
            color.r = sampleColor(sampleUv + vec2(chroma, 0.0)).r;
            color.b = sampleColor(sampleUv - vec2(chroma * 1.4, 0.0)).b;
            float scanline = 0.84 + 0.16 * sin(uv.y * InSize.y * 3.14159265);
            float noise = hash21(floor(uv * InSize.xy * 0.5) + floor(t * 24.0));
            float flicker = 0.94 + 0.06 * hash21(vec2(floor(t * 12.0), 37.0));
            color = color * scanline * flicker + (noise - 0.5) * 0.075;
            color = mix(color, vec3(dot(color, vec3(0.299, 0.587, 0.114))), 0.12);
        }

        // Legacy custom effects are independent layers, not mutually exclusive modes.
        if(UseRedFilter > 0.5){
            color = mix(color, vec3(1.0, 0.0, 0.0), 0.10);
        }
        float edgeDistance = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
        float edgeGlow = pow(clamp(1.0 - smoothstep(0.0, 0.24, edgeDistance), 0.0, 1.0), 1.35);
        if(UseGreenGlow > 0.5){
            color += vec3(0.03, 1.0, 0.08) * pow(edgeGlow, 1.8) * 0.82;
        }
        if(UseRedGlow > 0.5){
            color += vec3(1.0, 0.025, 0.025) * pow(edgeGlow, 1.8) * 0.82;
        }

        if(UseAbsorcion > 0.5){
            vec2 p = uv - vec2(0.5);
            p.x *= aspect;
            float radius = length(p);
            float coreRadius = 0.32 * clamp(AbsorcionProgress, 0.0, 1.0);
            float coreMask = 1.0 - smoothstep(coreRadius, coreRadius + 0.05, radius);
            color *= 1.0 - coreMask * smoothstep(0.0, 0.18, AbsorcionProgress);
            color *= 1.0 - clamp(AbsorcionProgress, 0.0, 1.0) * 0.78 * smoothstep(0.28, 1.05, radius);
        }

        if(UseRugido > 0.5){
            float radius = length((uv - vec2(0.5)) * vec2(aspect, 1.0));
            float wave = exp(-abs(radius - fract(t * 2.15) * 1.55) * 58.0);
            color += vec3(1.0, 0.92, 0.70) * wave * rugidoStrength * 0.24;
        }

        if(UseViaje > 0.5){
            vec2 p = uv - vec2(0.5);
            p.x *= aspect;
            float radius = length(p);
            float angle = atan(p.y, p.x);
            float raySpin = t * 0.72;
            float raysA = pow(max(cos((angle - raySpin) * 17.0 + radius * 29.0), 0.0), 5.0);
            float raysB = pow(max(cos((angle + t * 0.93) * 29.0 - radius * 41.0), 0.0), 6.0);
            float raysC = pow(max(cos((angle - t * 1.17) * 23.0 + radius * 36.0), 0.0), 5.0);
            float rings = pow(0.5 + 0.5 * cos(radius * 52.0 - t * 4.4 + angle * 3.0), 5.0);
            vec3 travelOverlay = vec3(0.10, 0.72, 1.0) * raysA * 0.42
                               + vec3(0.62, 0.08, 1.0) * raysB * 0.38
                               + vec3(0.25, 0.42, 1.0) * raysC * 0.24
                               + vec3(0.35, 0.70, 1.0) * rings * 0.22;
            float intro = clamp(ViajeProgress, 0.0, 1.0);
            float introRadius = intro * 1.38;
            float introWave = exp(-abs(radius - introRadius) * 72.0);
            travelOverlay += vec3(0.34, 0.90, 1.0) * introWave * 1.20;
            travelOverlay += vec3(0.48, 0.10, 1.0) * exp(-abs(radius - introRadius) * 18.0) * 0.34;
            color += travelOverlay * clamp(ViajeFade, 0.0, 1.0);
            float tintMix = 0.38 * clamp(ViajeFade, 0.0, 1.0);
            color = mix(color, color * 0.48 + vec3(0.25, 0.55, 1.0) * 0.62, tintMix);
        }

        // VHS color bleed, tape noise and faint tracking bars.
        if(UseVHS > 0.5){
            float tapeLine = step(0.982, hash21(vec2(floor(uv.y * 40.0), floor(t * 4.0))));
            color = mix(color, color * vec3(0.72, 0.90, 1.08), 0.18);
            color += vec3(0.72, 0.86, 1.0) * tapeLine * 0.10;
        }

        // Blood stains stay at half opacity while the scene gradually darkens.
        if(UseSangre > 0.5){
            float stainA = bloodBlob(uv, vec2(-0.03, 0.04), vec2(3.8, 3.2));
            float stainB = bloodBlob(uv, vec2(0.12, 0.17), vec2(5.3, 4.7));
            float stainC = bloodBlob(uv, vec2(1.03, 0.02), vec2(3.5, 3.4));
            float stainD = bloodBlob(uv, vec2(0.91, 0.14), vec2(5.8, 4.5));
            float stainE = bloodBlob(uv, vec2(0.48, 1.04), vec2(4.8, 3.1));
            float grain = hash21(floor(uv * InSize.xy * 0.055) + floor(t * 5.0));
            float stains = clamp((stainA + stainB + stainC + stainD + stainE) * (0.65 + grain * 0.45), 0.0, 1.0);
            stains = smoothstep(0.12, 0.72, stains);
            float fade = clamp(SangreFade, 0.0, 1.0);
            color = mix(color, vec3(0.48, 0.005, 0.025), stains * 0.50 * fade);
            float distanceFromCenter = length((uv - vec2(0.5)) * vec2(aspect, 1.0));
            float vignette = smoothstep(0.22, 0.82, distanceFromCenter);
            float fainting = smoothstep(0.05, 0.95, clamp(SangreProgress, 0.0, 1.0));
            color *= 1.0 - vignette * fainting * 0.78 * fade;
        }

        // Cinematic black letterbox bars.
        if(UseCine > 0.5){
            float edgeY = min(uv.y, 1.0 - uv.y);
            float bars = 1.0 - smoothstep(0.105, 0.118, edgeY);
            color = mix(color, vec3(0.0), bars);
        }

        // Dormir: two quick blinks, then a slow eyelid closure over the first eight seconds.
        // Once the effect expires, DormirOutro reopens the eye before restoring the image.
        if(UseDormir > 0.5){
            float elapsed = clamp(DormirProgress, 0.0, 8.0);
            float blink1 = blinkPulse(elapsed, 0.55);
            float blink2 = blinkPulse(elapsed, 1.55);
            float eyeOpen = 1.0 - smoothstep(2.15, 8.0, elapsed);
            eyeOpen *= 1.0 - max(blink1, blink2);
            eyeOpen = max(eyeOpen, clamp(DormirOutro, 0.0, 1.0));

            float horizontal = abs(uv.x - 0.5) / 0.52;
            float eyeCurve = sqrt(max(0.0, 1.0 - horizontal * horizontal));
            float aperture = 0.5 * eyeOpen * eyeCurve;
            float openMask = eyeOpen <= 0.001
                ? 0.0
                : 1.0 - smoothstep(aperture - 0.004, aperture + 0.004, abs(uv.y - 0.5));
            openMask = mix(openMask, 1.0, smoothstep(0.88, 1.0, eyeOpen));
            color *= openMask;
        }

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
