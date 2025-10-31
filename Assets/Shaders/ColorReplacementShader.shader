Shader "Hidden/ColorReplacementShader"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/Colors.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    half3 _ColorFind;
    half3 _ColorReplace;
    half _Threshold;
    half _Mix;
    half _Smooth;

    half4 Frag(VaryingsDefault i) : SV_Target {
        float2 uv = UnityStereoTransformScreenSpaceTex(i.texcoord.xy);
        half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
        half diff = length(color.rgb - _ColorFind);
        diff = saturate(smoothstep(_Threshold - _Smooth, _Threshold + _Smooth, diff));

        half3 colHSV = RgbToHsv(color.rgb);
        half3 replaceHSV = RgbToHsv(_ColorReplace);
        half3 newColor = HsvToRgb(half3(replaceHSV.r, colHSV.g, colHSV.b));

        half3 updated = lerp(newColor, color.rgb, diff);
        color.rgb = lerp(color.rgb, updated, _Mix);
        return color;
    }
    ENDHLSL

    SubShader{
        Cull Off ZWrite Off ZTest Always

        Pass {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment Frag
            ENDHLSL
        }
    }
}
