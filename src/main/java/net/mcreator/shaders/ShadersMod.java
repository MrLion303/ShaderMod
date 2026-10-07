package net.mcreator.shaders;

import net.mcreator.shaders.init.ShadersModMobEffects;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.event.entity.living.MobEffectEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.common.Mod.EventBusSubscriber.Bus;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.api.distmarker.Dist;

@Mod(ShadersMod.MODID)
public final class ShadersMod {
    public static final String MODID = "shaders";

    public ShadersMod() {
        ShadersModMobEffects.REGISTRY.register(FMLJavaModLoadingContext.get().getModEventBus());
    }

    @Mod.EventBusSubscriber(modid = MODID, value = Dist.CLIENT, bus = Bus.FORGE)
    public static final class ClientEvents {
        @SubscribeEvent
        public static void onClientTick(TickEvent.ClientTickEvent event) {
            if (event.phase == TickEvent.Phase.END) {
                ShaderController.tick();
            }
        }

        @SubscribeEvent
        public static void onShaderEffectAdded(MobEffectEvent.Added event) {
            MobEffectInstance instance = event.getEffectInstance();
            if (!instance.isVisible() || !isShaderEffect(instance.getEffect())) {
                return;
            }

            MobEffectInstance withoutParticles = new MobEffectInstance(
                instance.getEffect(),
                instance.getDuration(),
                instance.getAmplifier(),
                instance.isAmbient(),
                false,
                instance.showIcon()
            );

            event.getEntity().addEffect(withoutParticles);
        }

        private static boolean isShaderEffect(MobEffect effect) {
            return effect == ShadersModMobEffects.FXAA.get()
                || effect == ShadersModMobEffects.ART.get()
                || effect == ShadersModMobEffects.BUMPY.get()
                || effect == ShadersModMobEffects.BLOBS2.get()
                || effect == ShadersModMobEffects.COLOR_CONVOLVE.get()
                || effect == ShadersModMobEffects.DECONVERGE.get()
                || effect == ShadersModMobEffects.NTSC.get()
                || effect == ShadersModMobEffects.OUTLINE.get()
                || effect == ShadersModMobEffects.PHOSPHOR.get()
                || effect == ShadersModMobEffects.BITS.get()
                || effect == ShadersModMobEffects.GREEN.get()
                || effect == ShadersModMobEffects.BLOBS.get()
                || effect == ShadersModMobEffects.ANTIALIAS.get()
                || effect == ShadersModMobEffects.FLIP.get()
                || effect == ShadersModMobEffects.PENCIL.get()
                || effect == ShadersModMobEffects.ENDER_MAN_VISION.get()
                || effect == ShadersModMobEffects.SOBEL.get()
                || effect == ShadersModMobEffects.DESATURATE.get()
                || effect == ShadersModMobEffects.BLUR.get()
                || effect == ShadersModMobEffects.WOBBLE.get()
                || effect == ShadersModMobEffects.CREEPER_VISION.get()
                || effect == ShadersModMobEffects.SPIDER_VISION.get()
                || effect == ShadersModMobEffects.SCAN_PINCUSHION.get()
                || effect == ShadersModMobEffects.NOTCH.get()
                || effect == ShadersModMobEffects.NADA.get()
                || effect == ShadersModMobEffects.ABSORCION.get()
                || effect == ShadersModMobEffects.GREEN_GLOW.get()
                || effect == ShadersModMobEffects.RED_GLOW.get()
                || effect == ShadersModMobEffects.RED_FILTER.get()
                || effect == ShadersModMobEffects.RUGIDO.get()
                || effect == ShadersModMobEffects.GLITCH.get()
                || effect == ShadersModMobEffects.TERREMOTO.get()
                || effect == ShadersModMobEffects.VIAJE_REALIDADES.get();
        }
    }
}
