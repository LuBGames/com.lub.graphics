Shader "LuB/FillShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_FillColor ("Fill Color", Color) = (0,1,0,1)
		_Fill ("Fill", Range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 vert : TEXCOORD0;
			};

			fixed4 _Color;
			fixed4 _FillColor;
			fixed _Fill;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vert = v.vertex;
				return o;
			}

			inline fixed GetAngle (half2 one, half2 two)
			{
				return acos(dot(one, two)) * 57.29578 * sign(one.x * two.y - one.y * two.x);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed dotp = GetAngle( normalize(i.vert.xy), half2(0,1));
				fixed3 color = lerp(_Color, _FillColor, 1-step((_Fill-0.5)*360, dotp));
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}