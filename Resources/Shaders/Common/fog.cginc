#ifndef CUSTOM_FOG_INCLUDED
#define CUSTOM_FOG_INCLUDED

#include "skybox.cginc"
#include "lub.cginc"

fixed3 FogOffset;
fixed3 FogAxis;
fixed FogScale;

fixed GetFog (fixed3 pos)
{
    fixed3 napr = pos * FogAxis;
    fixed fx = -(napr.x + napr.y + napr.z);

    return clamp((fx - FogOffset) * FogScale, 0.0, 1.0);
}

inline Surface ApplyFog (Surface surface)
{
    const fixed3 fogCoord = normalize(surface.position - _WorldSpaceCameraPos);
    surface.color = lerp(surface.color, GetSkyboxColor(fogCoord), GetFog(surface.position));
    return surface;
}

#endif