Shader "Custom/BasicUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
        CGINCLUDE

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            
        ENDCG
    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "Deferred"}
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma exclude_renderers nomrt
            #pragma multi_compile_prepassfinal

            void frag (v2f i,
                out half4 gBuffer0 : SV_Target0,
                out half4 gBuffer1 : SV_Target1,
                out half4 gBuffer2 : SV_Target2,
                out half4 gBuffer3 : SV_Target3)
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                gBuffer0 = 0;
                gBuffer1 = 0;
                gBuffer2 = 0;
                gBuffer3 = col;
            }
            ENDCG
        }
    }
}
