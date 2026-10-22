package net.mcreator.shaders;

import net.mcreator.shaders.init.ShadersModMobEffects;
import net.minecraft.client.Minecraft;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.client.renderer.PostChain;
import net.minecraft.client.renderer.PostPass;
import com.mojang.blaze3d.shaders.Uniform;

import java.util.List;
import java.util.Map;

public final class ShaderController {
    private static final ResourceLocation COMPOSITE_SHADER =
        new ResourceLocation(ShadersMod.MODID, "shaders/post/combinados.json");

    private static ResourceLocation activeShader;
    private static MobEffect activeEffect;

    private static final int ABSORPTION_ANIMATION_TICKS = 160;
    private static final int RUGIDO_FADE_TICKS = 12;
    private static final int REALIDADES_INTRO_TICKS = 14;
    private static final int REALIDADES_OUTRO_TICKS = 24;
    private static final int SANGRE_FADE_IN_TICKS = 20;
    private static final int SANGRE_FADE_OUT_TICKS = 40;
    private static final int DORMIR_EYE_TICKS = 160;
    private static final int DORMIR_OUTRO_TICKS = 30;

    private static boolean wasAbsorcionActive;
    private static boolean wasViajeActive;
    private static boolean wasSangreActive;
    private static boolean wasDormirActive;
    private static boolean dormirOutroActive;

    private static long absorptionStartGameTime;
    private static long realidadesStartGameTime;
    private static long sangreStartGameTime;
    private static long dormirStartGameTime;
    private static long dormirOutroStartGameTime;
    private static int absorptionTotalTicks = 1;
    private static int sangreTotalTicks = 1;

    // These effects use Minecraft's original Super Secret Settings post-processors.
    // Effects created for ShaderMod use the compositing chain below so they can stack.
    private static final List<Map.Entry<MobEffect, ResourceLocation>> VANILLA_SHADERS = List.of(
        Map.entry(ShadersModMobEffects.NOTCH.get(), vanilla("notch")),
        Map.entry(ShadersModMobEffects.FXAA.get(), vanilla("fxaa")),
        Map.entry(ShadersModMobEffects.ART.get(), vanilla("art")),
        Map.entry(ShadersModMobEffects.BUMPY.get(), vanilla("bumpy")),
        Map.entry(ShadersModMobEffects.BLOBS2.get(), vanilla("blobs2")),
        Map.entry(ShadersModMobEffects.PENCIL.get(), vanilla("pencil")),
        Map.entry(ShadersModMobEffects.COLOR_CONVOLVE.get(), vanilla("color_convolve")),
        Map.entry(ShadersModMobEffects.DECONVERGE.get(), vanilla("deconverge")),
        Map.entry(ShadersModMobEffects.FLIP.get(), vanilla("flip")),
        Map.entry(ShadersModMobEffects.ENDER_MAN_VISION.get(), vanilla("invert")),
        Map.entry(ShadersModMobEffects.NTSC.get(), vanilla("ntsc")),
        Map.entry(ShadersModMobEffects.OUTLINE.get(), vanilla("outline")),
        Map.entry(ShadersModMobEffects.PHOSPHOR.get(), vanilla("phosphor")),
        Map.entry(ShadersModMobEffects.SOBEL.get(), vanilla("sobel")),
        Map.entry(ShadersModMobEffects.BITS.get(), vanilla("bits")),
        Map.entry(ShadersModMobEffects.DESATURATE.get(), vanilla("desaturate")),
        Map.entry(ShadersModMobEffects.GREEN.get(), vanilla("green")),
        Map.entry(ShadersModMobEffects.BLUR.get(), vanilla("blur")),
        Map.entry(ShadersModMobEffects.WOBBLE.get(), vanilla("wobble")),
        Map.entry(ShadersModMobEffects.BLOBS.get(), vanilla("blobs")),
        Map.entry(ShadersModMobEffects.ANTIALIAS.get(), vanilla("antialias")),
        Map.entry(ShadersModMobEffects.CREEPER_VISION.get(), vanilla("creeper")),
        Map.entry(ShadersModMobEffects.SPIDER_VISION.get(), vanilla("spider")),
        Map.entry(ShadersModMobEffects.SCAN_PINCUSHION.get(), vanilla("scan_pincushion"))
    );

    // The new cinematic filters and the ShaderMod-created effects all share one shader.
    private static final List<MobEffect> COMPOSITE_EFFECTS = List.of(
        ShadersModMobEffects.ABSORCION.get(),
        ShadersModMobEffects.GREEN_GLOW.get(),
        ShadersModMobEffects.RED_GLOW.get(),
        ShadersModMobEffects.RED_FILTER.get(),
        ShadersModMobEffects.RUGIDO.get(),
        ShadersModMobEffects.GLITCH.get(),
        ShadersModMobEffects.TERREMOTO.get(),
        ShadersModMobEffects.VIAJE_REALIDADES.get(),
        ShadersModMobEffects.CINE.get(),
        ShadersModMobEffects.VHS.get(),
        ShadersModMobEffects.SANGRE.get(),
        ShadersModMobEffects.DORMIR.get()
    );

