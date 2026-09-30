package net.mcreator.shaders;

import net.mcreator.shaders.init.ShadersModMobEffects;
import net.minecraftforge.event.TickEvent;
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
    }
}
