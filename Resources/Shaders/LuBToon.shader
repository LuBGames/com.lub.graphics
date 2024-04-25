Shader "LuB/NewToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Space(20)]
        [Gamma] _Color ("Color", Color) = (1,1,1,1)
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
        
        [Space(20)]
        [Toggle(USE_CUTOUT)] _UseCutout ("Use Cutout", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing

            #pragma shader_feature SHADOWS_SCREEN
            
            #pragma shader_feature USE_FOG
            #pragma shader_feature USE_SPECULAR
            #pragma shader_feature USE_FRESNEL
            #pragma shader_feature USE_FRESNEL_REFLECT
            #pragma shader_feature USE_BAKED_SHADOWS
            #pragma shader_feature USE_SHADOW_COLOR_FOR_SHADING
            #pragma shader_feature USE_CUTOUT

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "baseFragment.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            sampler2D _AoTex;
            half4 _MainTex_ST;

            fixed4 _Color;

            half _Multiply;

            FragData vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                
                FragData o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = v.uv2;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.color = _LightColor0 * _Color * _Multiply;
                
                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag (FragData i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                #if defined(USE_CUTOUT)
                clip(col.a - 0.1);
                #endif

                const half3 worldNormal = normalize(i.worldNormal);

                const fixed fong = dot(_WorldSpaceLightPos0.xyz, worldNormal);

                Surface surface;
                surface.position = i.worldPos;
                surface.color = col.rgb * i.color;
                surface.fong = fong;
                surface.normal = worldNormal;
                surface.shadow = 0;

                return fixed4(ComputeBase(surface, i), 1);
            }
            ENDCG
        }
        
        UsePass "VertexLit/SHADOWCASTER"
    }
}
