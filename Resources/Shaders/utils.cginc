#ifndef CUSTOM_UTILS_INCLUDED
#define CUSTOM_UTILS_INCLUDED

inline fixed2 ToRadialCoords(fixed3 coords)
{
    fixed3 normalizedCoords = normalize(coords);
    fixed latitude = acos(normalizedCoords.y);
    fixed longitude = atan2(normalizedCoords.z, normalizedCoords.x);
    fixed2 sphereCoords = fixed2(longitude, latitude) * fixed2(0.5/UNITY_PI, 1.0/UNITY_PI);
    return fixed2(0.5,1.0) - sphereCoords;
}

#endif