#ifndef CUSTOM_UTILS_INCLUDED
#define CUSTOM_UTILS_INCLUDED

half _Scale;

inline fixed2 ToRadialCoords(fixed3 coords)
{
    fixed3 normalizedCoords = normalize(coords);
    fixed latitude = acos(normalizedCoords.y);
    fixed longitude = atan2(normalizedCoords.z, normalizedCoords.x);
    fixed2 sphereCoords = fixed2(longitude, latitude) * fixed2(0.5/UNITY_PI, 1.0/UNITY_PI);
    return fixed2(0.5,1.0) - sphereCoords;
}

struct TriplanarUV {
    half2 x, y, z;
};

struct SurfaceParameters
{
    half3 position;
    half3 normal;
};

TriplanarUV GetTriplanarUV (SurfaceParameters parameters) {
    TriplanarUV triUV;
    half3 p = parameters.position * _Scale;
    triUV.x = p.zy;
    triUV.y = p.xz;
    triUV.z = p.xy;
    if (parameters.normal.x < 0) {
        triUV.x.x = -triUV.x.x;
    }
    if (parameters.normal.y < 0) {
        triUV.y.x = -triUV.y.x;
    }
    if (parameters.normal.z >= 0) {
        triUV.z.x = -triUV.z.x;
    }
    return triUV;
}

#endif