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
        Map.entry(ShadersModMobEffects.FLIP.get(), vanilla("flip")),
        Map.entry(ShadersModMobEffects.PENCIL.get(), vanilla("pencil")),
        Map.entry(ShadersModMobEffects.ENDER_MAN_VISION.get(), vanilla("invert")),
        Map.entry(ShadersModMobEffects.SOBEL.get(), vanilla("sobel")),
        Map.entry(ShadersModMobEffects.DESATURATE.get(), vanilla("desaturate")),
        Map.entry(ShadersModMobEffects.BLUR.get(), vanilla("blur")),
        Map.entry(ShadersModMobEffects.WOBBLE.get(), vanilla("wobble")),
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
