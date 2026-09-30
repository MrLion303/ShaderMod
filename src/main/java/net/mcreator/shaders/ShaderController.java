package net.mcreator.shaders;

import net.mcreator.shaders.init.ShadersModMobEffects;
import net.minecraft.client.Minecraft;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.resources.ResourceLocation;

import java.util.List;
import java.util.Map;

public final class ShaderController {
    private static ResourceLocation activeShader;
    private static MobEffect activeEffect;

    private static final List<Map.Entry<MobEffect, ResourceLocation>> SHADERS = List.of(
        Map.entry(ShadersModMobEffects.FLIP.get(), id("flip")),
        Map.entry(ShadersModMobEffects.PENCIL.get(), id("pencil")),
        Map.entry(ShadersModMobEffects.ENDER_MAN_VISION.get(), id("enderman_vision")),
        Map.entry(ShadersModMobEffects.SOBEL.get(), id("sobel")),
        Map.entry(ShadersModMobEffects.DESATURATE.get(), id("desaturate")),
        Map.entry(ShadersModMobEffects.BLUR.get(), id("blur")),
        Map.entry(ShadersModMobEffects.WOBBLE.get(), id("wobble")),
        Map.entry(ShadersModMobEffects.CREEPER_VISION.get(), id("creeper_vision")),
        Map.entry(ShadersModMobEffects.SPIDER_VISION.get(), id("spider_vision")),
        Map.entry(ShadersModMobEffects.SCAN_PINCUSHION.get(), id("scan_pincushion")),
        Map.entry(ShadersModMobEffects.NOTCH.get(), id("notch"))
    );

    private ShaderController() {}

    private static ResourceLocation id(String path) {
        return ResourceLocation.fromNamespaceAndPath(ShadersMod.MODID, "shader/post/" + path + ".json");
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
                System.err.println("[ShaderMod] Failed to load shader " + shader + ": " + ex.getMessage());
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

    public static void shutdownForEntity(LivingEntity entity) {
        if (entity == Minecraft.getInstance().player) {
            shutdown(Minecraft.getInstance());
        }
    }
}
