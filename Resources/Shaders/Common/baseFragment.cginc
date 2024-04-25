#ifndef CUSTOM_BASEFRAGMENT_INCLUDED
#define CUSTOM_BASEFRAGMENT_INCLUDED

#include "lub.cginc"

#ifdef USE_FOG
#include "fog.cginc"
#endif

#ifdef USE_BAKED_SHADOWS
sampler2D _BakedShadows;
float4 _BakedShadows_ST;
#endif

fixed3 ComputeBase(Surface surface, FragData fd)
{
    #ifdef SHADOWS_SCREEN
    fixed shadow = SHADOW_ATTENUATION(fd);
    #else
    fixed shadow = 1;
    #endif

    #ifdef USE_BAKED_SHADOWS
    shadow = min(1-tex2D(_BakedShadows, fd.uv * _BakedShadows_ST.xy).r, shadow);
    shadow = max(_LightShadowData.x, shadow);
    #endif

    surface.shadow = shadow;

    #if defined(SHADOWS_SCREEN) || defined(USE_BAKED_SHADOWS)
    surface = ApplyShadows(surface);
    #endif

    #ifdef USE_FRESNEL
    surface = ApplyFresnel(surface);
    #endif

    #ifdef USE_SPECULAR
    surface = ApplySpecular(surface);
    #endif

    surface = ApplyShading(surface);
                    
    #ifdef USE_FOG
    surface = ApplyFog(surface);
    #endif
                    
    return surface.color;
}

#endif