    private ShaderController() {}

    private static ResourceLocation vanilla(String path) {
        return new ResourceLocation("minecraft", "shaders/post/" + path + ".json");
    }

    public static void tick() {
        Minecraft mc = Minecraft.getInstance();
        if (mc.level == null || mc.player == null) {
            resetTracking();
            shutdown(mc);
            return;
        }

        updateEffectTiming(mc);

        boolean menteActive = mc.player.hasEffect(ShadersModMobEffects.MENTE.get());
        MobEffect compositeEffect = firstActiveCompositeEffect(mc);
        boolean compositeActive = compositeEffect != null || dormirOutroActive;

        MobEffect requested = null;
        ResourceLocation shader = null;

        if (compositeActive) {
            requested = compositeEffect != null ? compositeEffect : ShadersModMobEffects.DORMIR.get();
            shader = COMPOSITE_SHADER;
        } else if (menteActive) {
            // Mente itself darkens the level before entities render, so it needs no post-chain.
            shutdown(mc);
            return;
        } else {
            for (Map.Entry<MobEffect, ResourceLocation> entry : VANILLA_SHADERS) {
                if (mc.player.hasEffect(entry.getKey())) {
                    requested = entry.getKey();
                    shader = entry.getValue();
                    break;
                }
            }
        }

        if (requested == null || shader == null) {
            shutdown(mc);
            return;
        }

        // Adding or removing a composite effect only changes uniforms. Do not reload the
        // post-chain while one of its other effects is still active.
        if (activeShader == null || !shader.equals(activeShader)) {
            shutdown(mc);
            try {
                mc.gameRenderer.loadEffect(shader);
                activeShader = shader;
                activeEffect = requested;
            } catch (RuntimeException ex) {
                activeShader = null;
                activeEffect = null;
                System.err.println("[ShaderMod] Failed to load shader " + shader + ": " + ex);
                return;
            }
        } else {
            activeEffect = requested;
        }

        if (COMPOSITE_SHADER.equals(activeShader)) {
            updateCompositeFrame();
        }
    }

    private static void updateEffectTiming(Minecraft mc) {
        long gameTime = mc.level.getGameTime();

        MobEffectInstance absorption = mc.player.getEffect(ShadersModMobEffects.ABSORCION.get());
        boolean absorptionActive = absorption != null;
        if (absorptionActive && !wasAbsorcionActive) {
            absorptionStartGameTime = gameTime;
            absorptionTotalTicks = Math.max(1, absorption.getDuration());
        }
        wasAbsorcionActive = absorptionActive;

        MobEffectInstance viaje = mc.player.getEffect(ShadersModMobEffects.VIAJE_REALIDADES.get());
        boolean viajeActive = viaje != null;
        if (viajeActive && !wasViajeActive) {
            realidadesStartGameTime = gameTime;
        }
        wasViajeActive = viajeActive;

        MobEffectInstance sangre = mc.player.getEffect(ShadersModMobEffects.SANGRE.get());
        boolean sangreActive = sangre != null;
        if (sangreActive && !wasSangreActive) {
            sangreStartGameTime = gameTime;
            sangreTotalTicks = Math.max(1, sangre.getDuration());
        }
        wasSangreActive = sangreActive;

        MobEffectInstance dormir = mc.player.getEffect(ShadersModMobEffects.DORMIR.get());
        boolean dormirActive = dormir != null;
        if (dormirActive && !wasDormirActive) {
            dormirStartGameTime = gameTime;
            dormirOutroActive = false;
        } else if (!dormirActive && wasDormirActive) {
            dormirOutroActive = true;
            dormirOutroStartGameTime = gameTime;
        }
        if (dormirOutroActive && gameTime - dormirOutroStartGameTime >= DORMIR_OUTRO_TICKS) {
            dormirOutroActive = false;
        }
        wasDormirActive = dormirActive;
    }

    private static MobEffect firstActiveCompositeEffect(Minecraft mc) {
        for (MobEffect effect : COMPOSITE_EFFECTS) {
            if (mc.player.hasEffect(effect)) {
                return effect;
            }
        }
        return null;
    }

