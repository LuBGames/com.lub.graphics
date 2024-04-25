#ifndef CUSTOM_BASEFRAGMENT_INCLUDED
#define CUSTOM_BASEFRAGMENT_INCLUDED

#include "lub.cginc"

#pragma shader_feature SHADOWS_SCREEN
            
#pragma shader_feature USE_FOG
#pragma shader_feature USE_SPECULAR
#pragma shader_feature USE_FRESNEL
#pragma shader_feature USE_FRESNEL_REFLECT
#pragma shader_feature USE_BAKED_SHADOWS
#pragma shader_feature USE_SHADOW_COLOR_FOR_SHADING
#pragma shader_feature OFF_SHADESH9
#pragma shader_feature USE_SHADE_SH9

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

    surface = ApplyShading(surface);

    #ifdef USE_FRESNEL
    surface = ApplyFresnel(surface);
    #endif

    #ifdef USE_SPECULAR
    surface = ApplySpecular(surface);
    #endif

    #if defined(SHADOWS_SCREEN) || defined(USE_BAKED_SHADOWS)
    surface = ApplyShadows(surface);
    #endif

    #if defined(USED_SHADE_SH9)
    surface.diff += fd.ambient;
    #endif
                    
    #ifdef USE_FOG
    surface = ApplyFog(surface);
    #endif
                    
    return surface.color * surface.diff;
}

#endif