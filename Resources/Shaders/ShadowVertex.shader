Shader "LuB/ShadowVertex"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _ShadowOffset ("Shadow Offset", Float) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        
        LOD 100
        
        Stencil {
            Ref 1
            Comp NotEqual
            Pass Replace
        }
        
        Offset -1, -1

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
            };

            fixed4 _Color;
            half _ShadowOffset;

            v2f vert (appdata v)
            {
                v2f o;

                float3 vertPos = mul(unity_ObjectToWorld, v.vertex);
                float3 lightDir = _WorldSpaceLightPos0 - vertPos * _WorldSpaceLightPos0.w;
                float3 offset = -lightDir * vertPos.y;
                vertPos.y = _ShadowOffset;
                vertPos += float3(offset.x, 0, offset.z);
                o.vertex = mul(UNITY_MATRIX_VP, float4(vertPos, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
