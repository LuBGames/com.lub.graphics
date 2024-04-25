Shader "LuB/NewToonTransparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Space(20)]
        _Color ("Color", Color) = (1,1,1,1)
        _ShadingColor ("Shading Color", Color) = (0,0,0,1)
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        
        [Space(20)]
        _Multiply ("Multiply", Float) = 1
        
        [Space(20)]
        _LitTrashHold ("Lit Trashhold", Range(-1,1)) = 0
        _LitSoftness ("Lit Softness", Range(0,1)) = 1
        
        [Space(20)]
        [Toggle(USE_SPECULAR)] _UseSpecular ("Use Specular", Float) = 0
        _SpecularSize ("Specular Size", Range(0.01,1)) = 0
        
        [Space(20)]
        [Toggle(USE_FRESNEL)] _UseFresnel ("Use Fresnel", Float) = 0
        [Toggle(USE_FRESNEL_REFLECT)] _UseFresnelReflect ("Use Fresnel Reflect", Float) = 0
        _SpecularTexture ("Specular Texture", CUBE) = "white" {}
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelBase ("Fresnel Base", Range(0, 1)) = 0
        
        [Space(20)]
        [Toggle(USE_FOG)] _UseFog ("Use fog", Float) = 0
        
        [Space(20)]
        [Toggle(USE_BAKED_SHADOWS)] _UseBakedShadows ("Use Baked Shadows", Float) = 0
        _BakedShadows ("Baked Shadows Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            
            #pragma shader_feature USE_FOG
            #pragma shader_feature USE_SPECULAR
            #pragma shader_feature USE_FRESNEL
            #pragma shader_feature USE_FRESNEL_REFLECT

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            #ifdef USE_FOG
            #include "Common/fogTransparent.cginc"
            #endif
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD3;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 worldPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;

            fixed _Multiply;

            fixed _LitTrashHold;
            fixed _LitSoftness;
            fixed4 _ShadingColor;
            fixed4 _Highlight;
            
            fixed4 _SpecularColor;
            fixed _SpecularSize;

            fixed4 _FresnelColor;
            fixed _FresnelBase;

            samplerCUBE _SpecularTexture;

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = v.uv2;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            inline fixed4 ApplySpecular (fixed4 color, v2f i)
            {
                const fixed3 normWorld = normalize(i.worldNormal);
                const fixed3 normLightDir = normalize(_WorldSpaceLightPos0);
                const fixed3 viewVec = normalize(i.worldPos - _WorldSpaceCameraPos);
                const fixed3 refLight = reflect(normLightDir, normWorld);
                const fixed dotRef = max(0, dot(refLight, viewVec));
                const fixed spec = pow(dotRef, 32.0 * _SpecularSize);

                return fixed4(color + lerp(0, spec, _SpecularColor.a) * _SpecularColor.rgb, max(color.a, spec));
            }

            inline fixed4 ApplyFresnel(fixed4 color, v2f i)
            {
                const fixed3 normWorld = normalize(i.worldNormal);
                const fixed3 viewVec = normalize(i.worldPos - _WorldSpaceCameraPos);

                const fixed dotProduct = dot(viewVec, normWorld);

                fixed fresnel = smoothstep(-1+_FresnelBase, _FresnelBase, dotProduct);

                fresnel *= _FresnelColor.a;

                #ifdef USE_FRESNEL_REFLECT
                const fixed4 refSample = texCUBE(_SpecularTexture, normWorld);

                fresnel = min(refSample.r, fresnel);
                fixed3 fresnelComp = lerp(0, refSample.rgb, fresnel);
                #else
                fixed3 fresnelComp = fresnel * _FresnelColor.rgb;
                #endif

                return fixed4(color + fresnelComp, max(color.a, fresnel));
            }

            inline fixed3 ApplyShading (fixed3 color, fixed fong)
            {
                fong = smoothstep(_LitTrashHold - _LitSoftness*2, _LitTrashHold + _LitSoftness, fong);
                fong = saturate(fong);
                return color * max(_ShadingColor, fong);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * lerp(_Color, _Highlight, _Highlight.a) * _Multiply;
                col.rgb *= _LightColor0.rgb;

                const fixed fong = dot(_WorldSpaceLightPos0.xyz, normalize(i.worldNormal));

                #ifdef USE_FRESNEL
                col = ApplyFresnel(col, i);
                #endif

                #ifdef USE_SPECULAR
                col = ApplySpecular(col, i);
                #endif

                col.rgb = ApplyShading(col, fong);
                
                #ifdef USE_FOG
                col.rgb = ApplyFog(col, i);
                #endif
                
                return col;
            }
            ENDCG
        }
        
        UsePass "VertexLit/SHADOWCASTER"
    }
}