    public static void updateCompositeFrame() {
        Minecraft mc = Minecraft.getInstance();
        if (mc.level == null || mc.player == null) return;
        PostChain chain = mc.gameRenderer.currentEffect();
        if (chain == null) return;

        double gameTicks = mc.level.getGameTime() + mc.getFrameTime();
        float shaderTime = (float) (gameTicks / 20.0);

        MobEffectInstance absorption = mc.player.getEffect(ShadersModMobEffects.ABSORCION.get());
        float absorptionProgress = absorption == null ? 0.0F
            : clamp((float) ((gameTicks - absorptionStartGameTime) / ABSORPTION_ANIMATION_TICKS));

        MobEffectInstance rugido = mc.player.getEffect(ShadersModMobEffects.RUGIDO.get());
        float rugidoProgress = rugido == null ? 0.0F
            : clamp(rugido.getDuration() / (float) RUGIDO_FADE_TICKS);

        MobEffectInstance terremoto = mc.player.getEffect(ShadersModMobEffects.TERREMOTO.get());
        float terremotoStrength = terremoto == null ? 1.0F
            : Math.max(1.0F, Math.min(10.0F, terremoto.getAmplifier() + 1.0F));

        MobEffectInstance viaje = mc.player.getEffect(ShadersModMobEffects.VIAJE_REALIDADES.get());
        float viajeProgress = viaje == null ? 0.0F
            : clamp((float) ((gameTicks - realidadesStartGameTime) / REALIDADES_INTRO_TICKS));
        float viajeFade = viaje == null ? 0.0F
            : clamp(viaje.getDuration() / (float) REALIDADES_OUTRO_TICKS);

        MobEffectInstance sangre = mc.player.getEffect(ShadersModMobEffects.SANGRE.get());
        float sangreProgress = sangre == null ? 0.0F
            : clamp((float) ((gameTicks - sangreStartGameTime) / sangreTotalTicks));
        float sangreElapsed = sangre == null ? 0.0F : (float) (gameTicks - sangreStartGameTime);
        float sangreFadeIn = clamp(sangreElapsed / SANGRE_FADE_IN_TICKS);
        float sangreFadeOut = sangre == null ? 0.0F
            : clamp(sangre.getDuration() / (float) SANGRE_FADE_OUT_TICKS);
        float sangreFade = sangre == null ? 0.0F : Math.min(sangreFadeIn, sangreFadeOut);

        MobEffectInstance dormir = mc.player.getEffect(ShadersModMobEffects.DORMIR.get());
        float dormirProgress = dormir == null ? 8.0F
            : Math.min(8.0F, (float) ((gameTicks - dormirStartGameTime) / 20.0));
        float dormirOutro = dormirOutroActive
            ? clamp((float) ((gameTicks - dormirOutroStartGameTime) / DORMIR_OUTRO_TICKS))
            : 0.0F;

        for (PostPass pass : chain.passes) {
            set(pass, "Mode", 18.0F);
            set(pass, "ShaderTime", shaderTime);
            set(pass, "UseAbsorcion", has(mc, ShadersModMobEffects.ABSORCION.get()));
            set(pass, "UseGreenGlow", has(mc, ShadersModMobEffects.GREEN_GLOW.get()));
            set(pass, "UseRedGlow", has(mc, ShadersModMobEffects.RED_GLOW.get()));
            set(pass, "UseRedFilter", has(mc, ShadersModMobEffects.RED_FILTER.get()));
            set(pass, "UseRugido", has(mc, ShadersModMobEffects.RUGIDO.get()));
            set(pass, "UseGlitch", has(mc, ShadersModMobEffects.GLITCH.get()));
            set(pass, "UseTerremoto", has(mc, ShadersModMobEffects.TERREMOTO.get()));
            set(pass, "UseViaje", has(mc, ShadersModMobEffects.VIAJE_REALIDADES.get()));
            set(pass, "UseCine", has(mc, ShadersModMobEffects.CINE.get()));
            set(pass, "UseVHS", has(mc, ShadersModMobEffects.VHS.get()));
            set(pass, "UseSangre", has(mc, ShadersModMobEffects.SANGRE.get()));
            set(pass, "UseDormir", dormir != null || dormirOutroActive);

            set(pass, "AbsorcionProgress", absorptionProgress);
            set(pass, "RugidoProgress", rugidoProgress);
            set(pass, "TerremotoStrength", terremotoStrength);
            set(pass, "ViajeProgress", viajeProgress);
            set(pass, "ViajeFade", viajeFade);
            set(pass, "SangreProgress", sangreProgress);
            set(pass, "SangreFade", sangreFade);
            set(pass, "DormirProgress", dormirProgress);
            set(pass, "DormirOutro", dormirOutro);
        }
    }

    private static float has(Minecraft mc, MobEffect effect) {
        return mc.player.hasEffect(effect) ? 1.0F : 0.0F;
    }

    private static float clamp(float value) {
        return Math.max(0.0F, Math.min(1.0F, value));
    }

    private static void set(PostPass pass, String name, float value) {
        Uniform uniform = pass.getEffect().getUniform(name);
        if (uniform != null) {
            uniform.set(value);
        }
    }

    private static void resetTracking() {
        wasAbsorcionActive = false;
        wasViajeActive = false;
        wasSangreActive = false;
        wasDormirActive = false;
        dormirOutroActive = false;
        absorptionTotalTicks = 1;
        sangreTotalTicks = 1;
    }

    private static void shutdown(Minecraft mc) {
        if (activeShader != null || activeEffect != null) {
            mc.gameRenderer.shutdownEffect();
            activeShader = null;
            activeEffect = null;
        }
    }
}
