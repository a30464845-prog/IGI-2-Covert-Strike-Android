#version 430

#ifndef SPIRV_CROSS_CONSTANT_ID_1
#define SPIRV_CROSS_CONSTANT_ID_1 0.0
#endif
const float cSunX = SPIRV_CROSS_CONSTANT_ID_1;
#ifndef SPIRV_CROSS_CONSTANT_ID_2
#define SPIRV_CROSS_CONSTANT_ID_2 0.0
#endif
const float cSunY = SPIRV_CROSS_CONSTANT_ID_2;
#ifndef SPIRV_CROSS_CONSTANT_ID_3
#define SPIRV_CROSS_CONSTANT_ID_3 0.0
#endif
const float cSunZ = SPIRV_CROSS_CONSTANT_ID_3;
#ifndef SPIRV_CROSS_CONSTANT_ID_9
#define SPIRV_CROSS_CONSTANT_ID_9 0.0
#endif
const float cSunRed = SPIRV_CROSS_CONSTANT_ID_9;
#ifndef SPIRV_CROSS_CONSTANT_ID_10
#define SPIRV_CROSS_CONSTANT_ID_10 0.0
#endif
const float cSunGreen = SPIRV_CROSS_CONSTANT_ID_10;
#ifndef SPIRV_CROSS_CONSTANT_ID_11
#define SPIRV_CROSS_CONSTANT_ID_11 0.0
#endif
const float cSunBlue = SPIRV_CROSS_CONSTANT_ID_11;
#ifndef SPIRV_CROSS_CONSTANT_ID_6
#define SPIRV_CROSS_CONSTANT_ID_6 0.0
#endif
const float cAmbientRed = SPIRV_CROSS_CONSTANT_ID_6;
#ifndef SPIRV_CROSS_CONSTANT_ID_7
#define SPIRV_CROSS_CONSTANT_ID_7 0.0
#endif
const float cAmbientGreen = SPIRV_CROSS_CONSTANT_ID_7;
#ifndef SPIRV_CROSS_CONSTANT_ID_8
#define SPIRV_CROSS_CONSTANT_ID_8 0.0
#endif
const float cAmbientBlue = SPIRV_CROSS_CONSTANT_ID_8;
#ifndef SPIRV_CROSS_CONSTANT_ID_64
#define SPIRV_CROSS_CONSTANT_ID_64 1
#endif
const int cClipYDown = SPIRV_CROSS_CONSTANT_ID_64;
#ifndef SPIRV_CROSS_CONSTANT_ID_66
#define SPIRV_CROSS_CONSTANT_ID_66 0
#endif
const int cSamplerDecodes = SPIRV_CROSS_CONSTANT_ID_66;
#ifndef SPIRV_CROSS_CONSTANT_ID_12
#define SPIRV_CROSS_CONSTANT_ID_12 0
#endif
const int cLinearScene = SPIRV_CROSS_CONSTANT_ID_12;
const bool _219 = (cClipYDown != 0);
const bool _275 = (cSamplerDecodes != 0);
const bool _316 = (cLinearScene != 0);

layout(binding = 0, std140) uniform WaterPush_std140
{
    layout(row_major) mat4 modelViewProjection;
    vec4 eyeFacing;
    vec4 diffuseScale;
    vec4 specularFog;
    vec4 fogNormalScale;
} push;

layout(location = 0) out vec4 entryPointParam_vertexMain_colour0;
layout(location = 1) out vec3 entryPointParam_vertexMain_colour1;
layout(location = 2) out vec3 entryPointParam_vertexMain_reflection;
layout(location = 3) out float entryPointParam_vertexMain_fog;
layout(location = 0) in vec3 input_position;
layout(location = 1) in vec3 input_normal;
layout(location = 2) in vec2 input_shallowness;

mat4 spvWorkaroundRowMajor(mat4 wrap) { return wrap; }

void main()
{
    vec3 sun;
    vec3 _419 = sun;
    _419.x = cSunX;
    _419.y = cSunY;
    _419.z = cSunZ;
    sun = _419;
    vec3 sunColour;
    vec3 _425 = sunColour;
    _425.x = cSunRed;
    _425.y = cSunGreen;
    _425.z = cSunBlue;
    sunColour = _425;
    vec3 normal = input_normal * push.fogNormalScale.w;
    vec3 _101 = normalize(push.eyeFacing.xyz - input_position);
    float _113 = dot(_101, normal);
    float _116 = isnan(push.eyeFacing.w) ? _113 : (isnan(_113) ? push.eyeFacing.w : max(_113, push.eyeFacing.w));
    vec3 _404 = ((normal * (_116 * 2.0)) - _101).xzy;
    float grazing = 1.0 - _116;
    float grazing2 = grazing * grazing;
    float _130 = ((grazing2 * grazing2) * grazing) * 0.979632794857025146484375;
    float fresnel = _130 + 0.02036719955503940582275390625;
    float _137 = 0.979632794857025146484375 - _130;
    vec4 _402 = clamp(vec4(fresnel, fresnel, fresnel, _137 * input_shallowness.x), vec4(0.0), vec4(1.0));
    float _154 = dot(normalize(_101 + _419), normal);
    float glint2 = _154 * _154;
    float glint8 = glint2 * glint2;
    vec3 _403 = clamp(((((push.specularFog.xyz * ((glint8 * glint8) * _154)) * _425) * fresnel) + ((((_425 * dot(normal, _419)) * push.diffuseScale.xyz) + vec3(cAmbientRed, cAmbientGreen, cAmbientBlue)) * _137)) * (1.0 - input_shallowness.x), vec3(0.0), vec3(1.0));
    vec4 clip = vec4(input_position, 1.0) * spvWorkaroundRowMajor(push.modelViewProjection);
    float _70;
    if (push.specularFog.w > 0.0)
    {
        _70 = clamp(exp2((-push.specularFog.w) * (isnan(0.0) ? clip.w : (isnan(clip.w) ? 0.0 : max(clip.w, 0.0)))), 0.0, 1.0);
    }
    else
    {
        _70 = 1.0;
    }
    float _405 = _70;
    float _360;
    if (_219)
    {
        _360 = -clip.y;
    }
    else
    {
        _360 = clip.y;
    }
    vec4 _431 = clip;
    _431.y = _360;
    _431.z = (_431.w - _431.z) * 0.5;
    clip = _431;
    gl_Position = _431;
    entryPointParam_vertexMain_colour0 = _402;
    entryPointParam_vertexMain_colour1 = _403;
    entryPointParam_vertexMain_reflection = _404;
    entryPointParam_vertexMain_fog = _405;
}

