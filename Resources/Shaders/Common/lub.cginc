﻿#ifndef CUSTOM_LUB_INCLUDED
#define CUSTOM_LUB_INCLUDED

#include "UnityLightingCommon.cginc"

struct Surface
{
    half3 color;
    half3 position;
    half3 normal;
    fixed shadow;
    fixed fong;
};

struct FragData
{
    float4 vertex : SV_POSITION;
    float3 worldNormal : NORMAL;
    float2 uv : TEXCOORD0;
    float2 uv2 : TEXCOORD1;
    half3 color : COLOR;
    SHADOW_COORDS(3)
    float3 worldPos : TEXCOORD4;
};

fixed4 _SpecularColor;
fixed _SpecularSize;

inline Surface ApplySpecular (Surface surface)
{
    const fixed3 normLightDir = normalize(_WorldSpaceLightPos0);
    const fixed3 viewVec = normalize(surface.position - _WorldSpaceCameraPos);
    const fixed3 refLight = reflect(normLightDir, surface.normal);
    const fixed dotRef = max(0, dot(refLight, viewVec));
    const fixed spec = pow(dotRef, 32.0 * _SpecularSize);

    const fixed blendSpec = _SpecularColor.a * smoothstep(0,1, surface.shadow);

    surface.color += lerp(0, spec, blendSpec) * _SpecularColor.rgb * _LightColor0.rgb;

    return surface;
}

fixed4 _FresnelColor;
fixed _FresnelBase;

#ifdef USE_FRESNEL_REFLECT
samplerCUBE _SpecularTexture;
#endif

inline Surface ApplyFresnel(Surface surface)
{
    const fixed3 viewVec = normalize(surface.position - _WorldSpaceCameraPos);

    const fixed dotProduct = dot(viewVec, surface.normal);

    fixed fresnel = smoothstep(-1+_FresnelBase, _FresnelBase, dotProduct);

    fresnel *= _FresnelColor.a;

    #ifdef USE_FRESNEL_REFLECT
    const fixed4 refSample = texCUBE(_SpecularTexture, surface.normal);

    fixed3 fresnelComp = lerp(0, refSample.rgb * _FresnelColor.rgb * _LightColor0.rgb, fresnel);
    #else
    fixed3 fresnelComp = fresnel * _FresnelColor.rgb * _LightColor0.rgb;
    #endif

    surface.color += fresnelComp;
    
    return surface;
}

inline Surface ApplyShadows (Surface surface)
{
    fixed shadow = lerp(1, surface.shadow, max(surface.fong, 0));
    surface.color *= lerp(unity_ShadowColor, 1, shadow);
    return surface;
}

fixed _LitTrashHold;
fixed _LitSoftness;
fixed4 _ShadingColor;

inline Surface ApplyShading (Surface surface)
{
    fixed fong = smoothstep(_LitTrashHold - _LitSoftness*2, _LitTrashHold + _LitSoftness, surface.fong);
    fong = saturate(fong);
    #if defined(USE_SHADOW_COLOR_FOR_SHADING)
    surface.color = lerp(unity_ShadowColor * surface.color, surface.color, fong);
    #else
    surface.color = lerp(_ShadingColor * surface.color, surface.color, fong);
    #endif
    return surface;
}

#endif