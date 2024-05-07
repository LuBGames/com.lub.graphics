#ifndef CUSTOM_BASEFRAGMENT_INCLUDED
#define CUSTOM_BASEFRAGMENT_INCLUDED

#pragma shader_feature SHADOWS_SCREEN
            
#pragma shader_feature USE_FOG
#pragma shader_feature _USE_SPECULAR_NONE _USE_SPECULAR_STANDARD _USE_SPECULAR_TOON
#pragma shader_feature _ _USE_FRESNEL_STANDARD _USE_FRESNEL_REFLECT
#pragma shader_feature USE_SHADOW_COLOR_FOR_SHADING
#pragma shader_feature OFF_SHADESH9 USE_SHADE_SH9

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

    surface = ApplyShading(surface);

    #if defined(_USE_FRESNEL_STANDARD) | defined(_USE_FRESNEL_REFLECT)
    surface = ApplyFresnel(surface);
    #endif

    #ifdef _USE_SPECULAR_STANDARD
    surface = ApplySpecular(surface);
    #elif _USE_SPECULAR_TOON
    surface = ApplySpecularToon(surface);
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