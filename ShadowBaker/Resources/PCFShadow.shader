Shader "Hidden/PCFShadow"
{
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float2 _Size;

			fixed4 frag (v2f i) : SV_Target
			{
				float total = 0;
				[Loop]
				for (int x = -5; x < 5; x++)
				{
					[Loop]
					for (int y = -5; y < 5; y++)
					{
						total += tex2D(_MainTex, i.uv + float2(x * _Size.x, y * _Size.y));
					}
				}
				total = total / 100;
				return fixed4(total,total,total,1);
			}
			ENDCG
		}
	}
}