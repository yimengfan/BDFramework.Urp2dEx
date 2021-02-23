#if USE_NORMAL_MAP
    #if LIGHT_QUALITY_FAST
        #define NORMALS_LIGHTING_COORDS(TEXCOORDA, TEXCOORDB) \
            float4	lightDirection	: TEXCOORDA;\
            float4	screenUV   : TEXCOORDB;

        #define TRANSFER_NORMALS_LIGHTING(output, worldSpacePos)\
            output.screenUV = ComputeScreenPos(output.positionCS);\
            output.lightDirection.xy = _LightPosition.xy - worldSpacePos.xy;\
            output.lightDirection.z = _LightZDistance;\
            output.lightDirection.w = 0;\
            output.lightDirection.w = normalize(output.lightDirection.xyz);
            
        #define APPLY_NORMALS_LIGHTING(input, lightColor)\
            half4 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.screenUV.xy/ input.screenUV.w);\
            float3 normalUnpacked = UnpackNormal(normal);\
            lightColor = lightColor * saturate(dot(input.lightDirection.xyz, normalUnpacked));
    #else
        #define NORMALS_LIGHTING_COORDS(TEXCOORDA, TEXCOORDB) \
            float4	positionWS : TEXCOORDA;\
            float4	screenUV   : TEXCOORDB;

        #define TRANSFER_NORMALS_LIGHTING(output, worldSpacePos) \
            output.screenUV = ComputeScreenPos(output.positionCS);\
            output.positionWS = worldSpacePos;

        #define APPLY_NORMALS_LIGHTING(input, lightColor) \
            float4 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.screenUV.xy / input.screenUV.w);\
            float3 normalUnpacked = UnpackNormal(normal);\
            float3 dirToLight;\
            dirToLight.xy = _LightPosition.xy - input.positionWS.xy;\
            dirToLight.z =  _LightZDistance;\
            dirToLight = normalize(dirToLight);\
            lightColor = lightColor * saturate(dot(dirToLight, normalUnpacked));
    #endif

    #define NORMALS_LIGHTING_VARIABLES \
            TEXTURE2D(_NormalMap); \
            SAMPLER(sampler_NormalMap); \
            float4	_LightPosition;\
            half	    _LightZDistance;
#else
    #define NORMALS_LIGHTING_COORDS(TEXCOORDA, TEXCOORDB)
    #define NORMALS_LIGHTING_VARIABLES
    #define TRANSFER_NORMALS_LIGHTING(output, worldSpacePos)
    #define TRANSFER_NORMALS_LIGHTINGTWO(input, output, worldSpacePos)
    #define APPLY_NORMALS_LIGHTING(input, lightColor)
#endif

#define SHADOW_COORDS(TEXCOORDA)\
    float2  shadowUV    : TEXCOORDA;

#define SHADOW_VARIABLES\
    float  _ShadowIntensity;\
    float  _ShadowVolumeIntensity;\
    TEXTURE2D(_ShadowTex);\
    SAMPLER(sampler_ShadowTex);

#define APPLY_SHADOWS(input, color, intensity)\
    if(intensity < 1)\
    {\
        half4 shadow = saturate(SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, input.shadowUV)); \
        half  shadowIntensity = 1 - (shadow.r * saturate(2 * (shadow.g - 0.5f * shadow.b))); \
        color.rgb = (color.rgb * shadowIntensity) + (color.rgb * intensity*(1 - shadowIntensity));\
    }

    

#define TRANSFER_SHADOWS(output)\
    output.shadowUV = ComputeScreenPos(output.positionCS / output.positionCS.w).xy;

#define SHAPE_LIGHT(index)\
    TEXTURE2D(_ShapeLightTexture##index);\
    SAMPLER(sampler_ShapeLightTexture##index);\
    float2 _ShapeLightBlendFactors##index;\
    float4 _ShapeLightMaskFilter##index;\
    float4 _ShapeLightInvertedFilter##index;

