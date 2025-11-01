Shader "Custom/ToonShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Float) = 1
        _EmissionMap("Emission Tex", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
        _RimColor("Rim Color", Color) = (0,0,0,1)
        _RimPower("Rim Fill", Range(0, 2)) = 0.1
        _RimSmooth("Rim Smooth", Range(0.5, 1)) = 1
        _Thresh("Shadow Threshold", Range(0, 2)) = 1
        _ShadowSmooth("Shadow Smoothness", Range(0.5, 1)) = 0.6
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        _Cutout("Cutout", Range(0,1)) = 0.5
        [Space]
        [Header(Dissolve)]
        [Toggle(_AUTO_DISSOLVE)] _AutoDissolve("Auto Dissolve", float) = 0
        _DissolveTex("Dissolve Tex", 2D) = "white" {}
        _DissolveAmount("Dissolve Amount", Range(0,1)) = 0.0
        _DissolveScale("Dissolve Scale", Float) = 0
        _DissolveLine("Dissolve Line", Range(0,0.2)) = 0.0
        [HDR]_DissolveLineColor("Dissolve Line Color", Color) = (0,0,0,1)
        [Space]
        [Header(Gloss)]
        _SpecMap("Specular Map", 2D) = "white" {}
        _Gloss("Glossiness", Range(0, 20)) = 0
        _GlossSmothness("Gloss Smothness", Range(0, 2)) = 0
        [HDR]_GlossColor("Gloss Color", Color) = (0,0,0,1)
        [Space]
        [Header(Outline)]
        _Outline("Outline Width", Range(0, 0.025)) = .000
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="Transparent" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha

        Cull Front
        CGPROGRAM
        #include "ToonShader.cginc"

        #pragma surface surf Toon vertex:OutlineVert

        #pragma target 3.0

        float _Outline;

        void OutlineVert(inout appdata_full v)
        {
        v.vertex.xyz += v.normal * _Outline;
        }

        struct Input{
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o){
            if(_Outline <= 0.0001)
                clip(-1);
            o.Emission = Black;
        }
        ENDCG
        

        Cull Back 
        CGPROGRAM
        #include "ToonShader.cginc"

        #pragma surface surf Toon
        #pragma shader_feature_local _AUTO_DISSOLVE

        half _Thresh;
        half _ShadowSmooth;
        half3 _ShadowColor;
        half _Gloss;
        half _GlossSmothness;
        half3 _GlossColor;
        
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _EmissionMap;
        sampler2D _SpecMap;
        
        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        fixed4 _Color;
        float _NormalStrength;
        half4 _EmissionColor;
        half4 _RimColor;
        half _RimPower;
        half _RimSmooth;
        half _Cutout;
        sampler2D _DissolveTex;
        half _DissolveAmount;
        half _DissolveScale;
        half _DissolveLine;
        half3 _DissolveLineColor;
        half _AutoDissolve;
        void surf (Input IN, inout SurfaceOutput o)
        {
            InitLightingToon(_Thresh, _ShadowSmooth, _ShadowColor, _Gloss, _GlossSmothness, _GlossColor);
            half4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _Color;
            o.Alpha = tex.a;
            clip(tex.a - _Cutout);
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;
            half4 emissionMap = tex2D(_EmissionMap, IN.uv_MainTex);
            o.Emission += emissionMap * _EmissionColor;
            half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            o.Emission += _RimColor * smoothstep(0.5, max(0.5, _RimSmooth), d);
            // Dissolve
            half4 noise = tex2D(_DissolveTex, IN.uv_MainTex * _DissolveScale);
            half dissolve = _DissolveAmount;
            if(_AutoDissolve == 1)
                dissolve = frac(sin(_Time.y * 1) * 0.5 + 0.5);
            clip(noise.r - dissolve);
            o.Emission += step(noise.r, dissolve + _DissolveLine) *step(0.001, dissolve) * _DissolveLineColor;
            o.Specular = tex2D(_SpecMap, IN.uv_MainTex);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
