Shader "Custom/TexGen/TexGenUnlit"
{
    Properties
    {
		_Tex("Texture", 2D) = "white" {}
		[NoScaleOffset]_TexBump("Texture Normal", 2D) = "bump" {}
		_BlendTex("Blend Texture", 2D) = "white" {}
		[NoScaleOffset]_BlendTexBump("Blend Texture Normal", 2D) = "bump" {}
		_Mask("Blend Mask", 2D) = "white" {}
		_BlendPower("Blend Power", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags 
		{ 
			"Queue" = "Transparent" 
			"RenderType" = "Transparent" 
			"PreviewType" = "Plane" 
		}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "TexGen.cginc"
		#pragma vertex vert

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos		: SV_POSITION;
			float4 packedUV	: TEXCOORD0;
			float2 maskUV	: TEXCOORD1;
		};

		float4		_Tex_ST;
		float4		_BlendTex_ST;
		float4		_Mask_ST;

		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.packedUV.xy = TRANSFORM_TEX(v.uv, _Tex);
			o.packedUV.zw = TRANSFORM_TEX(v.uv, _BlendTex);
			o.maskUV = TRANSFORM_TEX(v.uv, _Mask);
			return o;
		}

		half4 FragAlbedo(v2f i) : SV_Target
		{
			return Mix2(i.packedUV.xy, i.packedUV.zw, i.maskUV);
		}
		float4 FragNormal(v2f i) : SV_Target
		{
			float3 normal = MixNormal(i.packedUV.xy, i.packedUV.zw, i.maskUV);
			return float4(RepackNormal(normal), 1);
		}

		ENDCG

        Pass
        {
            CGPROGRAM
			#pragma fragment FragAlbedo
            ENDCG
        }
		Pass
		{
			CGPROGRAM
			#pragma fragment FragNormal
			ENDCG
		}
    }
}
