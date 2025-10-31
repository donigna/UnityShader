Shader "Custom/Unlit/Shape2D"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BGColor ("Background Color", Color) = (0.5, 0.5, 0.5, 1)
        _BGTex ("Background Texture", 2D) = "white" {}
        _Radius ("Circle Radius", float) = 0.25
        _CircleST("Circle Position", Vector) = (1,1,0,0)
        _BoxST("Box Position", Vector) = (1,1,0,0)
        _FGColor("Foreground Color", Color) = (1,1,1,1)
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
            sampler2D _BGTex;
            float4 _MainTex_ST;
            float4 _BGTex_ST;

            half4 _CircleST;
            half4 _BoxST;
            half4 _Color;
            half4 _BGColor;
            half4 _FGColor;
            half _Radius;

            half CircleSDF(half2 p, half radius) {
                return length(p) - radius;
            }

            half BoxSDF(half2 p, half2 scale) {
                half2 dist = abs(p) - scale;
                return length(max(dist, 0)) + min(max(dist.x, dist.y), 0);
            }

            half SubtractSDF(half sdf, half toSubtract) {
                return max(sdf, -toSubtract);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_BGTex, i.uv * _BGTex_ST.xy + _BGTex_ST.xy) * _BGColor;
                half4 fg = tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
                half2 p = i.uv - 0.5;
                half sdf = CircleSDF(p + _CircleST.zw, _Radius);
                half box = BoxSDF(p + _BoxST.zw, _BoxST.xy);
                sdf = SubtractSDF(sdf, box);

                half littleCircle = CircleSDF(p + _BoxST.zw, length(_BoxST.xy) * 0.25);

                fg *= sdf < littleCircle ? _Color : _FGColor;

                sdf = min(sdf, littleCircle);

                col.rgb = lerp(col.rgb, fg.rgb, sdf < 0? fg.a : 0);
                return col;
            }
            ENDCG
        }
    }
}
