Shader "Custom/SpriteMaskShader"
{
    Properties
    {
        [PreRendererData]_MainTex ("Sprite Texture", 2D) = "white" {}
        [NoScaleOffset]_Mask ("Sprite Mask", 2D) = "transparent" {}
        _R("Red Channel Color", Color) = (1,1,1,1)
        _G("Green Channel Color", Color) = (1,1,1,1)
        _B("Blue Channel Color", Color) = (1,1,1,1)
        _A("Alpha Color", Color) = (1,1,1,1)
        [Enum(Off,0,Front,1,Back,2)] _Cull("Cull", Float) = 2
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "IngnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "true"    
        }
        Cull[_Cull]
        ZTest Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        LOD 100

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
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
                half4 color     : COLOR;
            };

            struct v2f
            {
                float2 uv       : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                half4 color     : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            sampler2D _Mask;
            half4 _R;
            half4 _G;
            half4 _B;
            half4 _A;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                half4 mask = tex2D(_Mask, i.uv);
                half4 mix = half4(0,0,0,1);
                mix = lerp(mix, _R, mask.r);
                mix = lerp(mix, _G, mask.g);
                mix = lerp(mix, _B, mask.b);
                mix = lerp(mix, _A, 1 - mask.a);
                return col * mix;
            }
            ENDCG
        }
    }
}
