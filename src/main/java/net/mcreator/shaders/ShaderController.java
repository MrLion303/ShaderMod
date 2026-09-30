package net.mcreator.shaders;

import net.mcreator.shaders.init.ShadersModMobEffects;
import net.minecraft.client.Minecraft;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.world.effect.MobEffect;

import java.util.List;
import java.util.Map;

public final class ShaderController {
    private static ResourceLocation activeShader;
    private static MobEffect activeEffect;

    /*
     * Minecraft 1.20.1 still ships the original Super Secret Settings
     * post-processing chains. Use those vanilla chains directly so their
     * original multi-pass behavior is preserved.
     */
    private static final List<Map.Entry<MobEffect, ResourceLocation>> SHADERS = List.of(
        Map.entry(ShadersModMobEffects.NOTCH.get(), vanilla("notch")),
        Map.entry(ShadersModMobEffects.FXAA.get(), vanilla("fxaa")),
        Map.entry(ShadersModMobEffects.ART.get(), vanilla("art")),
        Map.entry(ShadersModMobEffects.BUMPY.get(), vanilla("bumpy")),
        Map.entry(ShadersModMobEffects.BLOBS2.get(), vanilla("blobs2")),
        Map.entry(ShadersModMobEffects.PENCIL.get(), vanilla("pencil")),
        Map.entry(ShadersModMobEffects.COLOR_CONVOLVE.get(), vanilla("color_convolve")),
        Map.entry(ShadersModMobEffects.DECONVERGE.get(), vanilla("deconverge")),
        Map.entry(ShadersModMobEffects.FLIP.get(), vanilla("flip")),
        Map.entry(ShadersModMobEffects.PENCIL.get(), vanilla("pencil")),
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
        Map.entry(ShadersModMobEffects.SCAN_PINCUSHION.get(), vanilla("scan_pincushion")),
        Map.entry(ShadersModMobEffects.NOTCH.get(), vanilla("notch"))
    );

    private ShaderController() {}

    private static ResourceLocation vanilla(String path) {
        return new ResourceLocation("minecraft", "shaders/post/" + path + ".json");
    }

    public static void tick() {
        Minecraft mc = Minecraft.getInstance();
        if (mc.level == null || mc.player == null) {
            shutdown(mc);
            return;
        }

        MobEffect requested = null;
        ResourceLocation shader = null;

        for (Map.Entry<MobEffect, ResourceLocation> entry : SHADERS) {
            if (mc.player.hasEffect(entry.getKey())) {
                requested = entry.getKey();
                shader = entry.getValue();
                break;
            }
        }

        if (requested == null) {
            shutdown(mc);
            return;
        }

        if (!shader.equals(activeShader) || requested != activeEffect) {
            shutdown(mc);
            try {
                mc.gameRenderer.loadEffect(shader);
                activeShader = shader;
                activeEffect = requested;
            } catch (RuntimeException ex) {
                activeShader = null;
                activeEffect = null;
                System.err.println("[ShaderMod] Failed to load vanilla shader " + shader + ": " + ex);
            }
        }
    }

    private static void shutdown(Minecraft mc) {
        if (activeShader != null || activeEffect != null) {
            mc.gameRenderer.shutdownEffect();
            activeShader = null;
            activeEffect = null;
        }
    }
}
