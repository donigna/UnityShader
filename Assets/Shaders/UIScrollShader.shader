Shader "Custom/UI/UIScroll"
{
    Properties
    {
        [PreRendererData]_MainTex ("Texture", 2D) = "white" {}
        _PatterTex("Pattern Tex", 2D) = "white" {}
        _SpeedX("Speed X", Range(-1,1)) = 0
        _SpeedY("Speed Y", Range(-1,1)) = 0
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"    
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas" = "true"
        }
        Blend SrcAlpha OneMinusSrcAlpha
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
                half4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
                half2 patternUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _PatterTex;
            float4 _PatterTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                o.patternUV = TRANSFORM_TEX(v.uv, _PatterTex);
                return o;
            }

            half _SpeedX;
            half _SpeedY;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 offset = frac(_Time.y * float2(_SpeedX, _SpeedY));
                half4 pattern = tex2D(_PatterTex, i.patternUV + offset);
                return col * i.color * pattern;
            }
            ENDCG
        }
    }
}
