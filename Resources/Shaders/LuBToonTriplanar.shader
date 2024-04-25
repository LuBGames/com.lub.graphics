Shader "LuB/NewToonTriplanar"
{
    Properties
    {
        _MainTexX ("TextureX", 2D) = "white" {}
        _MainTexY ("TextureY", 2D) = "white" {}
        _MainTexZ ("TextureZ", 2D) = "white" {}
        
        _BlendOffset ("Blend Offset", Range(0, 0.5)) = 0
        
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

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Common/baseFragment.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTexX;
            sampler2D _MainTexY;
            sampler2D _MainTexZ;

            float4 _MainTexX_ST;
            float4 _MainTexY_ST;
            float4 _MainTexZ_ST;

            half _BlendOffset;

            fixed4 _Color;

            half _Multiply;

            struct TriplanarUV {
				half2 x, y, z;
			};

            struct SurfaceParameters
            {
	            float3 position;
            	half3 normal;
            };

            FragData vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                
                FragData o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                TRANSFER_SHADOW(o);
                
                return o;
            }

            TriplanarUV GetTriplanarUV (SurfaceParameters parameters) {
	            TriplanarUV triUV;
	            float3 p = parameters.position;
	            triUV.x = p.zy;
	            triUV.y = p.xz;
	            triUV.z = p.xy;
	            if (parameters.normal.x < 0) {
		            triUV.x.x = -triUV.x.x;
	            }
	            if (parameters.normal.y < 0) {
		            triUV.y.x = -triUV.y.x;
	            }
	            if (parameters.normal.z >= 0) {
		            triUV.z.x = -triUV.z.x;
	            }
	            return triUV;
            }

            half3 GetTriplanarWeights (SurfaceParameters parameters) {
				half3 triW = abs(parameters.normal);
            	triW = saturate(triW - _BlendOffset);
				return triW / (triW.x + triW.y + triW.z);
			}

            fixed4 frag (FragData i) : SV_Target
            {
            	SurfaceParameters surfacePar;
            	surfacePar.normal = i.worldNormal;
            	surfacePar.position = i.worldPos;

            	TriplanarUV triplanar_uv = GetTriplanarUV(surfacePar);
            	fixed3 triW = GetTriplanarWeights(surfacePar);

            	fixed4 albedoX = tex2D(_MainTexX, triplanar_uv.x * _MainTexX_ST.xy);
            	fixed4 albedoY = tex2D(_MainTexY, triplanar_uv.y * _MainTexY_ST.xy);
            	fixed4 albedoZ = tex2D(_MainTexZ, triplanar_uv.z * _MainTexZ_ST.xy);

            	fixed4 col = albedoX * triW.x + albedoY * triW.y + albedoZ * triW.z;

            	col *= _Color * _Multiply;

                const half3 worldNormal = normalize(i.worldNormal);

                const fixed fong = dot(_WorldSpaceLightPos0.xyz, worldNormal);

                Surface surface;
                surface.position = i.worldPos;
                surface.color = col.rgb;
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
