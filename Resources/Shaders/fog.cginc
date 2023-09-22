#ifndef CUSTOM_FOG_INCLUDED
#define CUSTOM_FOG_INCLUDED

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

inline fixed3 ApplyFog (fixed3 color, v2f i)
{
    const fixed3 fogCoord = normalize(i.worldPos - _WorldSpaceCameraPos);
    return lerp(color, GetSkyboxColor(fogCoord), GetFog(i.worldPos));
}

#endif