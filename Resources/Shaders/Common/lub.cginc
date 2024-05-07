#ifndef CUSTOM_LUB_INCLUDED
#define CUSTOM_LUB_INCLUDED

#include "UnityLightingCommon.cginc"

#if !defined(OFF_SHADESH9) && defined(USE_SHADE_SH9)
#define USED_SHADE_SH9
#endif

#if defined(USED_SHADE_SH9)
#define COMPUTE_AMBIENT(o) o.ambient = ShadeSH9(half4(o.worldNormal, 1));
#else
#define COMPUTE_AMBIENT(o)
#endif

struct Surface
{
    fixed3 color;
    fixed3 diff;
    half3 position;
    half3 normal;
    fixed shadow;
    fixed fong;
    #if defined(USED_SHADE_SH9)
    fixed3 ambient;
    #endif
};

struct FragData
{
    float4 vertex : SV_POSITION;
    float3 worldNormal : NORMAL;
    float2 uv : TEXCOORD0;
    float2 uv2 : TEXCOORD1;
    fixed3 color : COLOR;
    SHADOW_COORDS(3)
    float3 worldPos : TEXCOORD4;
    #if defined(USED_SHADE_SH9)
    fixed3 ambient : COLOR1;
    #endif
};

fixed4 _SpecularColor;
fixed _SpecularSize;
fixed _SpecBlend;

inline Surface ApplySpecular (Surface surface)
{
    const half3 normLightDir = normalize(_WorldSpaceLightPos0);
    const half3 viewVec = normalize(surface.position - _WorldSpaceCameraPos);
    const half3 refLight = reflect(normLightDir, surface.normal);
    const fixed dotRef = max(0, dot(refLight, viewVec));
    const fixed spec = pow(dotRef, 32.0 * _SpecularSize);

    const fixed blendSpec = _SpecularColor.a * smoothstep(0,1, surface.shadow);

    surface.color += lerp(0, spec, blendSpec) * _SpecularColor.rgb * _LightColor0.rgb;

    return surface;
}

inline Surface ApplySpecularToon (Surface surface)
{
    const half3 normLightDir = normalize(_WorldSpaceLightPos0);
    const half3 viewVec = normalize(surface.position - _WorldSpaceCameraPos);
    const half3 refLight = reflect(normLightDir, surface.normal);
    const fixed dotRef = max(0, dot(refLight, viewVec));

    const fixed blendSpec = _SpecularColor.a * smoothstep(0,1, surface.shadow);
    const fixed specSize = 1.0 - _SpecularSize;
    
    surface.color += smoothstep(specSize - _SpecBlend, specSize + _SpecBlend, dotRef) * blendSpec * _SpecularColor.rgb * _LightColor0.rgb;

    return surface;
}

fixed4 _FresnelColor;
fixed _FresnelBase;

#ifdef _USE_FRESNEL_REFLECT
samplerCUBE _SpecularTexture;
#endif

inline Surface ApplyFresnel(Surface surface)
{
    const fixed3 viewVec = normalize(surface.position - _WorldSpaceCameraPos);

    const fixed dotProduct = dot(viewVec, surface.normal);

    fixed fresnel = smoothstep(-1+_FresnelBase, _FresnelBase, dotProduct);

    fresnel *= _FresnelColor.a;

    #ifdef _USE_FRESNEL_REFLECT
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
    const fixed shadow = lerp(1, surface.shadow, max(surface.fong, 0));
    surface.diff *= lerp(unity_ShadowColor, 1, shadow);
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
    surface.diff = lerp(unity_ShadowColor, _LightColor0, fong);
    #else
    surface.diff = lerp(_ShadingColor, _LightColor0, fong);
    #endif
    return surface;
}

#endif