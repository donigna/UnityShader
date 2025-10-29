Shader "Custom/TexGen/TexGenLit"
{
    Properties
    {
        _Tex ("Texture", 2D) = "white" {}
        _TexBump ("Texture Normal", 2D) = "bump" {}
        _BlendTex ("Blend Tex", 2D) = "white" {}
        _BlendTexBump ("Blend Tex Normal", 2D) = "bump" {}
        _Mask ("Mask", 2D) = "white" {}
        _BlendPower("Blend Power", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "TexGen.cginc"
        
        struct Input
        {
            float2 uv_Tex;
            float2 uv_BlendTex;
            float2 uv_Mask;
        };
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half4 mix = Mix2(IN.uv_Tex, IN.uv_BlendTex, IN.uv_Mask);
            o.Albedo = mix.rgb;
            o.Alpha = mix.a;
            o.Normal = MixNormal(IN.uv_Tex, IN.uv_BlendTex, IN.uv_Mask);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
