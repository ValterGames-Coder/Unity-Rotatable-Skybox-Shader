Shader "Skybox/RotatableSkybox"
{
    Properties
    {
        _FrontTex ("Front Texture", 2D) = "white" {}
        _BackTex  ("Back Texture", 2D)  = "black" {}
        _LeftTex  ("Left Texture", 2D)  = "black" {}
        _RightTex ("Right Texture", 2D) = "black" {}
        _UpTex    ("Up Texture", 2D)    = "black" {}
        _DownTex  ("Down Texture", 2D)  = "black" {}
        
        _RotationX ("Rotation X", Range(0, 360)) = 0.0
        _RotationY ("Rotation Y", Range(0, 360)) = 0.0
        _RotationZ ("Rotation Z", Range(0, 360)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Background" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _FrontTex;
            sampler2D _BackTex;
            sampler2D _LeftTex;
            sampler2D _RightTex;
            sampler2D _UpTex;
            sampler2D _DownTex;

            float _RotationY;
            float _RotationZ;
            float _RotationX;

            float3x3 GetRotationMatrix(float rotationY, float rotationZ, float rotationX)
            {
                rotationY = radians(rotationY);
                rotationZ = radians(rotationZ);
                rotationX = radians(rotationX);

                float3x3 rotationMatrixY = float3x3(
                    cos(rotationY), 0, sin(rotationY),
                    0, 1, 0,
                    -sin(rotationY), 0, cos(rotationY)
                );

                float3x3 rotationMatrixZ = float3x3(
                    cos(rotationZ), -sin(rotationZ), 0,
                    sin(rotationZ), cos(rotationZ), 0,
                    0, 0, 1
                );

                float3x3 rotationMatrixX = float3x3(
                    1, 0, 0,
                    0, cos(rotationX), -sin(rotationX),
                    0, sin(rotationX), cos(rotationX)
                );

                return mul(rotationMatrixX, mul(rotationMatrixZ, rotationMatrixY));
            }

            struct appdata_t
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 posWorld : TEXCOORD0;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWorld = v.vertex.xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3x3 rotationMatrix = GetRotationMatrix(_RotationY, _RotationZ, _RotationX);
                float3 rotatedPos = mul(rotationMatrix, i.posWorld);
                float3 absRotatedPos = abs(rotatedPos);
                float maxCoord = max(max(absRotatedPos.x, absRotatedPos.y), absRotatedPos.z);
                
                if (maxCoord == absRotatedPos.x)
                {
                    
                    float2 uv = float2(rotatedPos.z, rotatedPos.y) / absRotatedPos.x;
                    uv = uv * 0.5 + 0.5;
                    return (rotatedPos.x > 0) ? tex2D(_LeftTex, float2(1.0 - uv.x, uv.y)) : tex2D(_RightTex, uv);
                }
                if (maxCoord == absRotatedPos.y)
                {
                    float2 uv = float2(rotatedPos.x, rotatedPos.z) / absRotatedPos.y;
                    uv = uv * 0.5 + 0.5;
                    return (rotatedPos.y > 0) ? tex2D(_UpTex, float2(uv.x, 1.0 - uv.y)) : tex2D(_DownTex, uv);
                }
                float2 uv = float2(rotatedPos.x, rotatedPos.y) / absRotatedPos.z;
                uv = uv * 0.5 + 0.5;
                return (rotatedPos.z > 0) ? tex2D(_FrontTex, uv) : tex2D(_BackTex, float2(1.0 - uv.x, uv.y));
            }
            ENDCG
        }
    }
    FallBack "Skybox/Procedural"
}
