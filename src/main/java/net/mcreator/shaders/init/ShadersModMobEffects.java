package net.mcreator.shaders.init;

import net.mcreator.shaders.ShadersMod;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectCategory;
import net.minecraft.resources.ResourceLocation;
import net.minecraftforge.client.extensions.common.IClientMobEffectExtensions;
import net.minecraft.client.gui.Gui;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.screens.inventory.EffectRenderingInventoryScreen;
import net.minecraft.world.effect.MobEffectInstance;

import java.util.function.Consumer;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

public final class ShadersModMobEffects {
    public static final DeferredRegister<MobEffect> REGISTRY =
        DeferredRegister.create(ForgeRegistries.MOB_EFFECTS, ShadersMod.MODID);

    public static final RegistryObject<MobEffect> FXAA = register("fxaa", ShaderEffect::new);
    public static final RegistryObject<MobEffect> ART = register("art", ShaderEffect::new);
    public static final RegistryObject<MobEffect> BUMPY = register("bumpy", ShaderEffect::new);
    public static final RegistryObject<MobEffect> BLOBS2 = register("blobs2", ShaderEffect::new);
    public static final RegistryObject<MobEffect> COLOR_CONVOLVE = register("color_convolve", ShaderEffect::new);
    public static final RegistryObject<MobEffect> DECONVERGE = register("deconverge", ShaderEffect::new);
    public static final RegistryObject<MobEffect> NTSC = register("ntsc", ShaderEffect::new);
    public static final RegistryObject<MobEffect> OUTLINE = register("outline", ShaderEffect::new);
    public static final RegistryObject<MobEffect> PHOSPHOR = register("phosphor", ShaderEffect::new);
    public static final RegistryObject<MobEffect> BITS = register("bits", ShaderEffect::new);
    public static final RegistryObject<MobEffect> GREEN = register("green", ShaderEffect::new);
    public static final RegistryObject<MobEffect> BLOBS = register("blobs", ShaderEffect::new);
    public static final RegistryObject<MobEffect> ANTIALIAS = register("antialias", ShaderEffect::new);

    public static final RegistryObject<MobEffect> FLIP = register("flip", FlipMobEffect::new);
    public static final RegistryObject<MobEffect> PENCIL = register("pencil", PencilMobEffect::new);
    public static final RegistryObject<MobEffect> ENDER_MAN_VISION = register("enderman_vision", EndermanVisionMobEffect::new);
    public static final RegistryObject<MobEffect> SOBEL = register("sobel", SobelMobEffect::new);
    public static final RegistryObject<MobEffect> DESATURATE = register("desaturate", DesaturateMobEffect::new);
    public static final RegistryObject<MobEffect> BLUR = register("blur", BlurMobEffect::new);
    public static final RegistryObject<MobEffect> WOBBLE = register("wobble", WobbleMobEffect::new);
    public static final RegistryObject<MobEffect> CREEPER_VISION = register("creeper_vision", CreeperVisionMobEffect::new);
    public static final RegistryObject<MobEffect> SPIDER_VISION = register("spider_vision", SpiderVisionMobEffect::new);
    public static final RegistryObject<MobEffect> SCAN_PINCUSHION = register("scan_pincushion", ScanPincushionMobEffect::new);
    public static final RegistryObject<MobEffect> NOTCH = register("notch", NotchMobEffect::new);
    public static final RegistryObject<MobEffect> NADA = register("nada", NadaMobEffect::new);
    public static final RegistryObject<MobEffect> ABSORCION = register("absorcion", AbsorcionMobEffect::new);

    private static RegistryObject<MobEffect> register(String name, java.util.function.Supplier<MobEffect> supplier) {
        return REGISTRY.register(name, supplier);
    }

    private static class ShaderEffect extends MobEffect {
        private static final ResourceLocation ICON =
            new ResourceLocation(ShadersMod.MODID, "textures/mob_effect/logo.png");

        protected ShaderEffect() {
            super(MobEffectCategory.NEUTRAL, 0xFFFFFF);
        }

        @Override
        public void initializeClient(Consumer<IClientMobEffectExtensions> consumer) {
            consumer.accept(new IClientMobEffectExtensions() {
                @Override
                public boolean renderInventoryIcon(MobEffectInstance instance,
                                                   EffectRenderingInventoryScreen<?> screen,
                                                   GuiGraphics guiGraphics,
                                                   int x, int y, int blitOffset) {
                    guiGraphics.blit(ICON, x, y + 7, 0, 0, 18, 18, 1080, 1080);
                    return true;
                }

                @Override
                public boolean renderGuiIcon(MobEffectInstance instance,
                                             Gui gui,
                                             GuiGraphics guiGraphics,
                                             int x, int y, float z, float alpha) {
                    guiGraphics.setColor(1.0F, 1.0F, 1.0F, alpha);
                    guiGraphics.blit(ICON, x, y, 0, 0, 18, 18, 1080, 1080);
                    guiGraphics.setColor(1.0F, 1.0F, 1.0F, 1.0F);
                    return true;
                }
            });
        }
    }

    public static final class FlipMobEffect extends ShaderEffect {}
    public static final class PencilMobEffect extends ShaderEffect {}
    public static final class EndermanVisionMobEffect extends ShaderEffect {}
    public static final class SobelMobEffect extends ShaderEffect {}
    public static final class DesaturateMobEffect extends ShaderEffect {}
    public static final class BlurMobEffect extends ShaderEffect {}
    public static final class WobbleMobEffect extends ShaderEffect {}
    public static final class CreeperVisionMobEffect extends ShaderEffect {}
    public static final class SpiderVisionMobEffect extends ShaderEffect {}
    public static final class ScanPincushionMobEffect extends ShaderEffect {}
    public static final class NotchMobEffect extends ShaderEffect {}
    public static final class NadaMobEffect extends ShaderEffect {}
    public static final class AbsorcionMobEffect extends ShaderEffect {}
}
