Shader "Custom/Unlit/AlphaDraw"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _Falloff("Falloff", Range(0, 0.1)) = 0
        _Speed("Speed", Range(0, 2)) = 1
        [Toggle(_MANUAL)]
        _Manual("Manual line progress", float) = 0
        _Line ("Line", Range(0,1)) = 0
    }
    SubShader
    {
        Tags {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
                "PreviewType" = "Plane"
        }

        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _MANUAL

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            half _Line;
            half _Falloff;
            half _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 mask = tex2D(_MainTex, i.uv);
                #ifdef _MANUAL
                    half lineTime = _Line;
                #else
                    half lineTime = frac(sin(_Time.y * _Speed) * 0.5 + 0.5);
                #endif
                half progress = saturate(smoothstep(mask.r - _Falloff, mask.r + _Falloff, lineTime));
                half4 col = lerp(0, _Color, progress * mask.a);
                return col;
            }
            ENDCG
        }
    }
}
