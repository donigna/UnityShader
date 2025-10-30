Shader "Custom/SurfaceScanline"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
       [HDR] _ScanColor ("Scan Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Speed("Speed", float) = 1
        _Height("Height", Range(144, 1080)) = 720
        _RimPower("Rim Power", Range(0, 2)) = 1
        _RimSoftness("Rim Softness", Range(0, 1)) = 0.1
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

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        half3 _ScanColor;
        half _Speed;
        half _Height;
        half _RimPower;
        half _RimSoftness;


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half3 mainTex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = mainTex;
		    half scroll = sin(_Time.y * _Speed);
		    float scanline = sin((IN.screenPos.y / IN.screenPos.w - scroll) * _Height) * 0.5 + 0.5;
		    mainTex = lerp(mainTex, mainTex * _Color.rgb, _Color.a * scanline);
            half rim = smoothstep(0.5, max(0.5, _RimSoftness), 1 - pow(dot(o.Normal, IN.viewDir), _RimPower));
            o.Emission = _ScanColor * scanline * mainTex.rgb * rim;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
