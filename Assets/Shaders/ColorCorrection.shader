Shader "Custom/Unlit/ColorCorrection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Saturation("Saturation", Float) = 1
        _Brightness("Brightness", Float) = 1
        _Contrast("Contrast", Float) = 1
        [Header(Red Channel)]
        _RRed("Red", Range(-1, 2)) = 1
        _RGreen("Green", Range(-1, 2)) = 0
        _RBlue("Blue", Range(-1, 2)) = 0
        [Header(Green Channel)]
        _GRed("Red", Range(-1, 2)) = 0
        _GGreen("Green", Range(-1, 2)) = 1
        _GBlue("Blue", Range(-1, 2)) = 0
        [Header(Blue Channel)]
        _BRed("Red", Range(-1, 2)) = 0
        _BGreen("Green", Range(-1, 2)) = 0
        _BBlue("Blue", Range(-1, 2)) = 1
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Saturation;
            half _Brightness;
            half _Contrast;
            half _RRed;
            half _RGreen;
            half _RBlue;
            half _GRed;
            half _GGreen;
            half _GBlue;
            half _BRed;
            half _BGreen;
            half _BBlue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = half3(
                dot(col.rgb, half3(_RRed,_RGreen,_RBlue)),
                dot(col.rgb, half3(_GRed,_GGreen,_GBlue)),
                dot(col.rgb, half3(_BRed,_BGreen,_BBlue))
                );
                half luminosity = dot(col.rgb, unity_ColorSpaceLuminance.rgb);
                col.rgb = (col - luminosity) * _Saturation + luminosity;
                col.rgb *= _Brightness;
                col.rgb = (col.rgb - unity_ColorSpaceGrey.rgb) * _Contrast + unity_ColorSpaceGrey.rgb;
                return col;
            }
            ENDCG
        }
    }
}
