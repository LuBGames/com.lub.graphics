Shader "LuB/NewToon"
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
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelBase ("Fresnel Base", Range(0, 1)) = 0
        
        [Space(20)]
        [Toggle(USE_FOG)] _UseFog ("Use fog", Float) = 0
        
        [Space(20)]
        [IntRange] _Stencil ("Stencil ID", Range(0, 255)) = 0
        [IntRange] _StencilComp ("Stencil Comparison", Range(0, 8)) = 8
        [IntRange] _StencilOp ("Stencil Operation", Range(0, 7)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
        }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fwdadd_fullshadows
            #pragma shader_feature USE_FOG
            #pragma shader_feature USE_SPECULAR
            #pragma shader_feature USE_FRESNEL

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            #ifdef USE_FOG
            #include "fog.cginc"
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
                unityShadowCoord4 _ShadowCoord : TEXCOORD1;
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

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = v.uv2;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                
                return o;
            }

            inline fixed3 ApplySpecular (fixed3 color, fixed shadow, v2f i)
            {
                const fixed3 normWorld = normalize(i.worldNormal);
                const fixed3 normLightDir = normalize(_WorldSpaceLightPos0);
                const fixed3 viewVec = normalize(i.worldPos - _WorldSpaceCameraPos);
                const fixed3 refLight = reflect(normLightDir, normWorld);
                const fixed dotRef = max(0, dot(refLight, viewVec));
                const fixed spec = pow(dotRef, 32.0 * _SpecularSize);

                const fixed blendSpec = _SpecularColor.a * smoothstep(0,1, shadow);

                return color + lerp(0, spec, blendSpec) * _SpecularColor.rgb;
            }

            inline fixed3 ApplyFresnel(fixed3 color, fixed shadow, v2f i)
            {
                const fixed3 normWorld = normalize(i.worldNormal);
                const fixed3 viewVec = normalize(i.worldPos - _WorldSpaceCameraPos);

                const fixed dotProduct = dot(viewVec, normWorld);

                fixed fresnel = smoothstep(-1+_FresnelBase, _FresnelBase, dotProduct);

                fresnel *= _FresnelColor.a;

                return color + fresnel * _FresnelColor.rgb;
            }

            inline fixed3 ApplyShadows (fixed3 color, fixed fong, v2f i, out fixed shadow)
            {
                shadow = lerp(1, LIGHT_ATTENUATION(i), max(fong, 0));
                return color * shadow;
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

                const fixed fong = dot(_WorldSpaceLightPos0.xyz, normalize(i.worldNormal));

                fixed shadow;
                col.rgb = ApplyShadows(col, fong, i, shadow);

                #ifdef USE_FRESNEL
                col.rgb = ApplyFresnel(col, shadow, i);
                #endif

                #ifdef USE_SPECULAR
                col.rgb = ApplySpecular(col, shadow, i);
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
