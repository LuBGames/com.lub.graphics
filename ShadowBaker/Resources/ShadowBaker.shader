Shader "Hidden/ShadowBaker"
{
	SubShader
	{
		ZTest Off
		Cull Off
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature SHADOWS_SCREEN
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				unityShadowCoord4 _ShadowCoord : TEXCOORD1;
			};

			sampler2D _Shadows;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = float4((v.uv - 0.5) * 2, 0, 1);
				o._ShadowCoord = mul(unity_WorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				unityShadowCoord dist = SAMPLE_DEPTH_TEXTURE(_Shadows, i._ShadowCoord.xy);
                unityShadowCoord lightShadowDataX = _LightShadowData.x;
                unityShadowCoord threshold = i._ShadowCoord.z;
                fixed at = max(dist > threshold, lightShadowDataX);
				return fixed4(at,at,at,1);
			}
			ENDCG
		}
	}
}