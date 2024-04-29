Shader "Custom/RawImageBlurVR"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurAmount ("Blur Amount", Range(0, 20)) = 5
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurAmount;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float4 sum = float4(0, 0, 0, 0);
                float2 offset = float2(_BlurAmount / _ScreenParams.x, _BlurAmount / _ScreenParams.y);

                sum += tex2D(_MainTex, i.uv + float2(-2, -2) * offset) * 0.0625;
                sum += tex2D(_MainTex, i.uv + float2(-1, -2) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(0, -2) * offset) * 0.0625;
                sum += tex2D(_MainTex, i.uv + float2(1, -2) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(2, -2) * offset) * 0.0625;

                sum += tex2D(_MainTex, i.uv + float2(-2, -1) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(-1, -1) * offset) * 0.25;
                sum += tex2D(_MainTex, i.uv + float2(0, -1) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(1, -1) * offset) * 0.25;
                sum += tex2D(_MainTex, i.uv + float2(2, -1) * offset) * 0.125;

                sum += tex2D(_MainTex, i.uv + float2(-2, 0) * offset) * 0.0625;
                sum += tex2D(_MainTex, i.uv + float2(-1, 0) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(0, 0) * offset) * 0.0625;
                sum += tex2D(_MainTex, i.uv + float2(1, 0) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(2, 0) * offset) * 0.0625;

                sum += tex2D(_MainTex, i.uv + float2(-2, 1) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(-1, 1) * offset) * 0.25;
                sum += tex2D(_MainTex, i.uv + float2(0, 1) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(1, 1) * offset) * 0.25;
                sum += tex2D(_MainTex, i.uv + float2(2, 1) * offset) * 0.125;

                sum += tex2D(_MainTex, i.uv + float2(-2, 2) * offset) * 0.0625;
                sum += tex2D(_MainTex, i.uv + float2(-1, 2) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(0, 2) * offset) * 0.0625;
                sum += tex2D(_MainTex, i.uv + float2(1, 2) * offset) * 0.125;
                sum += tex2D(_MainTex, i.uv + float2(2, 2) * offset) * 0.0625;

                return sum;
            }
            ENDCG
        }
    }
}