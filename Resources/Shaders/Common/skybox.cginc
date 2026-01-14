#ifndef CUSTOM_SKYBOX_INCLUDED
#define CUSTOM_COMMON_INCLUDED

#pragma shader_feature GRADIENT_SKYBOX

#ifdef GRADIENT_SKYBOX
fixed3 TopColorSkybox;
fixed3 BottomColorSkybox;
fixed ExpSkybox;
fixed3 UpSkybox;

fixed3 GetSkyboxColor(half3 coord)
{
    fixed3 up = normalize(UpSkybox);
    fixed d = dot(coord, up);
    return lerp(BottomColorSkybox, TopColorSkybox, sign(d) * pow(abs(d), ExpSkybox) * 0.5 + 0.5);    
}
#else

samplerCUBE _Skybox;

fixed3 GetSkyboxColor(half3 coord)
{
    fixed3 col = texCUBE(_Skybox, coord);
    return col;
}
#endif

#endif