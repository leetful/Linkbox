Shader "Custom/SubtlePearlescentShader" {
    Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color1 ("Color 1", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (1,1,1,1)
        _Color3 ("Color 3", Color) = (1,1,1,1)
        _Intensity ("Intensity", Range(0,1)) = 0.3
        _Glossiness ("Smoothness", Range(0,1)) = 0.7
        _Metallic ("Metallic", Range(0,1)) = 0.2
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color1;
        fixed4 _Color2;
        fixed4 _Color3;
        half _Intensity;
        half _Glossiness;
        half _Metallic;

        struct Input {
            float2 uv_MainTex;
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

            // Calculate the dot product between the view direction and the surface normal
            float ndotv = saturate(dot(IN.viewDir, o.Normal));

            // Calculate the iridescent effect based on the view direction with a smoother falloff
            float iridescence = pow(1 - ndotv, _Intensity * 5);

            // Sample the main texture and extract its dominant colors
            fixed4 texColor1 = c;
            fixed4 texColor2 = c.gbra;
            fixed4 texColor3 = c.brga;

            // Blend the iridescent colors with the texture colors based on the iridescence factor
            fixed3 blendedColor1 = lerp(texColor1.rgb, _Color1.rgb, iridescence * 0.5);
            fixed3 blendedColor2 = lerp(texColor2.rgb, _Color2.rgb, iridescence * 0.3);
            fixed3 blendedColor3 = lerp(texColor3.rgb, _Color3.rgb, iridescence * 0.2);

            // Combine the blended colors with the main texture color
            fixed3 finalColor = (blendedColor1 + blendedColor2 + blendedColor3) * 0.5 + c.rgb * 0.5;

            o.Albedo = finalColor;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}