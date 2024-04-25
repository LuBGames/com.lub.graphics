#ifndef CUSTOM_FOGTRANSPARENT_INCLUDED
#define CUSTOM_FOGTRANSPARENT_INCLUDED

#include "skybox.cginc"

fixed3 FogOffset;
fixed3 FogAxis;
fixed FogScale;

fixed GetFog (fixed3 pos)
{
    fixed3 napr = pos * FogAxis;
    fixed fx = -(napr.x + napr.y + napr.z);

    return clamp((fx - FogOffset) * FogScale, 0.0, 1.0);
}

inline fixed3 ApplyFog (fixed3 colorIn, half3 wp)
{
    const fixed3 fogCoord = normalize(wp - _WorldSpaceCameraPos);
    return lerp(colorIn, GetSkyboxColor(fogCoord), GetFog(wp));
}

#endif