#ifndef CUSTOM_FOGTRANSPARENT_INCLUDED
#define CUSTOM_FOGTRANSPARENT_INCLUDED

#include "skybox.cginc"

half3 FogOffset;
half3 FogAxis;
fixed FogScale;

fixed GetFog (fixed3 pos)
{
    fixed3 napr = (pos - FogOffset) * FogAxis;
    fixed fx = -(napr.x + napr.y + napr.z);

    return clamp(fx * FogScale, 0.0, 1.0);
}

inline fixed3 ApplyFog (fixed3 colorIn, half3 wp)
{
    const fixed3 fogCoord = normalize(wp - _WorldSpaceCameraPos);
    return lerp(colorIn, GetSkyboxColor(fogCoord), GetFog(wp));
}

#endif