package net.mcreator.shaders;

import net.mcreator.shaders.init.ShadersModMobEffects;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.client.Minecraft;
import com.mojang.blaze3d.systems.RenderSystem;
import net.minecraftforge.client.event.RenderLevelStageEvent;
import org.lwjgl.BufferUtils;
import org.lwjgl.opengl.GL11;
import java.nio.FloatBuffer;
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
        private static boolean menteDarkenRemainder;
        private static float[] previousShaderColor;
        private static final FloatBuffer PREVIOUS_CLEAR_COLOR = BufferUtils.createFloatBuffer(4);

        @SubscribeEvent
        public static void onMenteRenderStage(RenderLevelStageEvent event) {
            RenderLevelStageEvent.Stage stage = event.getStage();

            if (stage == RenderLevelStageEvent.Stage.AFTER_LEVEL) {
                if (menteDarkenRemainder) {
                    float[] color = previousShaderColor;
                    if (color != null && color.length >= 4) {
                        RenderSystem.setShaderColor(color[0], color[1], color[2], color[3]);
                    }
                    previousShaderColor = null;
                    menteDarkenRemainder = false;
                }
                return;
            }

            Minecraft mc = Minecraft.getInstance();
            if (mc.player == null || !mc.player.hasEffect(ShadersModMobEffects.MENTE.get())) {
                return;
            }

            if (stage == RenderLevelStageEvent.Stage.AFTER_CUTOUT_BLOCKS) {
                // Clear only color: the depth buffer stays intact, so entities remain occluded by walls.
                PREVIOUS_CLEAR_COLOR.clear();
                GL11.glGetFloatv(GL11.GL_COLOR_CLEAR_VALUE, PREVIOUS_CLEAR_COLOR);

                RenderSystem.clearColor(0.0F, 0.0F, 0.0F, 1.0F);
                RenderSystem.clear(GL11.GL_COLOR_BUFFER_BIT, Minecraft.ON_OSX);
                RenderSystem.clearColor(
                    PREVIOUS_CLEAR_COLOR.get(0),
                    PREVIOUS_CLEAR_COLOR.get(1),
                    PREVIOUS_CLEAR_COLOR.get(2),
                    PREVIOUS_CLEAR_COLOR.get(3)
                );
            } else if (stage == RenderLevelStageEvent.Stage.AFTER_ENTITIES) {
                // Later world passes (block entities, translucent blocks and particles) should stay black too.
                previousShaderColor = RenderSystem.getShaderColor().clone();
                RenderSystem.setShaderColor(0.0F, 0.0F, 0.0F, 1.0F);
                menteDarkenRemainder = true;
            }
        }

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
                || effect == ShadersModMobEffects.VIAJE_REALIDADES.get()
                || effect == ShadersModMobEffects.MENTE.get();
        }
    }
}
