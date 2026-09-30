#version 120
attribute vec4 Position;
uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;
uniform vec2 ScreenSize;
varying vec2 texCoord;
void main(){gl_Position=ProjMat*vec4(Position.xy,0.0,1.0);texCoord=Position.xy/OutSize;texCoord.x=1.0-texCoord.x;texCoord.y=1.0-texCoord.y;}