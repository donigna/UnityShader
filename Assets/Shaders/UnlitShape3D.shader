Shader "Custom/Lit/Shape3D"
{
    Properties
    {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BGColor ("Background Color", Color) = (0.5, 0.5, 0.5, 1)
        [Header(Shapes)]
        _BGTex ("Background Texture", 2D) = "white" {}
        _Radius ("Circle Radius", float) = 0.25
        _SpherePos ("Sphere Pos", Vector) = (0, 0, 2, 0)
        _Radius2 ("Radius 2", float) = 0.15
        _SpherePos2 ("Sphere Pos 2", Vector) = (0, 0, 1.5, 0)
        _Color2 ("Color 2", Color) = (1, 0.5, 1, 1)
        _BoxScale ("Box Scale", Vector) = (0.5, 0.5, 0.5, 0)
        _BoxPos ("Box Position", Vector) = (0, 0, 0, 0)
        [Header(Raymarch)]
        _MaxDist("Max Dist", float) = 100
        [IntRange]
        _Steps("Steps", Range(5, 250)) = 100
        _CamPos("Cam Position", Vector) = (0, 0, -1, 0)
        _ShadowColor ("Shadow Color", Color) = (0.1, 0.1, 0.1, 1)

    } 
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "Preview"="Plane" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            #define EPSILON 2.4414e-4
            
            sampler2D _MainTex;
            sampler2D _BGTex;
            float4 _MainTex_ST;
            float4 _BGTex_ST;

            half4 _Color;
            half4 _BGColor;
            half _Radius;
            half3 _ShadowColor;
            half3 _BoxScale;
            half3 _BoxPos;
            half3 _SpherePos;
            float4 _CamPos;
            half _MaxDist;
            int _Steps;
            half _Radius2;
            half3 _SpherePos2;
            half3 _Color2;

            float SphereSDF(float3 p, half radius) {
                return length(p) - radius;
            }

            float BoxSDF(float3 p, float3 scale) {
                float3 dist = abs(p) - scale;
                return length(max(dist,0)) + min(max(dist.x, max(dist.y, dist.z)), 0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2 SphereUV(float3 n)
            {
                const float2 invAtan = float2(0.1591, 0.3183);
                float2 uv = float2(atan2(n.z, n.x), asin(n.y));
                return uv * invAtan + 0.5;
            }

            float SceneSDF(float3 p, out half3 color) {
                float sdf = SphereSDF(p - _SpherePos, _Radius);
                float box = BoxSDF(p - _BoxPos, _BoxScale);
                sdf = max(sdf,-box);
                float littleSphere = SphereSDF(p - _SpherePos2, _Radius2);
                color = sdf < littleSphere? _Color : _Color2;
                sdf = min(sdf, littleSphere);
                return sdf;
            }

            float3 GetNormal(float3 p) {
                half3 c = 0;
                float distance = SceneSDF(p, c);
                float3 normal = distance - float3(
                SceneSDF(p - half3(EPSILON, 0, 0), c),
                SceneSDF(p - half3(0, EPSILON, 0), c),
                SceneSDF(p - half3(0, 0, EPSILON), c));
                return normalize(normal);
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_BGTex, i.uv * _BGTex_ST.xy + _BGTex_ST.zw) * _BGColor;
                float3 p = _CamPos.xyz;
                half3 dir = normalize(float3(i.uv - 0.5, 1));

                half distance = 0;
                half3 c;
                for (int i = 0; i < _Steps; i++) {
                    half d = SceneSDF(p + dir * distance, c);
                    if (distance >= _MaxDist || d < EPSILON) break;
                    distance += d;
                }
                if (distance < _MaxDist) {
                    p += dir * distance;
                    float3 normal = GetNormal(p);
                    col = tex2D(_MainTex, SphereUV(normal) * _MainTex_ST.xy + _MainTex_ST.zw);
                    float3 lightDir = normalize(_WorldSpaceLightPos0 - p);
                    half d = pow(dot(normal, lightDir) * 0.5 + 0.5, 3);
                    col.rgb *= lerp(_ShadowColor, c, d);
                }
                return col;
            }
            ENDCG
        }
    }
}
