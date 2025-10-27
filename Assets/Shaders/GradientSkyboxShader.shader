Shader "Custom/GradientSkybox"
{
    Properties
    {
        _TopColor("Top Color", Color) = (1, 1, 1, 1)
        _BottomColor("Bottom Color", Color) = (0, 0, 0, 0)
        _Offset("Offset", Range(-1.5, 0.5)) = -0.75
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "Queue"="Background"
            "RenderType"="Background"
            "PreviewType"="Skybox" 
        }

        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // We use half3 because there is no alpha in skybox, we dont need to define their transparency.

            half3 _TopColor;
            half3 _BottomColor;
            half _Offset;
            half _Smoothness;

            fixed4 frag (v2f i) : SV_Target
            {
                half pos = (i.uv.y - _Offset) * 2 - 1;
                half blend = smoothstep(0, _Smoothness * 5, pos);
                half3 mix = lerp(_BottomColor, _TopColor, blend);
                half4 final = half4(mix, 1);
                return final;
            }
            ENDCG
        }
    }
}
