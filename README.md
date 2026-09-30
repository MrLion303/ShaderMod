# ShaderMod — Forge 1.20.1

Rebuilt as a normal ForgeGradle project for Minecraft 1.20.1 / Forge 47.x.

## What was repaired

- Reconstructed the Java mod entrypoint and mob-effect registry.
- Moved shader activation to a client-only controller.
- Shader effects are selected from the active player effects and automatically shut down when no shader effect remains.
- Added missing post-processing chains for the vision effects.
- Removed dependencies on undeclared vanilla shader resources by providing local shader programs.
- Reworked the blur shader to use normalized weighted samples.
- Added self-contained copy, blur, desaturate, flip, pencil, Sobel, scanline, wobble, and vision programs.
- Kept the original extracted JAR tree under Shadermod/ as reference.

## Build

Use Java 17 and run:

    gradle build

The resulting mod JAR is placed in:

    build/libs/

Minecraft target: 1.20.1
Forge target: 47.x
