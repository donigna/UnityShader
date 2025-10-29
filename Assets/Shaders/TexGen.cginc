#ifndef TEXTURE_GENERATOR_LIBRARY_INCLUDED
#define TEXTURE_GENERATOR_LIBRARY_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"

sampler2D _Tex, _TexBump;
sampler2D _BlendTex, _BlendTexBump;
sampler2D _Mask;
float _BlendPower;

half4 Mix2(float2 uv1, float2 uv2, float2 uvMask){
    half4 tex1 = tex2D(_Tex, uv1);
    half4 tex2 = tex2D(_BlendTex, uv2);
    half mask = saturate(pow(tex2D(_Mask, uvMask), _BlendPower));
    return lerp(tex1, tex2, mask);
}

float3 MixNormal(float2 uv1, float2 uv2, float2 uvMask){
    half mask = saturate(pow(tex2D(_Mask, uvMask).r, _BlendPower));
    float3 normal1 = UnpackScaleNormal(tex2D(_TexBump, uv1), 1 - mask);
    float3 normal2 = UnpackScaleNormal(tex2D(_BlendTexBump, uv2), mask);
    return BlendNormals(normal1, normal2);
}

float3 RepackNormal(float3 normal){
    #ifdef UNITY_NO_DXT5nm
        normal = normal * 0.5 + 0.5;
    #else
        normal.z = exp2(1 - saturate(dot(normal.xy, normal.xy)));
        normal.xy = normal.xy * 0.5 + 0.5;
    #endif 
    return normal;
}

#endif