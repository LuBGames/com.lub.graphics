Shader "LuB/Water"
{
    Properties
    {
		_DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
		_FoamColor("Foam Color", Color) = (1,1,1,1)
		_TopColor("Top Color", Color) = (1,1,1,1)
		_SurfaceNoise("Surface Noise", 2D) = "white" {}
		_SurfaceDistortion("Surface Distortion", 2D) = "white" {}
		_SurfaceDistortionAmount("Surface Distortion Amount", Float) = 0.1
		_TopLayer("Top Layer", 2D) = "white" {}
		_SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
		_SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
    }
    SubShader
    {
		Tags{ "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Pass
        {
        	Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

            CGPROGRAM
			#define SMOOTHSTEP_AA 0.01

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;	
				float2 noiseUV : TEXCOORD0;
				half2 topLayerUV : TEXCOORD1;
            	float3 worldPos : WORLD;
            };

			sampler2D _SurfaceNoise;
			sampler2D _TopLayer;
			float4 _SurfaceNoise_ST;
			float4 _TopLayer_ST;
			sampler2D _SurfaceDistortion;
			float4 _SurfaceDistortion_ST;
			float _SurfaceDistortionAmount;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
            	float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
            	o.noiseUV = worldPos.xz * _SurfaceNoise_ST.xy;
            	o.topLayerUV = worldPos.xz * _TopLayer_ST.xy;
            	o.worldPos = worldPos;
                return o;
            }

			fixed4 _DepthGradientShallow;
			fixed4 _FoamColor;
			fixed4 _TopColor;
            
			float _SurfaceNoiseCutoff;

			float3 _SurfaceNoiseScroll;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 waterColor = _DepthGradientShallow;

				float surfaceNoiseCutoff = _SurfaceNoiseCutoff;

				half2 noiseUV = half2((i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x), 
				(i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y));
            	half2 noiseUV2 = half2((i.noiseUV.x - _Time.y * _SurfaceNoiseScroll.x), 
				(i.noiseUV.y - _Time.y * _SurfaceNoiseScroll.y));
            	noiseUV += half2(_Time.y * _SurfaceNoiseScroll.z, 0);
            	noiseUV2 += half2(_Time.y * _SurfaceNoiseScroll.z, 0);
				float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;
            	surfaceNoiseSample = (surfaceNoiseSample + tex2D(_SurfaceNoise, noiseUV2).r)*0.5;

				float surfaceNoise = smoothstep(surfaceNoiseCutoff - SMOOTHSTEP_AA, surfaceNoiseCutoff + SMOOTHSTEP_AA, surfaceNoiseSample);

            	//fixed4 compColor = lerp(waterColor, _FoamColor, surfaceNoise);
            	fixed4 compColor = waterColor;
            	compColor.rgb += lerp(0, _FoamColor, surfaceNoise);

            	half2 noiseDist = tex2D(_SurfaceDistortion, i.worldPos.xz * _SurfaceDistortion_ST.xy + half2(_Time.x, _Time.x) * 0.1).rg;

            	fixed top = 1-tex2D(_TopLayer, i.topLayerUV + noiseDist * _SurfaceDistortionAmount).a;

            	compColor.rgb += top * _TopColor;
            	
				return compColor;
            }
            ENDCG
        }
    }
}