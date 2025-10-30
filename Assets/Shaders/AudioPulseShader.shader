Shader "Custom/AudioPulseShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _BGColor ("Background Color", Color) = (0, 0, 0, 1)
        _Radius ("Radius", Range(0,1)) = 0.05
        _Smooth ("Smooth", Range(0.001, 0.1)) = 0.005
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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

            half _Radius, _Smooth;
            half4 _Color, _BGColor;
            float _GlobalRMS;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = distance(i.uv, half2(0.5,0.5));
                half blend = smoothstep(dist - _Smooth, dist + _Smooth, _Radius + _GlobalRMS);
                return lerp(_BGColor, _Color, blend);
            }
            ENDCG
        }
    }
}
