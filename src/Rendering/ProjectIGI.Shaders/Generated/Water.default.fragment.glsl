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

layout(binding = 0) uniform samplerCube _436;

layout(location = 0) out vec4 entryPointParam_fragmentMain;
layout(location = 0) in vec4 input_colour0;
layout(location = 1) in vec3 input_colour1;
layout(location = 2) in vec3 input_reflection;
layout(location = 3) in float input_fog;

void main()
{
    vec4 _sampled = texture(_436, input_reflection);
    vec3 _266 = _sampled.xyz;
    vec3 _368;
    if (_275)
    {
        bvec3 _438 = isnan(_266);
        bvec3 _439 = isnan(vec3(0.0));
        vec3 _440 = max(_266, vec3(0.0));
        vec3 _441 = vec3(_438.x ? vec3(0.0).x : _440.x, _438.y ? vec3(0.0).y : _440.y, _438.z ? vec3(0.0).z : _440.z);
        _368 = mix((pow(vec3(_439.x ? _266.x : _441.x, _439.y ? _266.y : _441.y, _439.z ? _266.z : _441.z), vec3(0.4166666567325592041015625)) * 1.05499994754791259765625) - vec3(0.054999999701976776123046875), _266 * 12.9200000762939453125, step(_266, vec3(0.003130800090730190277099609375)));
    }
    else
    {
        _368 = _266;
    }
    vec3 _315 = mix(push.fogNormalScale.xyz, clamp((input_colour0.xyz * _368) + input_colour1, vec3(0.0), vec3(1.0)), vec3(input_fog));
    vec3 shown;
    if (_316)
    {
        bvec3 _443 = isnan(_315);
        bvec3 _444 = isnan(vec3(0.0));
        vec3 _445 = max(_315, vec3(0.0));
        vec3 _446 = vec3(_443.x ? vec3(0.0).x : _445.x, _443.y ? vec3(0.0).y : _445.y, _443.z ? vec3(0.0).z : _445.z);
        vec3 _318 = vec3(_444.x ? _315.x : _446.x, _444.y ? _315.y : _446.y, _444.z ? _315.z : _446.z);
        vec3 _396 = (_318 + vec3(0.054999999701976776123046875)) * vec3(0.947867333889007568359375);
        bvec3 _448 = isnan(_396);
        bvec3 _449 = isnan(vec3(0.0));
        vec3 _450 = max(_396, vec3(0.0));
        vec3 _451 = vec3(_448.x ? vec3(0.0).x : _450.x, _448.y ? vec3(0.0).y : _450.y, _448.z ? vec3(0.0).z : _450.z);
        shown = mix(pow(vec3(_449.x ? _396.x : _451.x, _449.y ? _396.y : _451.y, _449.z ? _396.z : _451.z), vec3(2.400000095367431640625)), _318 * vec3(0.077399380505084991455078125), step(_318, vec3(0.040449999272823333740234375))) * push.diffuseScale.w;
    }
    else
    {
        shown = _315;
    }
    entryPointParam_fragmentMain = vec4(shown, input_colour0.w);
}

