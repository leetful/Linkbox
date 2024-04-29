Shader "Custom/FrostedGlass"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _BlurAmount ("Blur Amount", Range(0, 20)) = 5
        _FrostIntensity ("Frost Intensity", Range(0, 1)) = 0.5
        _FrostColor ("Frost Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass { "_BackgroundTexture" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BackgroundTexture;
            float _BlurAmount;
            float _FrostIntensity;
            fixed4 _FrostColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 bgColor = tex2Dproj(_BackgroundTexture, i.grabPos);
                float4 mainColor = tex2D(_MainTex, i.uv);
                float alpha = mainColor.a;

                if (alpha < 1)
                {
                    float4 sum = float4(0, 0, 0, 0);
                    float2 offset = float2(_BlurAmount / _ScreenParams.x, _BlurAmount / _ScreenParams.y);

                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-2, -2, 0, 0) * offset) * 0.0625;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-1, -2, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(0, -2, 0, 0) * offset) * 0.0625;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(1, -2, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(2, -2, 0, 0) * offset) * 0.0625;

                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-2, -1, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-1, -1, 0, 0) * offset) * 0.25;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(0, -1, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(1, -1, 0, 0) * offset) * 0.25;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(2, -1, 0, 0) * offset) * 0.125;

                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-2, 0, 0, 0) * offset) * 0.0625;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-1, 0, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(0, 0, 0, 0) * offset) * 0.0625;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(1, 0, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(2, 0, 0, 0) * offset) * 0.0625;

                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-2, 1, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-1, 1, 0, 0) * offset) * 0.25;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(0, 1, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(1, 1, 0, 0) * offset) * 0.25;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(2, 1, 0, 0) * offset) * 0.125;

                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-2, 2, 0, 0) * offset) * 0.0625;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(-1, 2, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(0, 2, 0, 0) * offset) * 0.0625;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(1, 2, 0, 0) * offset) * 0.125;
                    sum += tex2Dproj(_BackgroundTexture, i.grabPos + float4(2, 2, 0, 0) * offset) * 0.0625;

                    bgColor = sum;
                }

                float4 finalColor = lerp(bgColor, _FrostColor, _FrostIntensity);
                finalColor.a = alpha;

                return finalColor;
            }
            ENDCG
        }
    }
}