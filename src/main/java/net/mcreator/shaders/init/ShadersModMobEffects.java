package net.mcreator.shaders.init;

import net.mcreator.shaders.ShadersMod;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectCategory;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

public final class ShadersModMobEffects {
    public static final DeferredRegister<MobEffect> REGISTRY =
        DeferredRegister.create(ForgeRegistries.MOB_EFFECTS, ShadersMod.MODID);

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

    private static RegistryObject<MobEffect> register(String name, java.util.function.Supplier<MobEffect> supplier) {
        return REGISTRY.register(name, supplier);
    }

    private static class ShaderEffect extends MobEffect {
        protected ShaderEffect() {
            super(MobEffectCategory.NEUTRAL, 0xFFFFFF);
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
}
