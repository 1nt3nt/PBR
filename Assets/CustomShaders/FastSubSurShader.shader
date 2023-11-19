Shader "Custom/FastSubSurShader" {
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Normal ("Normal", 2D) = "bump" {}
        _Color ("Color",Color) = (1,1,1,1)
        _Specular ("Specular Color",Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [PowerSlider(3.0)]_Glossiness("Smoothness",Range(1, 200)) = 10
        // texture part
        [Main(sss,_,3)] _group ("SubsurfaceScattering", float) = 1
        [Tex(sss)]_ThicknessTex ("Thickness Tex", 2D) = "white" {}
        [Sub(sss)]_ThicknessPower ("ThicknessPower", Range(0,10)) = 1
        // scatter part
        [Sub(sss)][HDR]_ScatterColor ("Scatter Color", Color) = (1,1,1,1)
        [Sub(sss)]_WrapValue ("WrapValue", Range(0,1)) = 0.0
        [Title(sss, Back SSS Factor)]
        [Sub(sss)]_DistortionBack ("Back Distortion", Range(0,1)) = 1.0
        [Sub(sss)]_PowerBack ("Back Power", Range(0,10)) = 1.0
        [Sub(sss)]_ScaleBack ("Back Scale", Range(0,1)) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False"}
        LOD 300

        Pass{
            Tags { "LightMode"="Forwardbase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardUtils.cginc"
            #include "UnityStandardBRDF.cginc"

            sampler2D _MainTex,_ThicknessTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            half _Glossiness;
            half _Metallic;
            float3 _Specular;
            
            float4 _ScatterColor;
            float _DistortionBack;
            float _PowerBack;
            float _ScaleBack;
            
            float _ThicknessPower;
            float _WrapValue;
            float _ScatterWidth;

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
                //SurfaceOutputStandard o;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
                float3 viewDir: TEXCOORD3;
                float3 lightDir: TEXCOORD4;
            };

            v2f vert(appdata v)
            {
                v2f o; //output
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                o.normalDir = UnityObjectToWorldNormal (v.normal);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.lightDir = UnityWorldSpaceLightDir(o.worldPos);
                return o;
            };
//---------------------------------- Subsurface Scattering -----------------------------            
            // calculate SSS
            inline float SubsurfaceScattering (float3 V, float3 L, float3 N, float distortion,float power,float scale)
            {
                float3 H = L + N * distortion;
                float I = pow(saturate(dot(V, -H)), power) * scale;
                return I;
            }


//------------------------------------ fragment shader ---------------------
            fixed4 frag(v2f i): SV_TARGET
            {
                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 lightColor = _LightColor0.rgb;
                float3 N = normalize(i.normalDir);
                float3 V = normalize(i.viewDir);
                float3 L = normalize(i.lightDir);
                float NdotL = saturate(dot(N, L));
                float3 H = normalize(L + V); //halfvector
                float NdotH = saturate(dot(N, H));
                float NdotV = saturate(dot(N, V));
                float LdotH = saturate(dot(L, H));
                float specularTint;
                half oneMinusReflectivity = OneMinusReflectivityFromMetallic(_Metallic);
                //half outputAlpha;
                //fixed3 al = DiffuseAndSpecularFromMetallic(albedo.rgb, _Metallic, _SpecColor, oneMinusReflectivity);
                //al = PreMultiplyAlpha(albedo.rgb, albedo.a, oneMinusReflectivity,outputAlpha);
                //albedo.a = outputAlpha;
                //albedo.rgb = al;
                albedo.rgb *= oneMinusReflectivity;
                albedo.a = -oneMinusReflectivity;
                float thickness = tex2D(_ThicknessTex, i.uv).r * _ThicknessPower;
                // ----------------------------- SSS -----------------------------
                float3 sss = SubsurfaceScattering(V,L,N,_DistortionBack,_PowerBack,_ScaleBack) * lightColor * _ScatterColor * thickness;

                // ----------------------------- Warp Lighting -----------------------------
                float wrap_diffuse = max(0, (NdotL + _WrapValue) / (1 + _WrapValue));
                
                // ----------------------------- Diffuse -----------------------------
                float3 diffuse = lightColor * wrap_diffuse  * albedo;

                // -------------------------- Blinn - Phong -----------------------------
                fixed3 specular = lightColor * pow(max(0,NdotH),_Glossiness) * _Specular;
                //fixed3 specular = specularTint * lightColor * pow(DotClamped(H,N), _Glossiness);

                float3 resCol = diffuse + sss + specular;

                return fixed4(resCol,1);
                
            };

            ENDCG
        }
      
    }
    FallBack "Diffuse"
}