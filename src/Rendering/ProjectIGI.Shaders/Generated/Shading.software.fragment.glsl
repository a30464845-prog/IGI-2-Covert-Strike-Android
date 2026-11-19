#version 430
#extension GL_EXT_texture_shadow_lod : enable
#ifdef GL_EXT_texture_shadow_lod
#define spvShadowLod0(s, c) textureLod(s, c, 0.0)
#else
#define spvShadowLod0(s, c) textureGrad(s, c, vec2(0.0), vec2(0.0))
#endif
#if defined(GL_EXT_control_flow_attributes)
#extension GL_EXT_control_flow_attributes : require
#define SPIRV_CROSS_FLATTEN [[flatten]]
#define SPIRV_CROSS_BRANCH [[dont_flatten]]
#define SPIRV_CROSS_UNROLL [[unroll]]
#define SPIRV_CROSS_LOOP [[dont_unroll]]
#else
#define SPIRV_CROSS_FLATTEN
#define SPIRV_CROSS_BRANCH
#define SPIRV_CROSS_UNROLL
#define SPIRV_CROSS_LOOP
#endif

#ifndef SPIRV_CROSS_CONSTANT_ID_64
#define SPIRV_CROSS_CONSTANT_ID_64 1
#endif
const int cClipYDown = SPIRV_CROSS_CONSTANT_ID_64;

struct _Array_std140_matrix_float_4_4_4
{
    mat4 data[4];
};

struct FlashlightParams_std140
{
    vec4 position;
    vec4 axis;
    vec4 up;
    vec4 colour;
    vec4 cone;
    vec4 control;
};

struct _Array_std140_vector_float_4_160
{
    vec4 data[160];
};

const bool _127 = (cClipYDown != 0);
uniform vec2 _2384_frag[12] = vec2[](vec2(-0.3260000050067901611328125, -0.4059999883174896240234375), vec2(-0.839999973773956298828125, -0.07400000095367431640625), vec2(-0.69599997997283935546875, 0.4569999873638153076171875), vec2(-0.20299999415874481201171875, 0.620999991893768310546875), vec2(0.96200001239776611328125, -0.194999992847442626953125), vec2(0.472999989986419677734375, -0.4799999892711639404296875), vec2(0.518999993801116943359375, 0.767000019550323486328125), vec2(0.185000002384185791015625, -0.89300000667572021484375), vec2(0.507000029087066650390625, 0.064000003039836883544921875), vec2(0.89600002765655517578125, 0.412000000476837158203125), vec2(-0.3219999969005584716796875, -0.933000028133392333984375), vec2(-0.791999995708465576171875, -0.597999989986419677734375));
uniform vec2 _3637_frag[4] = vec2[](vec2(0.0), vec2(0.430000007152557373046875, 0.709999978542327880859375), vec2(0.790000021457672119140625, 0.23999999463558197021484375), vec2(0.17000000178813934326171875, 0.4600000083446502685546875));
uvec3 _13487;
float _13488;

layout(binding = 0, std140) uniform Gi_std140
{
    vec4 unproject;
    vec4 probeOrigin;
    vec4 probeInvCount;
    vec4 probeMisc;
    vec4 probeSky;
    vec4 camera;
    vec4 giParams;
    layout(row_major) mat4 viewToWorld;
    vec4 cascadeSplits;
    vec4 shadowConfig;
    layout(row_major) _Array_std140_matrix_float_4_4_4 cascadeMatrix;
    vec4 wetness0;
    vec4 wetness1;
    vec4 shelterMap0;
    vec4 shelterMap1;
    vec4 shelterMap2;
    vec4 fog;
    FlashlightParams_std140 flashlight;
} gi;

layout(binding = 2, std140) uniform Light_std140
{
    vec4 sunDirectionModel;
    vec4 sunColourScale;
    vec4 ambient;
    vec4 sky;
    vec4 moon;
    vec4 stars;
    vec4 retailFog;
} light;

layout(binding = 1, std140) uniform Lamps_std140
{
    vec4 control;
    vec4 source;
    _Array_std140_vector_float_4_160 positionRadius;
    _Array_std140_vector_float_4_160 colourIntensity;
    _Array_std140_vector_float_4_160 direction;
    _Array_std140_vector_float_4_160 rect;
} lamps;

layout(binding = 0) uniform sampler2D _13494;
layout(binding = 2) uniform sampler2D _13497;
layout(binding = 3) uniform sampler2D _13500;
layout(binding = 4) uniform sampler2D _13503;
layout(binding = 19) uniform sampler3D _13505;
layout(binding = 13) uniform sampler2D _13508;
layout(binding = 14) uniform sampler2D _13510;
layout(binding = 15) uniform sampler2D _13512;
layout(binding = 1) uniform sampler2D _13515;
layout(binding = 12) uniform sampler2D _13517;
layout(binding = 9) uniform sampler2D _13519;
layout(binding = 21) uniform sampler2D _13522;
layout(binding = 10) uniform sampler2DArray _13525;
layout(binding = 11) uniform sampler2DArrayShadow _13527;
layout(binding = 17) uniform sampler2D _13529;
layout(binding = 20) uniform sampler2D _13532;
layout(binding = 18) uniform sampler2D _13535;
layout(binding = 5) uniform sampler3D _13537;
layout(binding = 6) uniform sampler3D _13539;
layout(binding = 7) uniform sampler3D _13541;
layout(binding = 8) uniform sampler3D _13543;
layout(binding = 16) uniform sampler2D _13546;

#ifdef GL_ARB_shader_draw_parameters
#define SPIRV_Cross_BaseVertex gl_BaseVertexARB
#else
uniform int SPIRV_Cross_BaseVertex;
#endif
layout(location = 0) out vec4 entryPointParam_fragmentMain;
layout(location = 0) in vec2 input_uv;

mat4 spvWorkaroundRowMajor(mat4 wrap) { return wrap; }

void main()
{
    bool _9749 = false;
    bool _9052 = false;
    {
        float _5382 = fwidth(input_uv.x);
        vec4 _5390 = texelFetch(_13494, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0);
        vec3 albedo = _5390.xyz;
        vec4 _5399 = texelFetch(_13497, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0);
        vec3 baked = texelFetch(_13500, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0).xyz;
        vec4 _5419 = vec4(texelFetch(_13503, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0).x, 0.0, 0.0, 0.0);
        float depth = _5419.x;
        int debugView = int(light.ambient.w + 0.5);
        bool _152;
        vec3 sunLight;
        if (depth <= 0.0)
        {
            if (debugView != 0)
            {
                _152 = debugView != 11;
            }
            else
            {
                _152 = false;
            }
            if (_152)
            {
                entryPointParam_fragmentMain = vec4(0.0, 0.0, 0.0, 1.0);
            }
            else
            {
                if (light.sky.x > 0.5)
                {
                    float _5425 = (_5399.y * 255.0) - 128.0;
                    float _5420;
                    if (_5425 > 0.5)
                    {
                        _5420 = _5425 * 0.0625;
                    }
                    else
                    {
                        _5420 = 1.0;
                    }
                    vec3 _468 = albedo * _5420;
                    vec3 _5433;
                    {
                        if (gi.fog.z <= 0.0)
                        {
                            _5433 = _468;
                        }
                        else
                        {
                            float _5448 = (gi.unproject.w * gi.fog.x) + gi.fog.y;
                            vec4 _5463 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _5448 : (isnan(_5448) ? 9.9999999747524270787835121154785e-07 : max(_5448, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                            _5433 = (_468 * _5463.w) + _5463.xyz;
                        }
                    }
                    entryPointParam_fragmentMain = vec4(_5433, 1.0);
                }
                else
                {
                    vec2 ndc = (input_uv * 2.0) - vec2(1.0);
                    vec3 _543 = normalize((vec4(normalize(vec3(ndc.x / gi.unproject.x, (-ndc.y) / gi.unproject.y, 1.0)), 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz);
                    uint _5472 = uvec2(textureSize(_13508, 0)).y;
                    float _5489 = (gi.giParams.w * gi.giParams.w) - 40449600.0;
                    float _5494 = acos(clamp(sqrt(isnan(_5489) ? 0.0 : (isnan(0.0) ? _5489 : max(0.0, _5489))) / gi.giParams.w, -1.0, 1.0));
                    float _5495 = 3.1415927410125732421875 - _5494;
                    float _5498 = acos(clamp(_543.z, -1.0, 1.0));
                    float _5484;
                    if (_5498 < _5495)
                    {
                        float _5510 = 1.0 - (_5498 / _5495);
                        _5484 = (1.0 - sqrt(isnan(_5510) ? 0.0 : (isnan(0.0) ? _5510 : max(0.0, _5510)))) * 0.5;
                    }
                    else
                    {
                        float _5503 = (_5498 - _5495) / (isnan(9.9999999747524270787835121154785e-07) ? _5494 : (isnan(_5494) ? 9.9999999747524270787835121154785e-07 : max(_5494, 9.9999999747524270787835121154785e-07)));
                        _5484 = (sqrt(isnan(_5503) ? 0.0 : (isnan(0.0) ? _5503 : max(0.0, _5503))) * 0.5) + 0.5;
                    }
                    float _5518 = atan(_543.y, _543.x);
                    float _5485;
                    if (_5518 < 0.0)
                    {
                        _5485 = _5518 + 6.283185482025146484375;
                    }
                    else
                    {
                        _5485 = _5518;
                    }
                    vec2 _5527 = vec2(_5485 * 0.15915493667125701904296875, _5484);
                    float _5481 = float(_5472);
                    float _5532 = _5527.y;
                    float _5536 = _5481 - 1.0;
                    float _5538 = (floor(_5481 * 0.5) - 1.0) / (isnan(1.0) ? _5536 : (isnan(_5536) ? 1.0 : max(_5536, 1.0)));
                    _5527.y = isnan(_5538) ? _5532 : (isnan(_5532) ? _5538 : min(_5532, _5538));
                    uvec2 _5546 = uvec2(textureSize(_13508, 0));
                    vec2 _5553 = vec2(float(_5546.x), float(_5546.y));
                    float _686 = 2.0 * _5382;
                    float sunPixelAngle = _686 / (isnan(9.9999997473787516355514526367188e-05) ? gi.unproject.x : (isnan(gi.unproject.x) ? 9.9999997473787516355514526367188e-05 : max(gi.unproject.x, 9.9999997473787516355514526367188e-05)));
                    vec3 _699 = normalize((vec4(light.sunDirectionModel.xyz, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz);
                    vec3 _5570;
                    {
                        float _5575 = dot(_543, _699);
                        bool _5571;
                        if (_5575 <= 0.999000012874603271484375)
                        {
                            _5571 = true;
                        }
                        else
                        {
                            _5571 = _699.z <= (-0.0199999995529651641845703125);
                        }
                        if (_5571)
                        {
                            _5570 = vec3(0.0);
                        }
                        else
                        {
                            float _5586 = acos(clamp(_5575, 0.0, 1.0));
                            float _5587 = isnan(sunPixelAngle) ? 0.0046799997799098491668701171875 : (isnan(0.0046799997799098491668701171875) ? sunPixelAngle : max(0.0046799997799098491668701171875, sunPixelAngle));
                            float _5588 = sunPixelAngle * 0.5;
                            float _5592 = 1.0 - smoothstep(_5587 - _5588, _5587 + _5588, _5586);
                            if (_5592 <= 0.0)
                            {
                                _5570 = vec3(0.0);
                            }
                            else
                            {
                                float _5597 = clamp(_5586 / _5587, 0.0, 1.0);
                                float _5599 = 1.0 - (_5597 * _5597);
                                float _5606 = 6.283185482025146484375 * (1.0 - cos(_5587));
                                vec3 _5609 = (light.sunColourScale.xyz * light.sunColourScale.w) / vec3(isnan(9.9999999392252902907785028219223e-09) ? _5606 : (isnan(_5606) ? 9.9999999392252902907785028219223e-09 : max(_5606, 9.9999999392252902907785028219223e-09)));
                                bvec3 _13603 = isnan(_5609);
                                bvec3 _13604 = isnan(vec3(4000.0));
                                vec3 _13605 = min(_5609, vec3(4000.0));
                                vec3 _13606 = vec3(_13603.x ? vec3(4000.0).x : _13605.x, _13603.y ? vec3(4000.0).y : _13605.y, _13603.z ? vec3(4000.0).z : _13605.z);
                                _5570 = vec3(_13604.x ? _5609.x : _13606.x, _13604.y ? _5609.y : _13606.y, _13604.z ? _5609.z : _13606.z) * ((0.4000000059604644775390625 + (0.60000002384185791015625 * sqrt(isnan(0.0) ? _5599 : (isnan(_5599) ? 0.0 : max(_5599, 0.0))))) * _5592);
                            }
                        }
                    }
                    vec3 background = textureLod(_13510, (_5527 * ((_5553 - vec2(1.0)) / _5553)) + (vec2(0.5) / _5553), 0.0).xyz + _5570;
                    if (light.stars.x > 0.0)
                    {
                        _152 = true;
                    }
                    else
                    {
                        _152 = light.moon.w > 0.0;
                    }
                    if (_152)
                    {
                        float pixelAngle = _686 / (isnan(9.9999997473787516355514526367188e-05) ? gi.unproject.x : (isnan(gi.unproject.x) ? 9.9999997473787516355514526367188e-05 : max(gi.unproject.x, 9.9999997473787516355514526367188e-05)));
                        vec3 _798 = normalize(light.moon.xyz);
                        vec3 _5616;
                        {
                            vec3 _5621 = vec3(0.0, 0.0, gi.giParams.w);
                            vec2 _5645;
                            {
                                float _5649 = dot(_543, _543);
                                float _5650 = dot(_5621, _543);
                                float _5658 = (4.0 * (_5650 * _5650)) - ((4.0 * _5649) * (dot(_5621, _5621) - 40449600.0));
                                if (_5658 < 0.0)
                                {
                                    _5645 = vec2(-1.0);
                                }
                                else
                                {
                                    float _5662 = sqrt(_5658);
                                    float _5663 = _5650 * (-2.0);
                                    float _5665 = 2.0 * _5649;
                                    _5645 = vec2((_5663 - _5662) / _5665, (_5663 + _5662) / _5665);
                                }
                            }
                            bool _5617;
                            if (_5645.x > 0.0)
                            {
                                _5617 = true;
                            }
                            else
                            {
                                _5617 = _5645.y > 0.0;
                            }
                            if (_5617)
                            {
                                _5616 = vec3(0.0);
                            }
                            else
                            {
                                float _5633 = _543.z;
                                float _5675 = gi.giParams.w * gi.giParams.w;
                                float _5676 = _5675 - 40449600.0;
                                float _5678 = sqrt(isnan(_5676) ? 0.0 : (isnan(0.0) ? _5676 : max(0.0, _5676)));
                                float _5682 = (_5675 * ((_5633 * _5633) - 1.0)) + 41216400.0;
                                float _5687 = ((-gi.giParams.w) * _5633) + sqrt(isnan(_5682) ? 0.0 : (isnan(0.0) ? _5682 : max(0.0, _5682)));
                                vec3 _5640 = textureLod(_13512, vec2(((isnan(_5687) ? 0.0 : (isnan(0.0) ? _5687 : max(0.0, _5687))) - (6420.0 - gi.giParams.w)) / ((-5544.3291015625) + (_5678 + gi.giParams.w)), _5678 * 0.001141981221735477447509765625), 0.0).xyz;
                                _5616 = _5640 * _5640;
                            }
                        }
                        float _5704 = clamp(1.0 - light.stars.y, 0.0, 1.0);
                        bool _5699;
                        if (light.stars.x > 0.0)
                        {
                            _5699 = _5704 > 0.0;
                        }
                        else
                        {
                            _5699 = false;
                        }
                        vec3 _5700;
                        if (_5699)
                        {
                            vec3 _5820 = _798 - (vec3(0.0, 0.62000000476837158203125, 0.785000026226043701171875) * dot(_798, vec3(0.0, 0.62000000476837158203125, 0.785000026226043701171875)));
                            float _5821 = length(_5820);
                            vec3 _5815;
                            if (_5821 > 9.9999997473787516355514526367188e-05)
                            {
                                _5815 = _5820 / vec3(_5821);
                            }
                            else
                            {
                                _5815 = vec3(1.0, 0.0, 0.0);
                            }
                            vec3 _5834 = vec3(dot(_543, _5815), dot(_543, cross(vec3(0.0, 0.62000000476837158203125, 0.785000026226043701171875), _5815)), dot(_543, vec3(0.0, 0.62000000476837158203125, 0.785000026226043701171875)));
                            float _5719 = 0.3499999940395355224609375 + (0.64999997615814208984375 * clamp(1.0 - (_543.z * 2.5), 0.0, 1.0));
                            vec3 _5836;
                            {
                                vec2 _5837;
                                uint _5905;
                                {
                                    vec3 _5911 = abs(_5834);
                                    float _5912 = _5911.x;
                                    float _5913 = _5911.y;
                                    bool _5906;
                                    if (_5912 >= _5913)
                                    {
                                        _5906 = _5912 >= _5911.z;
                                    }
                                    else
                                    {
                                        _5906 = false;
                                    }
                                    uint _5907;
                                    if (_5906)
                                    {
                                        _5837 = _5834.yz / vec2(_5912);
                                        if (_5834.x > 0.0)
                                        {
                                            _5907 = 0u;
                                        }
                                        else
                                        {
                                            _5907 = 1u;
                                        }
                                        _5905 = _5907;
                                    }
                                    else
                                    {
                                        float _5932 = _5911.z;
                                        if (_5913 >= _5932)
                                        {
                                            _5837 = _5834.xz / vec2(_5913);
                                            if (_5834.y > 0.0)
                                            {
                                                _5907 = 2u;
                                            }
                                            else
                                            {
                                                _5907 = 3u;
                                            }
                                            _5905 = _5907;
                                        }
                                        else
                                        {
                                            _5837 = _5834.xy / vec2(_5932);
                                            if (_5834.z > 0.0)
                                            {
                                                _5907 = 4u;
                                            }
                                            else
                                            {
                                                _5907 = 5u;
                                            }
                                            _5905 = _5907;
                                        }
                                    }
                                }
                                vec2 _5847 = floor(((_5837 * 0.5) + vec2(0.5)) * 55.0);
                                uvec3 _5854 = uvec3(uint(_5847.x), uint(_5847.y), (_5905 * 7919u) + 17u);
                                uvec3 _5967 = (_5854 * uvec3(1664525u)) + uvec3(1013904223u);
                                _5967.x = _5967.x + (_5967.y * _5967.z);
                                _5967.y = _5967.y + (_5967.z * _5967.x);
                                _5967.z = _5967.z + (_5967.x * _5967.y);
                                uvec3 _5994 = _5967 ^ (_5967 >> uvec3(16u));
                                _5994.x = _5994.x + (_5994.y * _5994.z);
                                _5994.y = _5994.y + (_5994.z * _5994.x);
                                _5994.z = _5994.z + (_5994.x * _5994.y);
                                vec3 _5960 = vec3(_5994) * 2.3283064365386962890625e-10;
                                if (_5960.z > 0.5)
                                {
                                    _5836 = vec3(0.0);
                                }
                                else
                                {
                                    uvec3 _6026 = ((_5854 + uvec3(101u, 211u, 307u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                    _6026.x = _6026.x + (_6026.y * _6026.z);
                                    _6026.y = _6026.y + (_6026.z * _6026.x);
                                    _6026.z = _6026.z + (_6026.x * _6026.y);
                                    uvec3 _6053 = _6026 ^ (_6026 >> uvec3(16u));
                                    _6053.x = _6053.x + (_6053.y * _6053.z);
                                    _6053.y = _6053.y + (_6053.z * _6053.x);
                                    _6053.z = _6053.z + (_6053.x * _6053.y);
                                    vec3 _6019 = vec3(_6053) * 2.3283064365386962890625e-10;
                                    vec2 _5871 = ((((_5847 + vec2(0.25)) + (_5960.xy * 0.5)) * vec2(0.01818181760609149932861328125)) - vec2(0.5)) * 2.0;
                                    vec3 _6074;
                                    if (_5905 == 0u)
                                    {
                                        _6074 = vec3(1.0, _5871);
                                    }
                                    else
                                    {
                                        if (_5905 == 1u)
                                        {
                                            _6074 = vec3(-1.0, _5871);
                                        }
                                        else
                                        {
                                            if (_5905 == 2u)
                                            {
                                                _6074 = vec3(_5871.x, 1.0, _5871.y);
                                            }
                                            else
                                            {
                                                if (_5905 == 3u)
                                                {
                                                    _6074 = vec3(_5871.x, -1.0, _5871.y);
                                                }
                                                else
                                                {
                                                    if (_5905 == 4u)
                                                    {
                                                        _6074 = vec3(_5871, 1.0);
                                                    }
                                                    else
                                                    {
                                                        _6074 = vec3(_5871, -1.0);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    float _5874 = length(_5834 - normalize(_6074));
                                    float _5875 = pixelAngle * 0.60000002384185791015625;
                                    float _5876 = isnan(9.9999997473787516355514526367188e-06) ? _5875 : (isnan(_5875) ? 9.9999997473787516355514526367188e-06 : max(_5875, 9.9999997473787516355514526367188e-06));
                                    float _5892 = _6019.z;
                                    vec3 _6118;
                                    {
                                        if (_5892 < 0.180000007152557373046875)
                                        {
                                            _6118 = vec3(0.7200000286102294921875, 0.819999992847442626953125, 1.0);
                                        }
                                        else
                                        {
                                            if (_5892 < 0.62000000476837158203125)
                                            {
                                                _6118 = vec3(0.949999988079071044921875, 0.959999978542327880859375, 1.0);
                                            }
                                            else
                                            {
                                                if (_5892 < 0.86000001430511474609375)
                                                {
                                                    _6118 = vec3(1.0, 0.920000016689300537109375, 0.7599999904632568359375);
                                                }
                                                else
                                                {
                                                    _6118 = vec3(1.0, 0.7599999904632568359375, 0.519999980926513671875);
                                                }
                                            }
                                        }
                                    }
                                    _5836 = _6118 * (((0.014999999664723873138427734375 + (0.98500001430511474609375 * pow(_6019.x, 12.0))) * (1.0 + ((_5719 * 0.449999988079071044921875) * sin((light.stars.z * (2.0 + (6.0 * _6019.y))) + (_5892 * 60.0))))) * exp((-(_5874 * _5874)) / ((2.0 * _5876) * _5876)));
                                }
                            }
                            vec3 _6134;
                            {
                                vec2 _6135;
                                uint _6203;
                                {
                                    vec3 _6209 = abs(_5834);
                                    float _6210 = _6209.x;
                                    float _6211 = _6209.y;
                                    bool _6204;
                                    if (_6210 >= _6211)
                                    {
                                        _6204 = _6210 >= _6209.z;
                                    }
                                    else
                                    {
                                        _6204 = false;
                                    }
                                    uint _6205;
                                    if (_6204)
                                    {
                                        _6135 = _5834.yz / vec2(_6210);
                                        if (_5834.x > 0.0)
                                        {
                                            _6205 = 0u;
                                        }
                                        else
                                        {
                                            _6205 = 1u;
                                        }
                                        _6203 = _6205;
                                    }
                                    else
                                    {
                                        float _6230 = _6209.z;
                                        if (_6211 >= _6230)
                                        {
                                            _6135 = _5834.xz / vec2(_6211);
                                            if (_5834.y > 0.0)
                                            {
                                                _6205 = 2u;
                                            }
                                            else
                                            {
                                                _6205 = 3u;
                                            }
                                            _6203 = _6205;
                                        }
                                        else
                                        {
                                            _6135 = _5834.xy / vec2(_6230);
                                            if (_5834.z > 0.0)
                                            {
                                                _6205 = 4u;
                                            }
                                            else
                                            {
                                                _6205 = 5u;
                                            }
                                            _6203 = _6205;
                                        }
                                    }
                                }
                                vec2 _6145 = floor(((_6135 * 0.5) + vec2(0.5)) * 150.0);
                                uvec3 _6152 = uvec3(uint(_6145.x), uint(_6145.y), (_6203 * 7919u) + 131u);
                                uvec3 _6265 = (_6152 * uvec3(1664525u)) + uvec3(1013904223u);
                                _6265.x = _6265.x + (_6265.y * _6265.z);
                                _6265.y = _6265.y + (_6265.z * _6265.x);
                                _6265.z = _6265.z + (_6265.x * _6265.y);
                                uvec3 _6292 = _6265 ^ (_6265 >> uvec3(16u));
                                _6292.x = _6292.x + (_6292.y * _6292.z);
                                _6292.y = _6292.y + (_6292.z * _6292.x);
                                _6292.z = _6292.z + (_6292.x * _6292.y);
                                vec3 _6258 = vec3(_6292) * 2.3283064365386962890625e-10;
                                if (_6258.z > 0.300000011920928955078125)
                                {
                                    _6134 = vec3(0.0);
                                }
                                else
                                {
                                    uvec3 _6324 = ((_6152 + uvec3(101u, 211u, 307u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                    _6324.x = _6324.x + (_6324.y * _6324.z);
                                    _6324.y = _6324.y + (_6324.z * _6324.x);
                                    _6324.z = _6324.z + (_6324.x * _6324.y);
                                    uvec3 _6351 = _6324 ^ (_6324 >> uvec3(16u));
                                    _6351.x = _6351.x + (_6351.y * _6351.z);
                                    _6351.y = _6351.y + (_6351.z * _6351.x);
                                    _6351.z = _6351.z + (_6351.x * _6351.y);
                                    vec3 _6317 = vec3(_6351) * 2.3283064365386962890625e-10;
                                    vec2 _6169 = ((((_6145 + vec2(0.25)) + (_6258.xy * 0.5)) * vec2(0.006666666828095912933349609375)) - vec2(0.5)) * 2.0;
                                    vec3 _6372;
                                    if (_6203 == 0u)
                                    {
                                        _6372 = vec3(1.0, _6169);
                                    }
                                    else
                                    {
                                        if (_6203 == 1u)
                                        {
                                            _6372 = vec3(-1.0, _6169);
                                        }
                                        else
                                        {
                                            if (_6203 == 2u)
                                            {
                                                _6372 = vec3(_6169.x, 1.0, _6169.y);
                                            }
                                            else
                                            {
                                                if (_6203 == 3u)
                                                {
                                                    _6372 = vec3(_6169.x, -1.0, _6169.y);
                                                }
                                                else
                                                {
                                                    if (_6203 == 4u)
                                                    {
                                                        _6372 = vec3(_6169, 1.0);
                                                    }
                                                    else
                                                    {
                                                        _6372 = vec3(_6169, -1.0);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    float _6172 = length(_5834 - normalize(_6372));
                                    float _6173 = pixelAngle * 0.60000002384185791015625;
                                    float _6174 = isnan(9.9999997473787516355514526367188e-06) ? _6173 : (isnan(_6173) ? 9.9999997473787516355514526367188e-06 : max(_6173, 9.9999997473787516355514526367188e-06));
                                    float _6190 = _6317.z;
                                    vec3 _6416;
                                    {
                                        if (_6190 < 0.180000007152557373046875)
                                        {
                                            _6416 = vec3(0.7200000286102294921875, 0.819999992847442626953125, 1.0);
                                        }
                                        else
                                        {
                                            if (_6190 < 0.62000000476837158203125)
                                            {
                                                _6416 = vec3(0.949999988079071044921875, 0.959999978542327880859375, 1.0);
                                            }
                                            else
                                            {
                                                if (_6190 < 0.86000001430511474609375)
                                                {
                                                    _6416 = vec3(1.0, 0.920000016689300537109375, 0.7599999904632568359375);
                                                }
                                                else
                                                {
                                                    _6416 = vec3(1.0, 0.7599999904632568359375, 0.519999980926513671875);
                                                }
                                            }
                                        }
                                    }
                                    _6134 = _6416 * (((0.014999999664723873138427734375 + (0.98500001430511474609375 * pow(_6317.x, 12.0))) * (1.0 + ((_5719 * 0.449999988079071044921875) * sin((light.stars.z * (2.0 + (6.0 * _6317.y))) + (_6190 * 60.0))))) * exp((-(_6172 * _6172)) / ((2.0 * _6174) * _6174)));
                                }
                            }
                            float _5725 = dot(_5834, normalize(vec3(0.4600000083446502685546875, -0.519999980926513671875, 0.7200000286102294921875)));
                            vec3 _5730 = _5834 * 9.0;
                            vec3 _6433 = floor(_5730);
                            vec3 _6434 = _5730 - _6433;
                            vec3 _6439 = (_6434 * _6434) * (vec3(3.0) - (_6434 * 2.0));
                            uvec3 _6442 = uvec3(ivec3(_6433) + ivec3(4096));
                            uvec3 _6487 = (_6442 * uvec3(1664525u)) + uvec3(1013904223u);
                            _6487.x = _6487.x + (_6487.y * _6487.z);
                            _6487.y = _6487.y + (_6487.z * _6487.x);
                            _6487.z = _6487.z + (_6487.x * _6487.y);
                            uvec3 _6514 = _6487 ^ (_6487 >> uvec3(16u));
                            uvec3 _12922;
                            _12922.x = _6514.x + (_6514.y * _6514.z);
                            uvec3 _12925 = _12922;
                            _12925.y = _12922.y + (_12922.z * _12922.x);
                            uvec3 _12928 = _12922;
                            _12928.z = _12922.z + (_12922.x * _12922.y);
                            uvec3 _6546 = ((_6442 + uvec3(1u, 0u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6546.x = _6546.x + (_6546.y * _6546.z);
                            _6546.y = _6546.y + (_6546.z * _6546.x);
                            _6546.z = _6546.z + (_6546.x * _6546.y);
                            uvec3 _6573 = _6546 ^ (_6546 >> uvec3(16u));
                            uvec3 _12940;
                            _12940.x = _6573.x + (_6573.y * _6573.z);
                            uvec3 _12943 = _12940;
                            _12943.y = _12940.y + (_12940.z * _12940.x);
                            uvec3 _12946 = _12940;
                            _12946.z = _12940.z + (_12940.x * _12940.y);
                            uvec3 _6605 = ((_6442 + uvec3(0u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6605.x = _6605.x + (_6605.y * _6605.z);
                            _6605.y = _6605.y + (_6605.z * _6605.x);
                            _6605.z = _6605.z + (_6605.x * _6605.y);
                            uvec3 _6632 = _6605 ^ (_6605 >> uvec3(16u));
                            uvec3 _12958;
                            _12958.x = _6632.x + (_6632.y * _6632.z);
                            uvec3 _12961 = _12958;
                            _12961.y = _12958.y + (_12958.z * _12958.x);
                            uvec3 _12964 = _12958;
                            _12964.z = _12958.z + (_12958.x * _12958.y);
                            uvec3 _6664 = ((_6442 + uvec3(1u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6664.x = _6664.x + (_6664.y * _6664.z);
                            _6664.y = _6664.y + (_6664.z * _6664.x);
                            _6664.z = _6664.z + (_6664.x * _6664.y);
                            uvec3 _6691 = _6664 ^ (_6664 >> uvec3(16u));
                            uvec3 _12976;
                            _12976.x = _6691.x + (_6691.y * _6691.z);
                            uvec3 _12979 = _12976;
                            _12979.y = _12976.y + (_12976.z * _12976.x);
                            uvec3 _12982 = _12976;
                            _12982.z = _12976.z + (_12976.x * _12976.y);
                            uvec3 _6723 = ((_6442 + uvec3(0u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6723.x = _6723.x + (_6723.y * _6723.z);
                            _6723.y = _6723.y + (_6723.z * _6723.x);
                            _6723.z = _6723.z + (_6723.x * _6723.y);
                            uvec3 _6750 = _6723 ^ (_6723 >> uvec3(16u));
                            uvec3 _12994;
                            _12994.x = _6750.x + (_6750.y * _6750.z);
                            uvec3 _12997 = _12994;
                            _12997.y = _12994.y + (_12994.z * _12994.x);
                            uvec3 _13000 = _12994;
                            _13000.z = _12994.z + (_12994.x * _12994.y);
                            uvec3 _6782 = ((_6442 + uvec3(1u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6782.x = _6782.x + (_6782.y * _6782.z);
                            _6782.y = _6782.y + (_6782.z * _6782.x);
                            _6782.z = _6782.z + (_6782.x * _6782.y);
                            uvec3 _6809 = _6782 ^ (_6782 >> uvec3(16u));
                            uvec3 _13012;
                            _13012.x = _6809.x + (_6809.y * _6809.z);
                            uvec3 _13015 = _13012;
                            _13015.y = _13012.y + (_13012.z * _13012.x);
                            uvec3 _13018 = _13012;
                            _13018.z = _13012.z + (_13012.x * _13012.y);
                            uvec3 _6841 = ((_6442 + uvec3(0u, 1u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6841.x = _6841.x + (_6841.y * _6841.z);
                            _6841.y = _6841.y + (_6841.z * _6841.x);
                            _6841.z = _6841.z + (_6841.x * _6841.y);
                            uvec3 _6868 = _6841 ^ (_6841 >> uvec3(16u));
                            uvec3 _13030;
                            _13030.x = _6868.x + (_6868.y * _6868.z);
                            uvec3 _13033 = _13030;
                            _13033.y = _13030.y + (_13030.z * _13030.x);
                            uvec3 _13036 = _13030;
                            _13036.z = _13030.z + (_13030.x * _13030.y);
                            uvec3 _6900 = ((_6442 + uvec3(1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _6900.x = _6900.x + (_6900.y * _6900.z);
                            _6900.y = _6900.y + (_6900.z * _6900.x);
                            _6900.z = _6900.z + (_6900.x * _6900.y);
                            uvec3 _6927 = _6900 ^ (_6900 >> uvec3(16u));
                            uvec3 _13048;
                            _13048.x = _6927.x + (_6927.y * _6927.z);
                            uvec3 _13051 = _13048;
                            _13051.y = _13048.y + (_13048.z * _13048.x);
                            uvec3 _13054 = _13048;
                            _13054.z = _13048.z + (_13048.x * _13048.y);
                            float _6466 = _6439.x;
                            float _6471 = _6439.y;
                            vec3 _5733 = _5834 * 23.0;
                            vec3 _6950 = floor(_5733);
                            vec3 _6951 = _5733 - _6950;
                            vec3 _6956 = (_6951 * _6951) * (vec3(3.0) - (_6951 * 2.0));
                            uvec3 _6959 = uvec3(ivec3(_6950) + ivec3(4096));
                            uvec3 _7004 = (_6959 * uvec3(1664525u)) + uvec3(1013904223u);
                            _7004.x = _7004.x + (_7004.y * _7004.z);
                            _7004.y = _7004.y + (_7004.z * _7004.x);
                            _7004.z = _7004.z + (_7004.x * _7004.y);
                            uvec3 _7031 = _7004 ^ (_7004 >> uvec3(16u));
                            uvec3 _13066;
                            _13066.x = _7031.x + (_7031.y * _7031.z);
                            uvec3 _13069 = _13066;
                            _13069.y = _13066.y + (_13066.z * _13066.x);
                            uvec3 _13072 = _13066;
                            _13072.z = _13066.z + (_13066.x * _13066.y);
                            uvec3 _7063 = ((_6959 + uvec3(1u, 0u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7063.x = _7063.x + (_7063.y * _7063.z);
                            _7063.y = _7063.y + (_7063.z * _7063.x);
                            _7063.z = _7063.z + (_7063.x * _7063.y);
                            uvec3 _7090 = _7063 ^ (_7063 >> uvec3(16u));
                            uvec3 _13084;
                            _13084.x = _7090.x + (_7090.y * _7090.z);
                            uvec3 _13087 = _13084;
                            _13087.y = _13084.y + (_13084.z * _13084.x);
                            uvec3 _13090 = _13084;
                            _13090.z = _13084.z + (_13084.x * _13084.y);
                            uvec3 _7122 = ((_6959 + uvec3(0u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7122.x = _7122.x + (_7122.y * _7122.z);
                            _7122.y = _7122.y + (_7122.z * _7122.x);
                            _7122.z = _7122.z + (_7122.x * _7122.y);
                            uvec3 _7149 = _7122 ^ (_7122 >> uvec3(16u));
                            uvec3 _13102;
                            _13102.x = _7149.x + (_7149.y * _7149.z);
                            uvec3 _13105 = _13102;
                            _13105.y = _13102.y + (_13102.z * _13102.x);
                            uvec3 _13108 = _13102;
                            _13108.z = _13102.z + (_13102.x * _13102.y);
                            uvec3 _7181 = ((_6959 + uvec3(1u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7181.x = _7181.x + (_7181.y * _7181.z);
                            _7181.y = _7181.y + (_7181.z * _7181.x);
                            _7181.z = _7181.z + (_7181.x * _7181.y);
                            uvec3 _7208 = _7181 ^ (_7181 >> uvec3(16u));
                            uvec3 _13120;
                            _13120.x = _7208.x + (_7208.y * _7208.z);
                            uvec3 _13123 = _13120;
                            _13123.y = _13120.y + (_13120.z * _13120.x);
                            uvec3 _13126 = _13120;
                            _13126.z = _13120.z + (_13120.x * _13120.y);
                            uvec3 _7240 = ((_6959 + uvec3(0u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7240.x = _7240.x + (_7240.y * _7240.z);
                            _7240.y = _7240.y + (_7240.z * _7240.x);
                            _7240.z = _7240.z + (_7240.x * _7240.y);
                            uvec3 _7267 = _7240 ^ (_7240 >> uvec3(16u));
                            uvec3 _13138;
                            _13138.x = _7267.x + (_7267.y * _7267.z);
                            uvec3 _13141 = _13138;
                            _13141.y = _13138.y + (_13138.z * _13138.x);
                            uvec3 _13144 = _13138;
                            _13144.z = _13138.z + (_13138.x * _13138.y);
                            uvec3 _7299 = ((_6959 + uvec3(1u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7299.x = _7299.x + (_7299.y * _7299.z);
                            _7299.y = _7299.y + (_7299.z * _7299.x);
                            _7299.z = _7299.z + (_7299.x * _7299.y);
                            uvec3 _7326 = _7299 ^ (_7299 >> uvec3(16u));
                            uvec3 _13156;
                            _13156.x = _7326.x + (_7326.y * _7326.z);
                            uvec3 _13159 = _13156;
                            _13159.y = _13156.y + (_13156.z * _13156.x);
                            uvec3 _13162 = _13156;
                            _13162.z = _13156.z + (_13156.x * _13156.y);
                            uvec3 _7358 = ((_6959 + uvec3(0u, 1u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7358.x = _7358.x + (_7358.y * _7358.z);
                            _7358.y = _7358.y + (_7358.z * _7358.x);
                            _7358.z = _7358.z + (_7358.x * _7358.y);
                            uvec3 _7385 = _7358 ^ (_7358 >> uvec3(16u));
                            uvec3 _13174;
                            _13174.x = _7385.x + (_7385.y * _7385.z);
                            uvec3 _13177 = _13174;
                            _13177.y = _13174.y + (_13174.z * _13174.x);
                            uvec3 _13180 = _13174;
                            _13180.z = _13174.z + (_13174.x * _13174.y);
                            uvec3 _7417 = ((_6959 + uvec3(1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7417.x = _7417.x + (_7417.y * _7417.z);
                            _7417.y = _7417.y + (_7417.z * _7417.x);
                            _7417.z = _7417.z + (_7417.x * _7417.y);
                            uvec3 _7444 = _7417 ^ (_7417 >> uvec3(16u));
                            uvec3 _13192;
                            _13192.x = _7444.x + (_7444.y * _7444.z);
                            uvec3 _13195 = _13192;
                            _13195.y = _13192.y + (_13192.z * _13192.x);
                            uvec3 _13198 = _13192;
                            _13198.z = _13192.z + (_13192.x * _13192.y);
                            float _6983 = _6956.x;
                            float _6988 = _6956.y;
                            vec3 _5738 = (_5834 * 14.0) + vec3(3.099999904632568359375, 7.69999980926513671875, 1.2999999523162841796875);
                            vec3 _7467 = floor(_5738);
                            vec3 _7468 = _5738 - _7467;
                            vec3 _7473 = (_7468 * _7468) * (vec3(3.0) - (_7468 * 2.0));
                            uvec3 _7476 = uvec3(ivec3(_7467) + ivec3(4096));
                            uvec3 _7521 = (_7476 * uvec3(1664525u)) + uvec3(1013904223u);
                            _7521.x = _7521.x + (_7521.y * _7521.z);
                            _7521.y = _7521.y + (_7521.z * _7521.x);
                            _7521.z = _7521.z + (_7521.x * _7521.y);
                            uvec3 _7548 = _7521 ^ (_7521 >> uvec3(16u));
                            uvec3 _13210;
                            _13210.x = _7548.x + (_7548.y * _7548.z);
                            uvec3 _13213 = _13210;
                            _13213.y = _13210.y + (_13210.z * _13210.x);
                            uvec3 _13216 = _13210;
                            _13216.z = _13210.z + (_13210.x * _13210.y);
                            uvec3 _7580 = ((_7476 + uvec3(1u, 0u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7580.x = _7580.x + (_7580.y * _7580.z);
                            _7580.y = _7580.y + (_7580.z * _7580.x);
                            _7580.z = _7580.z + (_7580.x * _7580.y);
                            uvec3 _7607 = _7580 ^ (_7580 >> uvec3(16u));
                            uvec3 _13228;
                            _13228.x = _7607.x + (_7607.y * _7607.z);
                            uvec3 _13231 = _13228;
                            _13231.y = _13228.y + (_13228.z * _13228.x);
                            uvec3 _13234 = _13228;
                            _13234.z = _13228.z + (_13228.x * _13228.y);
                            uvec3 _7639 = ((_7476 + uvec3(0u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7639.x = _7639.x + (_7639.y * _7639.z);
                            _7639.y = _7639.y + (_7639.z * _7639.x);
                            _7639.z = _7639.z + (_7639.x * _7639.y);
                            uvec3 _7666 = _7639 ^ (_7639 >> uvec3(16u));
                            uvec3 _13246;
                            _13246.x = _7666.x + (_7666.y * _7666.z);
                            uvec3 _13249 = _13246;
                            _13249.y = _13246.y + (_13246.z * _13246.x);
                            uvec3 _13252 = _13246;
                            _13252.z = _13246.z + (_13246.x * _13246.y);
                            uvec3 _7698 = ((_7476 + uvec3(1u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7698.x = _7698.x + (_7698.y * _7698.z);
                            _7698.y = _7698.y + (_7698.z * _7698.x);
                            _7698.z = _7698.z + (_7698.x * _7698.y);
                            uvec3 _7725 = _7698 ^ (_7698 >> uvec3(16u));
                            uvec3 _13264;
                            _13264.x = _7725.x + (_7725.y * _7725.z);
                            uvec3 _13267 = _13264;
                            _13267.y = _13264.y + (_13264.z * _13264.x);
                            uvec3 _13270 = _13264;
                            _13270.z = _13264.z + (_13264.x * _13264.y);
                            uvec3 _7757 = ((_7476 + uvec3(0u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7757.x = _7757.x + (_7757.y * _7757.z);
                            _7757.y = _7757.y + (_7757.z * _7757.x);
                            _7757.z = _7757.z + (_7757.x * _7757.y);
                            uvec3 _7784 = _7757 ^ (_7757 >> uvec3(16u));
                            uvec3 _13282;
                            _13282.x = _7784.x + (_7784.y * _7784.z);
                            uvec3 _13285 = _13282;
                            _13285.y = _13282.y + (_13282.z * _13282.x);
                            uvec3 _13288 = _13282;
                            _13288.z = _13282.z + (_13282.x * _13282.y);
                            uvec3 _7816 = ((_7476 + uvec3(1u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7816.x = _7816.x + (_7816.y * _7816.z);
                            _7816.y = _7816.y + (_7816.z * _7816.x);
                            _7816.z = _7816.z + (_7816.x * _7816.y);
                            uvec3 _7843 = _7816 ^ (_7816 >> uvec3(16u));
                            uvec3 _13300;
                            _13300.x = _7843.x + (_7843.y * _7843.z);
                            uvec3 _13303 = _13300;
                            _13303.y = _13300.y + (_13300.z * _13300.x);
                            uvec3 _13306 = _13300;
                            _13306.z = _13300.z + (_13300.x * _13300.y);
                            uvec3 _7875 = ((_7476 + uvec3(0u, 1u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7875.x = _7875.x + (_7875.y * _7875.z);
                            _7875.y = _7875.y + (_7875.z * _7875.x);
                            _7875.z = _7875.z + (_7875.x * _7875.y);
                            uvec3 _7902 = _7875 ^ (_7875 >> uvec3(16u));
                            uvec3 _13318;
                            _13318.x = _7902.x + (_7902.y * _7902.z);
                            uvec3 _13321 = _13318;
                            _13321.y = _13318.y + (_13318.z * _13318.x);
                            uvec3 _13324 = _13318;
                            _13324.z = _13318.z + (_13318.x * _13318.y);
                            uvec3 _7934 = ((_7476 + uvec3(1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                            _7934.x = _7934.x + (_7934.y * _7934.z);
                            _7934.y = _7934.y + (_7934.z * _7934.x);
                            _7934.z = _7934.z + (_7934.x * _7934.y);
                            uvec3 _7961 = _7934 ^ (_7934 >> uvec3(16u));
                            uvec3 _13336;
                            _13336.x = _7961.x + (_7961.y * _7961.z);
                            uvec3 _13339 = _13336;
                            _13339.y = _13336.y + (_13336.z * _13336.x);
                            uvec3 _13342 = _13336;
                            _13342.z = _13336.z + (_13336.x * _13336.y);
                            float _7500 = _7473.x;
                            float _7505 = _7473.y;
                            float _5741 = ((0.550000011920928955078125 * mix(mix(mix((vec3(_12922) * 2.3283064365386962890625e-10).x, (vec3(_12940) * 2.3283064365386962890625e-10).x, _6466), mix((vec3(_12958) * 2.3283064365386962890625e-10).x, (vec3(_12976) * 2.3283064365386962890625e-10).x, _6466), _6471), mix(mix((vec3(_12994) * 2.3283064365386962890625e-10).x, (vec3(_13012) * 2.3283064365386962890625e-10).x, _6466), mix((vec3(_13030) * 2.3283064365386962890625e-10).x, (vec3(_13048) * 2.3283064365386962890625e-10).x, _6466), _6471), _6439.z)) + (0.449999988079071044921875 * mix(mix(mix((vec3(_13066) * 2.3283064365386962890625e-10).x, (vec3(_13084) * 2.3283064365386962890625e-10).x, _6983), mix((vec3(_13102) * 2.3283064365386962890625e-10).x, (vec3(_13120) * 2.3283064365386962890625e-10).x, _6983), _6988), mix(mix((vec3(_13138) * 2.3283064365386962890625e-10).x, (vec3(_13156) * 2.3283064365386962890625e-10).x, _6983), mix((vec3(_13174) * 2.3283064365386962890625e-10).x, (vec3(_13192) * 2.3283064365386962890625e-10).x, _6983), _6988), _6956.z))) * 1.2999999523162841796875;
                            vec3 _5753 = (((_5836 + (_6134 * 0.119999997317790985107421875)) + (vec3(0.85000002384185791015625, 0.89999997615814208984375, 1.0) * (((exp((_5725 * _5725) * (-41.322315216064453125)) * clamp(_5741 - 0.25, 0.0, 1.0)) * (1.0 - (0.60000002384185791015625 * smoothstep(0.3499999940395355224609375, 0.75, mix(mix(mix((vec3(_13210) * 2.3283064365386962890625e-10).x, (vec3(_13228) * 2.3283064365386962890625e-10).x, _7500), mix((vec3(_13246) * 2.3283064365386962890625e-10).x, (vec3(_13264) * 2.3283064365386962890625e-10).x, _7500), _7505), mix(mix((vec3(_13282) * 2.3283064365386962890625e-10).x, (vec3(_13300) * 2.3283064365386962890625e-10).x, _7500), mix((vec3(_13318) * 2.3283064365386962890625e-10).x, (vec3(_13336) * 2.3283064365386962890625e-10).x, _7500), _7505), _7473.z))))) * 0.01200000010430812835693359375))) * light.stars.x) * (_5704 * _5704);
                            _5700 = _5753;
                        }
                        else
                        {
                            _5700 = vec3(0.0);
                        }
                        if (light.moon.w > 0.0)
                        {
                            float _5757 = dot(_543, _798);
                            float _5759 = 2.0 - (2.0 * _5757);
                            float _5761 = sqrt(isnan(0.0) ? _5759 : (isnan(_5759) ? 0.0 : max(_5759, 0.0)));
                            float _5762 = isnan(0.0005249999812804162502288818359375) ? pixelAngle : (isnan(pixelAngle) ? 0.0005249999812804162502288818359375 : max(pixelAngle, 0.0005249999812804162502288818359375));
                            float _5766 = 1.0 - smoothstep(0.010499999858438968658447265625 - _5762, 0.010499999858438968658447265625 + _5762, _5761);
                            if (_5766 > 0.0)
                            {
                                float _5770 = clamp(_5761 * 95.23809814453125, 0.0, 1.0);
                                float _5772 = 1.0 - (_5770 * _5770);
                                vec3 _5781 = (((_543 - _798) * vec3(95.23809814453125)) * 1.60000002384185791015625) + vec3(11.0, 5.0, 2.0);
                                vec3 _7984 = floor(_5781);
                                vec3 _7985 = _5781 - _7984;
                                vec3 _7990 = (_7985 * _7985) * (vec3(3.0) - (_7985 * 2.0));
                                uvec3 _7993 = uvec3(ivec3(_7984) + ivec3(4096));
                                uvec3 _8038 = (_7993 * uvec3(1664525u)) + uvec3(1013904223u);
                                _8038.x = _8038.x + (_8038.y * _8038.z);
                                _8038.y = _8038.y + (_8038.z * _8038.x);
                                _8038.z = _8038.z + (_8038.x * _8038.y);
                                uvec3 _8065 = _8038 ^ (_8038 >> uvec3(16u));
                                uvec3 _13354;
                                _13354.x = _8065.x + (_8065.y * _8065.z);
                                uvec3 _13357 = _13354;
                                _13357.y = _13354.y + (_13354.z * _13354.x);
                                uvec3 _13360 = _13354;
                                _13360.z = _13354.z + (_13354.x * _13354.y);
                                uvec3 _8097 = ((_7993 + uvec3(1u, 0u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8097.x = _8097.x + (_8097.y * _8097.z);
                                _8097.y = _8097.y + (_8097.z * _8097.x);
                                _8097.z = _8097.z + (_8097.x * _8097.y);
                                uvec3 _8124 = _8097 ^ (_8097 >> uvec3(16u));
                                uvec3 _13372;
                                _13372.x = _8124.x + (_8124.y * _8124.z);
                                uvec3 _13375 = _13372;
                                _13375.y = _13372.y + (_13372.z * _13372.x);
                                uvec3 _13378 = _13372;
                                _13378.z = _13372.z + (_13372.x * _13372.y);
                                uvec3 _8156 = ((_7993 + uvec3(0u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8156.x = _8156.x + (_8156.y * _8156.z);
                                _8156.y = _8156.y + (_8156.z * _8156.x);
                                _8156.z = _8156.z + (_8156.x * _8156.y);
                                uvec3 _8183 = _8156 ^ (_8156 >> uvec3(16u));
                                uvec3 _13390;
                                _13390.x = _8183.x + (_8183.y * _8183.z);
                                uvec3 _13393 = _13390;
                                _13393.y = _13390.y + (_13390.z * _13390.x);
                                uvec3 _13396 = _13390;
                                _13396.z = _13390.z + (_13390.x * _13390.y);
                                uvec3 _8215 = ((_7993 + uvec3(1u, 1u, 0u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8215.x = _8215.x + (_8215.y * _8215.z);
                                _8215.y = _8215.y + (_8215.z * _8215.x);
                                _8215.z = _8215.z + (_8215.x * _8215.y);
                                uvec3 _8242 = _8215 ^ (_8215 >> uvec3(16u));
                                uvec3 _13408;
                                _13408.x = _8242.x + (_8242.y * _8242.z);
                                uvec3 _13411 = _13408;
                                _13411.y = _13408.y + (_13408.z * _13408.x);
                                uvec3 _13414 = _13408;
                                _13414.z = _13408.z + (_13408.x * _13408.y);
                                uvec3 _8274 = ((_7993 + uvec3(0u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8274.x = _8274.x + (_8274.y * _8274.z);
                                _8274.y = _8274.y + (_8274.z * _8274.x);
                                _8274.z = _8274.z + (_8274.x * _8274.y);
                                uvec3 _8301 = _8274 ^ (_8274 >> uvec3(16u));
                                uvec3 _13426;
                                _13426.x = _8301.x + (_8301.y * _8301.z);
                                uvec3 _13429 = _13426;
                                _13429.y = _13426.y + (_13426.z * _13426.x);
                                uvec3 _13432 = _13426;
                                _13432.z = _13426.z + (_13426.x * _13426.y);
                                uvec3 _8333 = ((_7993 + uvec3(1u, 0u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8333.x = _8333.x + (_8333.y * _8333.z);
                                _8333.y = _8333.y + (_8333.z * _8333.x);
                                _8333.z = _8333.z + (_8333.x * _8333.y);
                                uvec3 _8360 = _8333 ^ (_8333 >> uvec3(16u));
                                uvec3 _13444;
                                _13444.x = _8360.x + (_8360.y * _8360.z);
                                uvec3 _13447 = _13444;
                                _13447.y = _13444.y + (_13444.z * _13444.x);
                                uvec3 _13450 = _13444;
                                _13450.z = _13444.z + (_13444.x * _13444.y);
                                uvec3 _8392 = ((_7993 + uvec3(0u, 1u, 1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8392.x = _8392.x + (_8392.y * _8392.z);
                                _8392.y = _8392.y + (_8392.z * _8392.x);
                                _8392.z = _8392.z + (_8392.x * _8392.y);
                                uvec3 _8419 = _8392 ^ (_8392 >> uvec3(16u));
                                uvec3 _13462;
                                _13462.x = _8419.x + (_8419.y * _8419.z);
                                uvec3 _13465 = _13462;
                                _13465.y = _13462.y + (_13462.z * _13462.x);
                                uvec3 _13468 = _13462;
                                _13468.z = _13462.z + (_13462.x * _13462.y);
                                uvec3 _8451 = ((_7993 + uvec3(1u)) * uvec3(1664525u)) + uvec3(1013904223u);
                                _8451.x = _8451.x + (_8451.y * _8451.z);
                                _8451.y = _8451.y + (_8451.z * _8451.x);
                                _8451.z = _8451.z + (_8451.x * _8451.y);
                                uvec3 _8478 = _8451 ^ (_8451 >> uvec3(16u));
                                uvec3 _13480;
                                _13480.x = _8478.x + (_8478.y * _8478.z);
                                uvec3 _13483 = _13480;
                                _13483.y = _13480.y + (_13480.z * _13480.x);
                                uvec3 _13486 = _13480;
                                _13486.z = _13480.z + (_13480.x * _13480.y);
                                float _8017 = _7990.x;
                                float _8022 = _7990.y;
                                vec3 _5793 = vec3(1.0, 0.980000019073486328125, 0.939999997615814208984375) * ((((light.moon.w * _5766) * (0.62000000476837158203125 + (0.37999999523162841796875 * sqrt(isnan(0.0) ? _5772 : (isnan(_5772) ? 0.0 : max(_5772, 0.0)))))) * (1.0 - (0.2800000011920928955078125 * smoothstep(0.449999988079071044921875, 0.800000011920928955078125, mix(mix(mix((vec3(_13354) * 2.3283064365386962890625e-10).x, (vec3(_13372) * 2.3283064365386962890625e-10).x, _8017), mix((vec3(_13390) * 2.3283064365386962890625e-10).x, (vec3(_13408) * 2.3283064365386962890625e-10).x, _8017), _8022), mix(mix((vec3(_13426) * 2.3283064365386962890625e-10).x, (vec3(_13444) * 2.3283064365386962890625e-10).x, _8017), mix((vec3(_13462) * 2.3283064365386962890625e-10).x, (vec3(_13480) * 2.3283064365386962890625e-10).x, _8017), _8022), _7990.z))))) * clamp(1.0 - (light.stars.y * 1.5), 0.0, 1.0));
                                _5700 += _5793;
                            }
                            float _5797 = clamp(_5757, 0.0, 1.0);
                            _5700 += ((vec3(0.819999992847442626953125, 0.87999999523162841796875, 1.0) * light.moon.w) * ((((pow(_5797, 6000.0) * 0.006000000052154064178466796875) * _5704) + (pow(_5797, 180.0) * 0.0003000000142492353916168212890625)) + ((pow(_5797, 18.0) * 0.000600000028498470783233642578125) * light.stars.y)));
                        }
                        sunLight = background + (_5700 * _5616);
                    }
                    else
                    {
                        sunLight = background;
                    }
                    vec3 _8500;
                    {
                        if (gi.fog.z <= 0.0)
                        {
                            _8500 = sunLight;
                        }
                        else
                        {
                            float _8515 = (gi.unproject.w * gi.fog.x) + gi.fog.y;
                            vec4 _8530 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _8515 : (isnan(_8515) ? 9.9999999747524270787835121154785e-07 : max(_8515, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                            _8500 = (sunLight * _8530.w) + _8530.xyz;
                        }
                    }
                    entryPointParam_fragmentMain = vec4(_8500, 1.0);
                }
            }
        }
        else
        {
            vec4 _154;
            if ((int((_5399.w * 255.0) + 0.5) & 15) == 0)
            {
                if (debugView != 0)
                {
                    _152 = debugView != 11;
                }
                else
                {
                    _152 = false;
                }
                if (_152)
                {
                    if (debugView == 1)
                    {
                        _154 = vec4(albedo, 1.0);
                    }
                    else
                    {
                        _154 = vec4(0.0, 0.0, 0.0, 1.0);
                    }
                    entryPointParam_fragmentMain = _154;
                }
                else
                {
                    float _8560 = ((2.0 * gi.unproject.z) * gi.unproject.w) / ((gi.unproject.w + gi.unproject.z) - ((1.0 - (2.0 * depth)) * (gi.unproject.w - gi.unproject.z)));
                    vec2 _8563 = (input_uv * 2.0) - vec2(1.0);
                    vec3 _8575 = vec3(_13488, _13488, _8560);
                    float viewZ = _8575.z;
                    float _8581 = (_5399.y * 255.0) - 128.0;
                    float _8576;
                    if (_8581 > 0.5)
                    {
                        _8576 = _8581 * 0.0625;
                    }
                    else
                    {
                        _8576 = 1.0;
                    }
                    vec3 _1634 = albedo * _8576;
                    vec3 _8589;
                    {
                        bool _8590;
                        if (light.retailFog.w <= 0.0)
                        {
                            _8590 = true;
                        }
                        else
                        {
                            _8590 = gi.fog.z > 0.0;
                        }
                        if (_8590)
                        {
                            _8589 = _1634;
                        }
                        else
                        {
                            _8589 = mix(light.retailFog.xyz, _1634, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? viewZ : (isnan(viewZ) ? 0.0 : max(viewZ, 0.0)))), 0.0, 1.0)));
                        }
                    }
                    vec3 _8622;
                    {
                        if (gi.fog.z <= 0.0)
                        {
                            _8622 = _8589;
                        }
                        else
                        {
                            float _8637 = (viewZ * gi.fog.x) + gi.fog.y;
                            vec4 _8652 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _8637 : (isnan(_8637) ? 9.9999999747524270787835121154785e-07 : max(_8637, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                            _8622 = (_8589 * _8652.w) + _8652.xyz;
                        }
                    }
                    entryPointParam_fragmentMain = vec4(_8622, 1.0);
                }
            }
            else
            {
                vec3 normal = normalize((texelFetch(_13515, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0).xyz * 2.0) - vec3(1.0));
                int model = int(light.sunDirectionModel.w + 0.5);
                if (debugView == 1)
                {
                    entryPointParam_fragmentMain = vec4(albedo, 1.0);
                }
                else
                {
                    if (debugView == 2)
                    {
                        entryPointParam_fragmentMain = vec4((normal * 0.5) + vec3(0.5), 1.0);
                    }
                    else
                    {
                        if (debugView == 3)
                        {
                            float _8691 = ((2.0 * gi.unproject.z) * gi.unproject.w) / ((gi.unproject.w + gi.unproject.z) - ((1.0 - (2.0 * depth)) * (gi.unproject.w - gi.unproject.z)));
                            vec2 _8694 = (input_uv * 2.0) - vec2(1.0);
                            float _1733 = pow(clamp(vec3(_13488, _13488, _8691).z * 0.0024999999441206455230712890625, 0.0, 1.0), 0.4544999897480010986328125);
                            entryPointParam_fragmentMain = vec4(_1733, _1733, _1733, 1.0);
                        }
                        else
                        {
                            if (debugView == 4)
                            {
                                entryPointParam_fragmentMain = vec4(_5399.zxw, 1.0);
                            }
                            else
                            {
                                if (debugView == 6)
                                {
                                    entryPointParam_fragmentMain = vec4(baked, 1.0);
                                }
                                else
                                {
                                    if (debugView == 7)
                                    {
                                        entryPointParam_fragmentMain = vec4(textureLod(_13517, input_uv, 0.0).xxx, 1.0);
                                    }
                                    else
                                    {
                                        if (debugView == 8)
                                        {
                                            entryPointParam_fragmentMain = vec4(textureLod(_13519, input_uv, 0.0).xyz * gi.giParams.x, 1.0);
                                        }
                                        else
                                        {
                                            if (debugView == 18)
                                            {
                                                entryPointParam_fragmentMain = vec4(_5399.zzz, 1.0);
                                            }
                                            else
                                            {
                                                if (debugView == 19)
                                                {
                                                    entryPointParam_fragmentMain = vec4(_5399.xxx, 1.0);
                                                }
                                                else
                                                {
                                                    if (debugView == 20)
                                                    {
                                                        entryPointParam_fragmentMain = vec4(_5390.www, 1.0);
                                                    }
                                                    else
                                                    {
                                                        if (debugView == 11)
                                                        {
                                                            albedo = vec3(0.180000007152557373046875);
                                                        }
                                                        if (debugView == 28)
                                                        {
                                                            float _8708;
                                                            {
                                                                if (gi.flashlight.control.x <= 0.5)
                                                                {
                                                                    _8708 = 1.0;
                                                                }
                                                                else
                                                                {
                                                                    _8708 = clamp(texelFetch(_13522, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0).x, 0.0, 1.0);
                                                                }
                                                            }
                                                            entryPointParam_fragmentMain = vec4(_8708, _8708, _8708, 1.0);
                                                        }
                                                        else
                                                        {
                                                            float _8745 = ((2.0 * gi.unproject.z) * gi.unproject.w) / ((gi.unproject.w + gi.unproject.z) - ((1.0 - (2.0 * depth)) * (gi.unproject.w - gi.unproject.z)));
                                                            vec2 _8748 = (input_uv * 2.0) - vec2(1.0);
                                                            vec3 _8760 = vec3((_8748.x * _8745) / gi.unproject.x, ((-_8748.y) * _8745) / gi.unproject.y, _8745);
                                                            vec3 flashDir;
                                                            vec3 _8762;
                                                            {
                                                                flashDir = vec3(0.0, 0.0, 1.0);
                                                                if (!(gi.flashlight.position.w > 0.0))
                                                                {
                                                                    _8762 = vec3(0.0);
                                                                }
                                                                else
                                                                {
                                                                    vec3 _8763;
                                                                    vec3 _8800;
                                                                    {
                                                                        vec3 _8810 = _8760 - gi.flashlight.position.xyz;
                                                                        float _8811 = dot(_8810, _8810);
                                                                        float _8813 = sqrt(isnan(9.9999999392252902907785028219223e-09) ? _8811 : (isnan(_8811) ? 9.9999999392252902907785028219223e-09 : max(_8811, 9.9999999392252902907785028219223e-09)));
                                                                        float _8764 = _8813;
                                                                        _8763 = (-_8810) / vec3(_8813);
                                                                        bool _8801;
                                                                        if (gi.flashlight.position.w <= 0.0)
                                                                        {
                                                                            _8801 = true;
                                                                        }
                                                                        else
                                                                        {
                                                                            _8801 = _8764 >= gi.flashlight.position.w;
                                                                        }
                                                                        if (_8801)
                                                                        {
                                                                            _8800 = vec3(0.0);
                                                                        }
                                                                        else
                                                                        {
                                                                            vec3 _8828 = -_8763;
                                                                            float _8867;
                                                                            {
                                                                                float _8877 = dot(gi.flashlight.axis.xyz, _8828);
                                                                                bool _8868;
                                                                                if (_8877 <= gi.flashlight.axis.w)
                                                                                {
                                                                                    _8868 = true;
                                                                                }
                                                                                else
                                                                                {
                                                                                    _8868 = _8877 <= 0.0;
                                                                                }
                                                                                if (_8868)
                                                                                {
                                                                                    _8867 = 0.0;
                                                                                }
                                                                                else
                                                                                {
                                                                                    float _8888 = 1.0 - (_8877 * _8877);
                                                                                    float _8896 = (sqrt(isnan(0.0) ? _8888 : (isnan(_8888) ? 0.0 : max(_8888, 0.0))) / _8877) / (isnan(9.9999997473787516355514526367188e-05) ? gi.flashlight.cone.x : (isnan(gi.flashlight.cone.x) ? 9.9999997473787516355514526367188e-05 : max(gi.flashlight.cone.x, 9.9999997473787516355514526367188e-05)));
                                                                                    float _8901 = (0.300000011920928955078125 * gi.flashlight.cone.y) * gi.flashlight.cone.y;
                                                                                    float _8908 = _8896 - 0.86000001430511474609375;
                                                                                    vec3 _8920 = cross(gi.flashlight.up.xyz, gi.flashlight.axis.xyz);
                                                                                    float _8921 = length(_8920);
                                                                                    vec3 _8869;
                                                                                    if (_8921 > 9.9999997473787516355514526367188e-05)
                                                                                    {
                                                                                        _8869 = _8920 / vec3(_8921);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        _8869 = vec3(1.0, 0.0, 0.0);
                                                                                    }
                                                                                    float _8934 = atan(dot(_8828, cross(gi.flashlight.axis.xyz, _8869)), dot(_8828, _8869) + 9.9999999747524270787835121154785e-07);
                                                                                    float _8953 = ((((0.550000011920928955078125 * exp(-((_8896 * _8896) / (isnan(9.9999997473787516355514526367188e-05) ? _8901 : (isnan(_8901) ? 9.9999997473787516355514526367188e-05 : max(_8901, 9.9999997473787516355514526367188e-05)))))) + (0.449999988079071044921875 * (1.0 - smoothstep(gi.flashlight.cone.y, 1.0, _8896)))) + (0.070000000298023223876953125 * exp((_8908 * _8908) * (-249.9999847412109375)))) * ((1.0 + ((0.04500000178813934326171875 * _8896) * sin((5.0 * _8934) + 1.2999999523162841796875))) + (0.02999999932944774627685546875 * sin((33.0 * _8896) + (2.0 * _8934))))) + ((1.0 - smoothstep(1.0, gi.flashlight.cone.z, _8896)) * gi.flashlight.cone.w);
                                                                                    _8867 = isnan(0.0) ? _8953 : (isnan(_8953) ? 0.0 : max(_8953, 0.0));
                                                                                }
                                                                            }
                                                                            if (_8867 <= 0.0)
                                                                            {
                                                                                _8800 = vec3(0.0);
                                                                            }
                                                                            else
                                                                            {
                                                                                float _8834 = _8811 / (gi.flashlight.position.w * gi.flashlight.position.w);
                                                                                float _8837 = clamp(1.0 - (_8834 * _8834), 0.0, 1.0);
                                                                                if (true)
                                                                                {
                                                                                    _8801 = _8764 > 5.0;
                                                                                }
                                                                                else
                                                                                {
                                                                                    _8801 = false;
                                                                                }
                                                                                float _8802;
                                                                                if (_8801)
                                                                                {
                                                                                    _8802 = pow(_8764 * 0.20000000298023223876953125, gi.flashlight.control.z);
                                                                                }
                                                                                else
                                                                                {
                                                                                    _8802 = 1.0;
                                                                                }
                                                                                _8800 = gi.flashlight.colour.xyz * (((_8867 * (_8837 * _8837)) * _8802) / (isnan(gi.flashlight.colour.w) ? _8811 : (isnan(_8811) ? gi.flashlight.colour.w : max(_8811, gi.flashlight.colour.w))));
                                                                            }
                                                                        }
                                                                    }
                                                                    if (all(lessThanEqual(_8800, vec3(0.0))))
                                                                    {
                                                                        _8762 = vec3(0.0);
                                                                    }
                                                                    else
                                                                    {
                                                                        vec3 _8783 = normalize((vec4(_8763, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz);
                                                                        flashDir = _8783;
                                                                        if (dot(normal, _8783) <= 0.0)
                                                                        {
                                                                            _8762 = vec3(0.0);
                                                                        }
                                                                        else
                                                                        {
                                                                            float _8958;
                                                                            {
                                                                                if (gi.flashlight.control.x <= 0.5)
                                                                                {
                                                                                    _8958 = 1.0;
                                                                                }
                                                                                else
                                                                                {
                                                                                    _8958 = clamp(texelFetch(_13522, ivec3(ivec2(gl_FragCoord.xy), 0).xy, 0).x, 0.0, 1.0);
                                                                                }
                                                                            }
                                                                            _8762 = _8800 * _8958;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            float _2093 = dot(normal, flashDir);
                                                            vec3 flashDiffuse = (albedo * _8762) * (isnan(0.0) ? _2093 : (isnan(_2093) ? 0.0 : max(_2093, 0.0)));
                                                            if (model == 0)
                                                            {
                                                                vec3 _2100 = (albedo * baked) + flashDiffuse;
                                                                float _2101 = _8760.z;
                                                                vec3 _8981;
                                                                {
                                                                    bool _8982;
                                                                    if (light.retailFog.w <= 0.0)
                                                                    {
                                                                        _8982 = true;
                                                                    }
                                                                    else
                                                                    {
                                                                        _8982 = gi.fog.z > 0.0;
                                                                    }
                                                                    if (_8982)
                                                                    {
                                                                        _8981 = _2100;
                                                                    }
                                                                    else
                                                                    {
                                                                        _8981 = mix(light.retailFog.xyz, _2100, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _2101 : (isnan(_2101) ? 0.0 : max(_2101, 0.0)))), 0.0, 1.0)));
                                                                    }
                                                                }
                                                                vec3 _9014;
                                                                {
                                                                    if (gi.fog.z <= 0.0)
                                                                    {
                                                                        _9014 = _8981;
                                                                    }
                                                                    else
                                                                    {
                                                                        float _9029 = (_2101 * gi.fog.x) + gi.fog.y;
                                                                        vec4 _9044 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _9029 : (isnan(_9029) ? 9.9999999747524270787835121154785e-07 : max(_9029, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                        _9014 = (_8981 * _9044.w) + _9044.xyz;
                                                                    }
                                                                }
                                                                entryPointParam_fragmentMain = vec4(_9014, 1.0);
                                                            }
                                                            else
                                                            {
                                                                vec3 _2114 = normalize((vec4(light.sunDirectionModel.xyz, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz);
                                                                float _2116 = dot(normal, _2114);
                                                                float _2117 = isnan(0.0) ? _2116 : (isnan(_2116) ? 0.0 : max(_2116, 0.0));
                                                                if (_2117 > 0.0)
                                                                {
                                                                    _152 = true;
                                                                }
                                                                else
                                                                {
                                                                    _152 = debugView == 12;
                                                                }
                                                                float visibility;
                                                                if (_152)
                                                                {
                                                                    if (gi.probeMisc.w > 0.5)
                                                                    {
                                                                        visibility = textureLod(_13529, input_uv, 0.0).x;
                                                                    }
                                                                    else
                                                                    {
                                                                        _9052 = false;
                                                                        float _9053;
                                                                        {
                                                                            int _9066 = int(gi.shadowConfig.x + 0.5);
                                                                            if (_9066 <= 0)
                                                                            {
                                                                                _9052 = true;
                                                                                _9053 = 1.0;
                                                                            }
                                                                            else
                                                                            {
                                                                                float _9073 = isnan(1.0) ? gi.probeSky.w : (isnan(gi.probeSky.w) ? 1.0 : max(gi.probeSky.w, 1.0));
                                                                                vec3 _9078 = (vec4(_8760, 1.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz;
                                                                                int _9054 = 0;
                                                                                bool _9055;
                                                                                float _9056;
                                                                                float _9057;
                                                                                bool _9058;
                                                                                float _9154;
                                                                                float _9162;
                                                                                float _9337;
                                                                                int _9338;
                                                                                float _9339;
                                                                                float _9452;
                                                                                float _9460;
                                                                                float _9635;
                                                                                int _9636;
                                                                                float _9637;
                                                                                for (;;)
                                                                                {
                                                                                    bool _9081_ladder_break = false;
                                                                                    {
                                                                                        if (!(_9054 < 4))
                                                                                        {
                                                                                            _9081_ladder_break = true;
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            if (_9054 >= _9066)
                                                                                            {
                                                                                                _9081_ladder_break = true;
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                float _9091 = _8760.z;
                                                                                                if (!(_9091 > gi.cascadeSplits[_9054]))
                                                                                                {
                                                                                                    {
                                                                                                        float _9177 = length(vec3(spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054])[0].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054])[1].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054])[2].x));
                                                                                                        float _9182 = length(vec3(spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054])[0].z, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054])[1].z, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054])[2].z));
                                                                                                        float _9188 = (2.0 * gi.shadowConfig.w) / (isnan(9.9999999747524270787835121154785e-07) ? _9177 : (isnan(_9177) ? 9.9999999747524270787835121154785e-07 : max(_9177, 9.9999999747524270787835121154785e-07)));
                                                                                                        float _9190 = 2.0 / (isnan(9.9999999747524270787835121154785e-07) ? _9182 : (isnan(_9182) ? 9.9999999747524270787835121154785e-07 : max(_9182, 9.9999999747524270787835121154785e-07)));
                                                                                                        vec4 _9197 = vec4(_9078 + (normal * (gi.shadowConfig.z * _9188)), 1.0) * spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9054]);
                                                                                                        vec3 _9201 = _9197.xyz / vec3(_9197.w);
                                                                                                        bool _9205 = all(lessThanEqual(abs(_9201.xy), vec2(1.0)));
                                                                                                        _9055 = _9205;
                                                                                                        if (!_9205)
                                                                                                        {
                                                                                                            _9154 = 1.0;
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            float _9216 = ((_9201.z * 0.5) + 0.5) - ((gi.shadowConfig.y * _9188) / _9190);
                                                                                                            float _9229 = length(vec3(spvWorkaroundRowMajor(gi.cascadeMatrix.data[0])[0].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[0])[1].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[0])[2].x));
                                                                                                            float _9234 = (_9073 * ((2.0 * gi.shadowConfig.w) / (isnan(9.9999999747524270787835121154785e-07) ? _9229 : (isnan(_9229) ? 9.9999999747524270787835121154785e-07 : max(_9229, 9.9999999747524270787835121154785e-07))))) / (isnan(9.9999999747524270787835121154785e-07) ? _9188 : (isnan(_9188) ? 9.9999999747524270787835121154785e-07 : max(_9188, 9.9999999747524270787835121154785e-07)));
                                                                                                            float _9235 = isnan(1.0) ? _9234 : (isnan(_9234) ? 1.0 : max(_9234, 1.0));
                                                                                                            vec2 _9242 = vec2((_9201.x * 0.5) + 0.5, 0.5 - (_9201.y * 0.5));
                                                                                                            uvec3 _9244 = uvec3(textureSize(_13525, 0));
                                                                                                            ivec2 _9252 = ivec2(int(_9244.x), int(_9244.y));
                                                                                                            float _9255 = clamp(0.140399992465972900390625 / (isnan(9.9999999747524270787835121154785e-07) ? _9188 : (isnan(_9188) ? 9.9999999747524270787835121154785e-07 : max(_9188, 9.9999999747524270787835121154785e-07))), 2.0, 16.0);
                                                                                                            float _9258 = fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy + vec2(7.0, 3.0), vec2(0.067110560834407806396484375, 0.005837149918079376220703125)))) * 6.283185482025146484375;
                                                                                                            float _9259 = sin(_9258);
                                                                                                            float _9260 = cos(_9258);
                                                                                                            int _9158 = 0;
                                                                                                            float _9159 = 0.0;
                                                                                                            float _9160 = 0.0;
                                                                                                            for (;;)
                                                                                                            {
                                                                                                                if (!(_9158 < 12))
                                                                                                                {
                                                                                                                    break;
                                                                                                                }
                                                                                                                vec4 _9295 = texelFetch(_13525, ivec4(clamp(ivec2((_9242 + (vec2((_2384_frag[_9158].x * _9260) - (_2384_frag[_9158].y * _9259), (_2384_frag[_9158].x * _9259) + (_2384_frag[_9158].y * _9260)) * (_9255 * gi.shadowConfig.w))) * vec2(_9252)), ivec2(0), _9252 - ivec2(1)), _9054, 0).xyz, 0);
                                                                                                                float _9296 = _9295.x;
                                                                                                                if (_9296 < _9216)
                                                                                                                {
                                                                                                                    _9159 += (_9216 - _9296);
                                                                                                                    _9160 += 1.0;
                                                                                                                }
                                                                                                                _9158++;
                                                                                                                continue;
                                                                                                            }
                                                                                                            if (_9160 > 0.0)
                                                                                                            {
                                                                                                                float _9321 = (((_9159 / _9160) * _9190) * 0.0046799997799098491668701171875) / (isnan(9.9999999747524270787835121154785e-07) ? _9188 : (isnan(_9188) ? 9.9999999747524270787835121154785e-07 : max(_9188, 9.9999999747524270787835121154785e-07)));
                                                                                                                _9162 = clamp(isnan(_9321) ? _9235 : (isnan(_9235) ? _9321 : max(_9235, _9321)), 1.0, 24.0);
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                _9162 = _9235;
                                                                                                            }
                                                                                                            vec3 _9325 = vec3(_9242, _9216);
                                                                                                            {
                                                                                                                if (_9162 <= 1.5)
                                                                                                                {
                                                                                                                    _9338 = -1;
                                                                                                                    _9339 = 0.0;
                                                                                                                    for (;;)
                                                                                                                    {
                                                                                                                        if (!(_9338 <= 1))
                                                                                                                        {
                                                                                                                            break;
                                                                                                                        }
                                                                                                                        int _9340 = -1;
                                                                                                                        for (;;)
                                                                                                                        {
                                                                                                                            if (!(_9340 <= 1))
                                                                                                                            {
                                                                                                                                break;
                                                                                                                            }
                                                                                                                            int _9367 = _9340;
                                                                                                                            _9340++;
                                                                                                                            _9339 += spvShadowLod0(_13527, vec4(vec3(_9325.xy + (vec2(float(_9367), float(_9338)) * gi.shadowConfig.w), float(_9054)), _9216));
                                                                                                                            continue;
                                                                                                                        }
                                                                                                                        _9338++;
                                                                                                                        continue;
                                                                                                                    }
                                                                                                                    _9337 = _9339 * 0.111111111938953399658203125;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    float _9399 = fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125)))) * 6.283185482025146484375;
                                                                                                                    float _9400 = sin(_9399);
                                                                                                                    float _9401 = cos(_9399);
                                                                                                                    float _9402 = _9162 * gi.shadowConfig.w;
                                                                                                                    _9338 = 0;
                                                                                                                    _9339 = 0.0;
                                                                                                                    for (;;)
                                                                                                                    {
                                                                                                                        if (!(_9338 < 12))
                                                                                                                        {
                                                                                                                            break;
                                                                                                                        }
                                                                                                                        int _9411 = _9338;
                                                                                                                        _9338++;
                                                                                                                        _9339 += spvShadowLod0(_13527, vec4(vec3(_9325.xy + (vec2((_2384_frag[_9411].x * _9401) - (_2384_frag[_9411].y * _9400), (_2384_frag[_9411].x * _9400) + (_2384_frag[_9411].y * _9401)) * _9402), float(_9054)), _9216));
                                                                                                                        continue;
                                                                                                                    }
                                                                                                                    _9337 = _9339 * 0.083333335816860198974609375;
                                                                                                                }
                                                                                                            }
                                                                                                            _9154 = _9337;
                                                                                                        }
                                                                                                    }
                                                                                                    if (!(!_9055))
                                                                                                    {
                                                                                                        if (_9054 == 0)
                                                                                                        {
                                                                                                            _9056 = 0.0;
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            _9056 = gi.cascadeSplits[_9054 - 1];
                                                                                                        }
                                                                                                        float _9115 = _9056;
                                                                                                        float _9117 = (gi.cascadeSplits[_9054] - _9115) * 0.100000001490116119384765625;
                                                                                                        float _9118 = isnan(0.001000000047497451305389404296875) ? _9117 : (isnan(_9117) ? 0.001000000047497451305389404296875 : max(_9117, 0.001000000047497451305389404296875));
                                                                                                        float _9123 = clamp((_9091 - (gi.cascadeSplits[_9054] - _9118)) / _9118, 0.0, 1.0);
                                                                                                        if (_9123 > 0.0)
                                                                                                        {
                                                                                                            int _9128 = _9054 + 1;
                                                                                                            if (_9128 < _9066)
                                                                                                            {
                                                                                                                {
                                                                                                                    float _9475 = length(vec3(spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128])[0].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128])[1].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128])[2].x));
                                                                                                                    float _9480 = length(vec3(spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128])[0].z, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128])[1].z, spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128])[2].z));
                                                                                                                    float _9486 = (2.0 * gi.shadowConfig.w) / (isnan(9.9999999747524270787835121154785e-07) ? _9475 : (isnan(_9475) ? 9.9999999747524270787835121154785e-07 : max(_9475, 9.9999999747524270787835121154785e-07)));
                                                                                                                    float _9488 = 2.0 / (isnan(9.9999999747524270787835121154785e-07) ? _9480 : (isnan(_9480) ? 9.9999999747524270787835121154785e-07 : max(_9480, 9.9999999747524270787835121154785e-07)));
                                                                                                                    vec4 _9495 = vec4(_9078 + (normal * (gi.shadowConfig.z * _9486)), 1.0) * spvWorkaroundRowMajor(gi.cascadeMatrix.data[_9128]);
                                                                                                                    vec3 _9499 = _9495.xyz / vec3(_9495.w);
                                                                                                                    bool _9503 = all(lessThanEqual(abs(_9499.xy), vec2(1.0)));
                                                                                                                    _9058 = _9503;
                                                                                                                    if (!_9503)
                                                                                                                    {
                                                                                                                        _9452 = 1.0;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        float _9514 = ((_9499.z * 0.5) + 0.5) - ((gi.shadowConfig.y * _9486) / _9488);
                                                                                                                        float _9527 = length(vec3(spvWorkaroundRowMajor(gi.cascadeMatrix.data[0])[0].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[0])[1].x, spvWorkaroundRowMajor(gi.cascadeMatrix.data[0])[2].x));
                                                                                                                        float _9532 = (_9073 * ((2.0 * gi.shadowConfig.w) / (isnan(9.9999999747524270787835121154785e-07) ? _9527 : (isnan(_9527) ? 9.9999999747524270787835121154785e-07 : max(_9527, 9.9999999747524270787835121154785e-07))))) / (isnan(9.9999999747524270787835121154785e-07) ? _9486 : (isnan(_9486) ? 9.9999999747524270787835121154785e-07 : max(_9486, 9.9999999747524270787835121154785e-07)));
                                                                                                                        float _9533 = isnan(1.0) ? _9532 : (isnan(_9532) ? 1.0 : max(_9532, 1.0));
                                                                                                                        vec2 _9540 = vec2((_9499.x * 0.5) + 0.5, 0.5 - (_9499.y * 0.5));
                                                                                                                        uvec3 _9542 = uvec3(textureSize(_13525, 0));
                                                                                                                        ivec2 _9550 = ivec2(int(_9542.x), int(_9542.y));
                                                                                                                        float _9553 = clamp(0.140399992465972900390625 / (isnan(9.9999999747524270787835121154785e-07) ? _9486 : (isnan(_9486) ? 9.9999999747524270787835121154785e-07 : max(_9486, 9.9999999747524270787835121154785e-07))), 2.0, 16.0);
                                                                                                                        float _9556 = fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy + vec2(7.0, 3.0), vec2(0.067110560834407806396484375, 0.005837149918079376220703125)))) * 6.283185482025146484375;
                                                                                                                        float _9557 = sin(_9556);
                                                                                                                        float _9558 = cos(_9556);
                                                                                                                        int _9456 = 0;
                                                                                                                        float _9457 = 0.0;
                                                                                                                        float _9458 = 0.0;
                                                                                                                        for (;;)
                                                                                                                        {
                                                                                                                            if (!(_9456 < 12))
                                                                                                                            {
                                                                                                                                break;
                                                                                                                            }
                                                                                                                            vec4 _9593 = texelFetch(_13525, ivec4(clamp(ivec2((_9540 + (vec2((_2384_frag[_9456].x * _9558) - (_2384_frag[_9456].y * _9557), (_2384_frag[_9456].x * _9557) + (_2384_frag[_9456].y * _9558)) * (_9553 * gi.shadowConfig.w))) * vec2(_9550)), ivec2(0), _9550 - ivec2(1)), _9128, 0).xyz, 0);
                                                                                                                            float _9594 = _9593.x;
                                                                                                                            if (_9594 < _9514)
                                                                                                                            {
                                                                                                                                _9457 += (_9514 - _9594);
                                                                                                                                _9458 += 1.0;
                                                                                                                            }
                                                                                                                            _9456++;
                                                                                                                            continue;
                                                                                                                        }
                                                                                                                        if (_9458 > 0.0)
                                                                                                                        {
                                                                                                                            float _9619 = (((_9457 / _9458) * _9488) * 0.0046799997799098491668701171875) / (isnan(9.9999999747524270787835121154785e-07) ? _9486 : (isnan(_9486) ? 9.9999999747524270787835121154785e-07 : max(_9486, 9.9999999747524270787835121154785e-07)));
                                                                                                                            _9460 = clamp(isnan(_9619) ? _9533 : (isnan(_9533) ? _9619 : max(_9533, _9619)), 1.0, 24.0);
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            _9460 = _9533;
                                                                                                                        }
                                                                                                                        vec3 _9623 = vec3(_9540, _9514);
                                                                                                                        {
                                                                                                                            if (_9460 <= 1.5)
                                                                                                                            {
                                                                                                                                _9636 = -1;
                                                                                                                                _9637 = 0.0;
                                                                                                                                for (;;)
                                                                                                                                {
                                                                                                                                    if (!(_9636 <= 1))
                                                                                                                                    {
                                                                                                                                        break;
                                                                                                                                    }
                                                                                                                                    int _9638 = -1;
                                                                                                                                    for (;;)
                                                                                                                                    {
                                                                                                                                        if (!(_9638 <= 1))
                                                                                                                                        {
                                                                                                                                            break;
                                                                                                                                        }
                                                                                                                                        int _9665 = _9638;
                                                                                                                                        _9638++;
                                                                                                                                        _9637 += spvShadowLod0(_13527, vec4(vec3(_9623.xy + (vec2(float(_9665), float(_9636)) * gi.shadowConfig.w), float(_9128)), _9514));
                                                                                                                                        continue;
                                                                                                                                    }
                                                                                                                                    _9636++;
                                                                                                                                    continue;
                                                                                                                                }
                                                                                                                                _9635 = _9637 * 0.111111111938953399658203125;
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                float _9697 = fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125)))) * 6.283185482025146484375;
                                                                                                                                float _9698 = sin(_9697);
                                                                                                                                float _9699 = cos(_9697);
                                                                                                                                float _9700 = _9460 * gi.shadowConfig.w;
                                                                                                                                _9636 = 0;
                                                                                                                                _9637 = 0.0;
                                                                                                                                for (;;)
                                                                                                                                {
                                                                                                                                    if (!(_9636 < 12))
                                                                                                                                    {
                                                                                                                                        break;
                                                                                                                                    }
                                                                                                                                    int _9709 = _9636;
                                                                                                                                    _9636++;
                                                                                                                                    _9637 += spvShadowLod0(_13527, vec4(vec3(_9623.xy + (vec2((_2384_frag[_9709].x * _9699) - (_2384_frag[_9709].y * _9698), (_2384_frag[_9709].x * _9698) + (_2384_frag[_9709].y * _9699)) * _9700), float(_9128)), _9514));
                                                                                                                                    continue;
                                                                                                                                }
                                                                                                                                _9635 = _9637 * 0.083333335816860198974609375;
                                                                                                                            }
                                                                                                                        }
                                                                                                                        _9452 = _9635;
                                                                                                                    }
                                                                                                                }
                                                                                                                if (_9058)
                                                                                                                {
                                                                                                                    _9056 = _9452;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _9056 = 1.0;
                                                                                                                }
                                                                                                                _9057 = _9056;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                _9057 = 1.0;
                                                                                                            }
                                                                                                            _9057 = mix(_9154, _9057, _9123);
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            _9057 = _9154;
                                                                                                        }
                                                                                                        _9052 = true;
                                                                                                        _9053 = _9057;
                                                                                                        _9081_ladder_break = true;
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    if (_9081_ladder_break)
                                                                                    {
                                                                                        break;
                                                                                    }
                                                                                    _9054++;
                                                                                    continue;
                                                                                }
                                                                                if (!(_9052))
                                                                                {
                                                                                    _9052 = true;
                                                                                    _9053 = 1.0;
                                                                                }
                                                                            }
                                                                        }
                                                                        if (_9053 > 0.0)
                                                                        {
                                                                            _152 = gi.shadowConfig.x > 0.5;
                                                                        }
                                                                        else
                                                                        {
                                                                            _152 = false;
                                                                        }
                                                                        if (_152)
                                                                        {
                                                                            vec4 _2703 = spvWorkaroundRowMajor(gi.viewToWorld) * vec4(_2114, 0.0);
                                                                            _9749 = false;
                                                                            float _9750;
                                                                            {
                                                                                bool _9751;
                                                                                if (gi.camera.w <= 0.0)
                                                                                {
                                                                                    _9751 = true;
                                                                                }
                                                                                else
                                                                                {
                                                                                    _9751 = _2703.z <= (-0.999000012874603271484375);
                                                                                }
                                                                                if (_9751)
                                                                                {
                                                                                    _9749 = true;
                                                                                    _9750 = 1.0;
                                                                                }
                                                                                else
                                                                                {
                                                                                    uvec2 _9770 = uvec2(textureSize(_13503, 0));
                                                                                    vec2 _9777 = vec2(float(_9770.x), float(_9770.y));
                                                                                    vec3 _9779 = _2703.xyz * (gi.camera.w * 0.083333335816860198974609375);
                                                                                    float _9784 = _8760.z;
                                                                                    float _9785 = 0.0199999995529651641845703125 * _9784;
                                                                                    float _9786 = isnan(_9785) ? 0.300000011920928955078125 : (isnan(0.300000011920928955078125) ? _9785 : max(0.300000011920928955078125, _9785));
                                                                                    float _9788 = 0.00999999977648258209228515625 + (0.00200000009499490261077880859375 * _9784);
                                                                                    int _9754 = 0;
                                                                                    vec3 _9755 = _8760 + (_9779 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy + vec2(17.0, 31.0), vec2(0.067110560834407806396484375, 0.005837149918079376220703125)))));
                                                                                    bool _9756;
                                                                                    for (;;)
                                                                                    {
                                                                                        vec3 _9798;
                                                                                        bool _9791_ladder_break = false;
                                                                                        {
                                                                                            if (!(_9754 < 12))
                                                                                            {
                                                                                                _9791_ladder_break = true;
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                _9798 = _9755 + _9779;
                                                                                                if (_9798.z <= gi.unproject.z)
                                                                                                {
                                                                                                    _9791_ladder_break = true;
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    vec2 _9820 = vec2(0.5 + (((0.5 * _9798.x) * gi.unproject.x) / _9798.z), 0.5 - (((0.5 * _9798.y) * gi.unproject.y) / _9798.z));
                                                                                                    if (any(lessThan(_9820, vec2(0.0))))
                                                                                                    {
                                                                                                        _9751 = true;
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        _9751 = any(greaterThan(_9820, vec2(1.0)));
                                                                                                    }
                                                                                                    if (_9751)
                                                                                                    {
                                                                                                        _9791_ladder_break = true;
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        vec4 _9836 = texelFetch(_13503, ivec3(ivec2(_9820 * _9777), 0).xy, 0);
                                                                                                        float _9837 = _9836.x;
                                                                                                        if (!(_9837 <= 0.0))
                                                                                                        {
                                                                                                            float _9842 = _9798.z - (((2.0 * gi.unproject.z) * gi.unproject.w) / ((gi.unproject.w + gi.unproject.z) - ((1.0 - (2.0 * _9837)) * (gi.unproject.w - gi.unproject.z))));
                                                                                                            if (_9842 > _9788)
                                                                                                            {
                                                                                                                _9756 = _9842 < _9786;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                _9756 = false;
                                                                                                            }
                                                                                                            if (_9756)
                                                                                                            {
                                                                                                                _9749 = true;
                                                                                                                _9750 = float(_9754) * 0.083333335816860198974609375;
                                                                                                                _9791_ladder_break = true;
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        if (_9791_ladder_break)
                                                                                        {
                                                                                            break;
                                                                                        }
                                                                                        _9754++;
                                                                                        _9755 = _9798;
                                                                                        continue;
                                                                                    }
                                                                                    if (!(_9749))
                                                                                    {
                                                                                        _9749 = true;
                                                                                        _9750 = 1.0;
                                                                                    }
                                                                                }
                                                                            }
                                                                            visibility = _9053 * _9750;
                                                                        }
                                                                        else
                                                                        {
                                                                            visibility = _9053;
                                                                        }
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    visibility = 1.0;
                                                                }
                                                                if (debugView == 12)
                                                                {
                                                                    entryPointParam_fragmentMain = vec4(visibility, visibility, visibility, 1.0);
                                                                }
                                                                else
                                                                {
                                                                    if (model == 1)
                                                                    {
                                                                        if (light.sky.z > 0.5)
                                                                        {
                                                                            sunLight = vec3(0.0);
                                                                        }
                                                                        else
                                                                        {
                                                                            sunLight = (light.sunColourScale.xyz * _2117) * visibility;
                                                                        }
                                                                        vec3 _2926 = ((albedo * (baked + sunLight)) * light.sunColourScale.w) + flashDiffuse;
                                                                        float _2927 = _8760.z;
                                                                        vec3 _9887;
                                                                        {
                                                                            bool _9888;
                                                                            if (light.retailFog.w <= 0.0)
                                                                            {
                                                                                _9888 = true;
                                                                            }
                                                                            else
                                                                            {
                                                                                _9888 = gi.fog.z > 0.0;
                                                                            }
                                                                            if (_9888)
                                                                            {
                                                                                _9887 = _2926;
                                                                            }
                                                                            else
                                                                            {
                                                                                _9887 = mix(light.retailFog.xyz, _2926, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _2927 : (isnan(_2927) ? 0.0 : max(_2927, 0.0)))), 0.0, 1.0)));
                                                                            }
                                                                        }
                                                                        vec3 _9920;
                                                                        {
                                                                            if (gi.fog.z <= 0.0)
                                                                            {
                                                                                _9920 = _9887;
                                                                            }
                                                                            else
                                                                            {
                                                                                float _9935 = (_2927 * gi.fog.x) + gi.fog.y;
                                                                                vec4 _9950 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _9935 : (isnan(_9935) ? 9.9999999747524270787835121154785e-07 : max(_9935, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                _9920 = (_9887 * _9950.w) + _9950.xyz;
                                                                            }
                                                                        }
                                                                        entryPointParam_fragmentMain = vec4(_9920, 1.0);
                                                                    }
                                                                    else
                                                                    {
                                                                        float metallic = _5399.x;
                                                                        float specularLevel_1 = _5399.y;
                                                                        float roughness = _5399.z;
                                                                        vec3 _2942 = normalize(-(vec4(_8760, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz);
                                                                        vec3 worldRayToPixel = -_2942;
                                                                        float waterMask = 0.0;
                                                                        float waterReflectance = 0.0;
                                                                        if (gi.wetness0.x > 0.0)
                                                                        {
                                                                            _152 = !((int((_5399.w * 255.0) + 0.5) & 16) != 0);
                                                                        }
                                                                        else
                                                                        {
                                                                            _152 = false;
                                                                        }
                                                                        float specularLevel;
                                                                        if (_152)
                                                                        {
                                                                            float _2976 = dot(normal, _2942);
                                                                            float _2977 = isnan(0.001000000047497451305389404296875) ? _2976 : (isnan(_2976) ? 0.001000000047497451305389404296875 : max(_2976, 0.001000000047497451305389404296875));
                                                                            vec4 _2996 = vec4(_8760, 1.0) * spvWorkaroundRowMajor(gi.viewToWorld);
                                                                            {
                                                                                waterMask = 0.0;
                                                                                waterReflectance = 0.0;
                                                                                float _10034 = isnan(0.0) ? gi.wetness0.x : (isnan(gi.wetness0.x) ? 0.0 : max(gi.wetness0.x, 0.0));
                                                                                bool _9975;
                                                                                if (_10034 <= 0.0)
                                                                                {
                                                                                    _9975 = true;
                                                                                }
                                                                                else
                                                                                {
                                                                                    bool _10056;
                                                                                    {
                                                                                        ivec2 _10130 = ivec2(floor(((_2996.xy + gi.camera.xy) - gi.shelterMap0.xy) * gi.shelterMap0.z));
                                                                                        vec2 _12700 = gi.shelterMap2.xy;
                                                                                        bool _10131;
                                                                                        if (gi.wetness1.w > 0.5)
                                                                                        {
                                                                                            _10131 = _10130.x >= 0;
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            _10131 = false;
                                                                                        }
                                                                                        if (_10131)
                                                                                        {
                                                                                            _10131 = _10130.y >= 0;
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            _10131 = false;
                                                                                        }
                                                                                        if (_10131)
                                                                                        {
                                                                                            _10131 = _10130.x < int(_12700.x);
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            _10131 = false;
                                                                                        }
                                                                                        if (_10131)
                                                                                        {
                                                                                            _10131 = _10130.y < int(_12700.y);
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            _10131 = false;
                                                                                        }
                                                                                        if (!_10131)
                                                                                        {
                                                                                            _10056 = false;
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            vec4 _10078 = texelFetch(_13532, ivec3(_10130, 0).xy, 0);
                                                                                            float _12704 = gi.shelterMap0.w;
                                                                                            float _12705 = gi.shelterMap1.x;
                                                                                            float _10181 = floor((_10078.z * 255.0) + 0.5) + (floor((_10078.y * 255.0) + 0.5) * 256.0);
                                                                                            float _10169;
                                                                                            if (_10181 < 0.5)
                                                                                            {
                                                                                                _10169 = -1000000015047466219876688855040.0;
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                _10169 = _12704 + ((_10181 - 1.0) * _12705);
                                                                                            }
                                                                                            float _10084 = _2996.z + gi.camera.z;
                                                                                            float _12709 = gi.shelterMap1.z;
                                                                                            bool _10194;
                                                                                            if (_10169 > (_10084 + gi.shelterMap1.y))
                                                                                            {
                                                                                                _10194 = _10169 < (_10084 + _12709);
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                _10194 = false;
                                                                                            }
                                                                                            _10056 = _10194;
                                                                                        }
                                                                                    }
                                                                                    _9975 = _10056;
                                                                                }
                                                                                if (!(_9975))
                                                                                {
                                                                                    vec3 _9991 = normal;
                                                                                    float _10214 = clamp((_9991.z * 0.5) + 0.5, 0.0, 1.0);
                                                                                    float _10237 = isnan(0.0500000007450580596923828125) ? gi.wetness1.x : (isnan(gi.wetness1.x) ? 0.0500000007450580596923828125 : max(gi.wetness1.x, 0.0500000007450580596923828125));
                                                                                    float _10245 = _10237 * 0.4600000083446502685546875;
                                                                                    vec2 _10270 = vec2((0.800000011920928955078125 * gi.camera.xy.x) - (0.60000002384185791015625 * gi.camera.xy.y), (0.60000002384185791015625 * gi.camera.xy.x) + (0.800000011920928955078125 * gi.camera.xy.y)) / vec2(_10245);
                                                                                    vec2 _10271 = floor(_10270);
                                                                                    float _10297 = _2996.x;
                                                                                    float _10300 = _2996.y;
                                                                                    vec2 _10249 = ((vec2((0.800000011920928955078125 * _10297) - (0.60000002384185791015625 * _10300), (0.60000002384185791015625 * _10297) + (0.800000011920928955078125 * _10300)) / vec2(_10245)) + (_10270 - _10271)) + vec2(11.30000019073486328125);
                                                                                    vec2 _10309 = floor(_10249);
                                                                                    vec2 _10310 = _10249 - _10309;
                                                                                    vec2 _10315 = (_10310 * _10310) * (vec2(3.0) - (_10310 * 2.0));
                                                                                    vec2 _10316 = _10309 + _10271;
                                                                                    uvec2 _10334 = uvec2(ivec2(_10316) + ivec2(1048576));
                                                                                    uint _10339 = (_10334.x * 73856093u) ^ (_10334.y * 19349663u);
                                                                                    uint _10342 = (_10339 ^ (_10339 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10353 = uvec2(ivec2(_10316 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                    uint _10358 = (_10353.x * 73856093u) ^ (_10353.y * 19349663u);
                                                                                    uint _10361 = (_10358 ^ (_10358 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10372 = uvec2(ivec2(_10316 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                    uint _10377 = (_10372.x * 73856093u) ^ (_10372.y * 19349663u);
                                                                                    uint _10380 = (_10377 ^ (_10377 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10391 = uvec2(ivec2(_10316 + vec2(1.0)) + ivec2(1048576));
                                                                                    uint _10396 = (_10391.x * 73856093u) ^ (_10391.y * 19349663u);
                                                                                    uint _10399 = (_10396 ^ (_10396 >> uint(13))) * 1540483477u;
                                                                                    float _10324 = _10315.x;
                                                                                    float _10328 = mix(mix(float((_10342 ^ (_10342 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10361 ^ (_10361 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10324), mix(float((_10380 ^ (_10380 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10399 ^ (_10399 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10324), _10315.y);
                                                                                    vec2 _10415 = gi.camera.xy / vec2(_10237);
                                                                                    vec2 _10416 = floor(_10415);
                                                                                    vec2 _10257 = ((vec2(_2996.xy) / vec2(_10237)) + (_10415 - _10416)) + vec2((_10328 - 0.5) * 0.4000000059604644775390625);
                                                                                    vec2 _10454 = floor(_10257);
                                                                                    vec2 _10455 = _10257 - _10454;
                                                                                    vec2 _10460 = (_10455 * _10455) * (vec2(3.0) - (_10455 * 2.0));
                                                                                    vec2 _10461 = _10454 + _10416;
                                                                                    uvec2 _10479 = uvec2(ivec2(_10461) + ivec2(1048576));
                                                                                    uint _10484 = (_10479.x * 73856093u) ^ (_10479.y * 19349663u);
                                                                                    uint _10487 = (_10484 ^ (_10484 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10498 = uvec2(ivec2(_10461 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                    uint _10503 = (_10498.x * 73856093u) ^ (_10498.y * 19349663u);
                                                                                    uint _10506 = (_10503 ^ (_10503 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10517 = uvec2(ivec2(_10461 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                    uint _10522 = (_10517.x * 73856093u) ^ (_10517.y * 19349663u);
                                                                                    uint _10525 = (_10522 ^ (_10522 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10536 = uvec2(ivec2(_10461 + vec2(1.0)) + ivec2(1048576));
                                                                                    uint _10541 = (_10536.x * 73856093u) ^ (_10536.y * 19349663u);
                                                                                    uint _10544 = (_10541 ^ (_10541 >> uint(13))) * 1540483477u;
                                                                                    float _10469 = _10460.x;
                                                                                    float _10224 = clamp((_10034 * mix(0.25, 1.0, _10214 * _10214)) + (((clamp(((clamp(gi.wetness0.y, 0.0, 1.0) - ((mix(mix(float((_10487 ^ (_10487 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10506 ^ (_10506 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10469), mix(float((_10525 ^ (_10525 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10544 ^ (_10544 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10469), _10460.y) * 0.64999997615814208984375) + (_10328 * 0.3499999940395355224609375))) * 6.0) + 0.89999997615814208984375, 0.0, 1.0) * clamp((_9991.z - 0.86000001430511474609375) * 12.0, 0.0, 1.0)) * _10034) * 0.449999988079071044921875), 0.0, 1.0);
                                                                                    float _10570 = isnan(0.0500000007450580596923828125) ? gi.wetness1.x : (isnan(gi.wetness1.x) ? 0.0500000007450580596923828125 : max(gi.wetness1.x, 0.0500000007450580596923828125));
                                                                                    float _10578 = _10570 * 0.4600000083446502685546875;
                                                                                    vec2 _10603 = vec2((0.800000011920928955078125 * gi.camera.xy.x) - (0.60000002384185791015625 * gi.camera.xy.y), (0.60000002384185791015625 * gi.camera.xy.x) + (0.800000011920928955078125 * gi.camera.xy.y)) / vec2(_10578);
                                                                                    vec2 _10604 = floor(_10603);
                                                                                    float _10630 = _2996.x;
                                                                                    float _10633 = _2996.y;
                                                                                    vec2 _10582 = ((vec2((0.800000011920928955078125 * _10630) - (0.60000002384185791015625 * _10633), (0.60000002384185791015625 * _10630) + (0.800000011920928955078125 * _10633)) / vec2(_10578)) + (_10603 - _10604)) + vec2(11.30000019073486328125);
                                                                                    vec2 _10642 = floor(_10582);
                                                                                    vec2 _10643 = _10582 - _10642;
                                                                                    vec2 _10648 = (_10643 * _10643) * (vec2(3.0) - (_10643 * 2.0));
                                                                                    vec2 _10649 = _10642 + _10604;
                                                                                    uvec2 _10667 = uvec2(ivec2(_10649) + ivec2(1048576));
                                                                                    uint _10672 = (_10667.x * 73856093u) ^ (_10667.y * 19349663u);
                                                                                    uint _10675 = (_10672 ^ (_10672 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10686 = uvec2(ivec2(_10649 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                    uint _10691 = (_10686.x * 73856093u) ^ (_10686.y * 19349663u);
                                                                                    uint _10694 = (_10691 ^ (_10691 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10705 = uvec2(ivec2(_10649 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                    uint _10710 = (_10705.x * 73856093u) ^ (_10705.y * 19349663u);
                                                                                    uint _10713 = (_10710 ^ (_10710 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10724 = uvec2(ivec2(_10649 + vec2(1.0)) + ivec2(1048576));
                                                                                    uint _10729 = (_10724.x * 73856093u) ^ (_10724.y * 19349663u);
                                                                                    uint _10732 = (_10729 ^ (_10729 >> uint(13))) * 1540483477u;
                                                                                    float _10657 = _10648.x;
                                                                                    float _10661 = mix(mix(float((_10675 ^ (_10675 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10694 ^ (_10694 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10657), mix(float((_10713 ^ (_10713 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10732 ^ (_10732 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10657), _10648.y);
                                                                                    vec2 _10748 = gi.camera.xy / vec2(_10570);
                                                                                    vec2 _10749 = floor(_10748);
                                                                                    vec2 _10590 = ((vec2(_2996.xy) / vec2(_10570)) + (_10748 - _10749)) + vec2((_10661 - 0.5) * 0.4000000059604644775390625);
                                                                                    vec2 _10787 = floor(_10590);
                                                                                    vec2 _10788 = _10590 - _10787;
                                                                                    vec2 _10793 = (_10788 * _10788) * (vec2(3.0) - (_10788 * 2.0));
                                                                                    vec2 _10794 = _10787 + _10749;
                                                                                    uvec2 _10812 = uvec2(ivec2(_10794) + ivec2(1048576));
                                                                                    uint _10817 = (_10812.x * 73856093u) ^ (_10812.y * 19349663u);
                                                                                    uint _10820 = (_10817 ^ (_10817 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10831 = uvec2(ivec2(_10794 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                    uint _10836 = (_10831.x * 73856093u) ^ (_10831.y * 19349663u);
                                                                                    uint _10839 = (_10836 ^ (_10836 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10850 = uvec2(ivec2(_10794 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                    uint _10855 = (_10850.x * 73856093u) ^ (_10850.y * 19349663u);
                                                                                    uint _10858 = (_10855 ^ (_10855 >> uint(13))) * 1540483477u;
                                                                                    uvec2 _10869 = uvec2(ivec2(_10794 + vec2(1.0)) + ivec2(1048576));
                                                                                    uint _10874 = (_10869.x * 73856093u) ^ (_10869.y * 19349663u);
                                                                                    uint _10877 = (_10874 ^ (_10874 >> uint(13))) * 1540483477u;
                                                                                    float _10802 = _10793.x;
                                                                                    float _10565 = (clamp((clamp(gi.wetness0.y, 0.0, 1.0) - ((mix(mix(float((_10820 ^ (_10820 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10839 ^ (_10839 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10802), mix(float((_10858 ^ (_10858 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_10877 ^ (_10877 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _10802), _10793.y) * 0.64999997615814208984375) + (_10661 * 0.3499999940395355224609375))) * 20.0, 0.0, 1.0) * clamp((_9991.z - 0.86000001430511474609375) * 12.0, 0.0, 1.0)) * _10034;
                                                                                    waterMask = _10565;
                                                                                    albedo *= mix(1.0, 0.60000002384185791015625, _10224);
                                                                                    float _10891 = roughness * 0.75;
                                                                                    roughness = mix(roughness, isnan(_10891) ? 0.550000011920928955078125 : (isnan(0.550000011920928955078125) ? _10891 : max(0.550000011920928955078125, _10891)), _10224);
                                                                                    if (!(_10565 <= 0.0))
                                                                                    {
                                                                                        vec3 _10006 = vec3(_10565);
                                                                                        albedo = mix(albedo, albedo * 0.5, _10006);
                                                                                        vec2 _12770 = gi.camera.xy;
                                                                                        float _12773 = gi.wetness1.z;
                                                                                        float _10899 = isnan(0.0199999995529651641845703125) ? gi.wetness1.y : (isnan(gi.wetness1.y) ? 0.0199999995529651641845703125 : max(gi.wetness1.y, 0.0199999995529651641845703125));
                                                                                        float _10902 = gi.wetness0.w * 0.60000002384185791015625;
                                                                                        int _10936 = 0;
                                                                                        vec2 _10937 = vec2(0.0);
                                                                                        vec2 _11040;
                                                                                        vec2 _11045;
                                                                                        SPIRV_CROSS_UNROLL
                                                                                        for (;;)
                                                                                        {
                                                                                            bool _10947_ladder_break = false;
                                                                                            {
                                                                                                if (!(_10936 < 4))
                                                                                                {
                                                                                                    _10947_ladder_break = true;
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    vec4 _10938 = vec4(0.0, 0.2199999988079071044921875, 0.439999997615814208984375, 0.660000026226043701171875);
                                                                                                    float _10958 = clamp((gi.wetness0.z - _10938[_10936]) * 4.0, 0.0, 1.0);
                                                                                                    if (!(_10958 <= 0.0))
                                                                                                    {
                                                                                                        vec4 _10939 = vec4(0.519999980926513671875, 0.7400000095367431640625, 0.9700000286102294921875, 1.2799999713897705078125);
                                                                                                        float _10965 = _10899 * _10939[_10936];
                                                                                                        vec2 _11002 = _12770 / vec2(_10965);
                                                                                                        vec2 _11003 = floor(_11002);
                                                                                                        vec4 _10940 = vec4(0.959999978542327880859375, 0.810000002384185791015625, 0.88999998569488525390625, 0.7200000286102294921875);
                                                                                                        vec4 _10941 = vec4(0.0, 0.310000002384185791015625, 0.579999983310699462890625, 0.829999983310699462890625);
                                                                                                        float _10975 = fract((_10902 * _10940[_10936]) + _10941[_10936]);
                                                                                                        vec2 _10980 = ((vec2(_2996.xy) / vec2(_10965)) + (_11002 - _11003)) + _3637_frag[_10936];
                                                                                                        {
                                                                                                            if (_10958 <= 0.0)
                                                                                                            {
                                                                                                                _11040 = vec2(0.0);
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                float _11053 = mix(0.20000000298023223876953125, 1.0, clamp(_10958, 0.0, 1.0));
                                                                                                                vec2 _11056 = floor(_10980 - vec2(0.5));
                                                                                                                int _11041 = 0;
                                                                                                                vec2 _11042 = vec2(0.0);
                                                                                                                for (;;)
                                                                                                                {
                                                                                                                    if (!(_11041 < 2))
                                                                                                                    {
                                                                                                                        break;
                                                                                                                    }
                                                                                                                    int _11043 = 0;
                                                                                                                    vec2 _11044 = _11042;
                                                                                                                    for (;;)
                                                                                                                    {
                                                                                                                        bool _11068_ladder_break = false;
                                                                                                                        {
                                                                                                                            if (!(_11043 < 2))
                                                                                                                            {
                                                                                                                                _11068_ladder_break = true;
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                vec2 _11079 = _11056 + vec2(float(_11043), float(_11041));
                                                                                                                                vec2 _11082 = _10980 - (_11079 + vec2(0.5));
                                                                                                                                if (!(dot(_11082, _11082) > 0.608399927616119384765625))
                                                                                                                                {
                                                                                                                                    uvec2 _11142 = uvec2(ivec2(_11079 + _11003) + ivec2(1048576));
                                                                                                                                    uint _11147 = (_11142.x * 73856093u) ^ (_11142.y * 19349663u);
                                                                                                                                    uint _11150 = (_11147 ^ (_11147 >> uint(13))) * 1540483477u;
                                                                                                                                    uint _11152 = _11150 ^ (_11150 >> uint(15));
                                                                                                                                    uint _11153 = _11152 * 668265261u;
                                                                                                                                    uint _11155 = _11153 ^ (_11153 >> uint(15));
                                                                                                                                    uint _11156 = _11155 * 2246822507u;
                                                                                                                                    vec3 _11166 = vec3(float(_11152 & 16777215u), float(_11155 & 16777215u), float((_11156 ^ (_11156 >> uint(13))) & 16777215u)) * 5.9604651880817982601001858711243e-08;
                                                                                                                                    float _11091 = fract(_10975 + _11166.x);
                                                                                                                                    vec2 _11096 = _11082 - ((_11166.yz - vec2(0.5)) * 0.5);
                                                                                                                                    float _11097 = length(_11096);
                                                                                                                                    if (_11097 > 9.9999997473787516355514526367188e-06)
                                                                                                                                    {
                                                                                                                                        _11045 = _11096 / vec2(_11097);
                                                                                                                                    }
                                                                                                                                    else
                                                                                                                                    {
                                                                                                                                        _11045 = vec2(0.0);
                                                                                                                                    }
                                                                                                                                    _11044 -= (_11045 * ((sin(3.1415927410125732421875 * clamp((_11091 - clamp(_11097 * 2.17391300201416015625, 0.0, 1.0)) * 24.0, 0.0, 4.0)) * clamp(_11053 - _11091, 0.0, 1.0)) * 0.449999988079071044921875));
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                        if (_11068_ladder_break)
                                                                                                                        {
                                                                                                                            break;
                                                                                                                        }
                                                                                                                        _11043++;
                                                                                                                        continue;
                                                                                                                    }
                                                                                                                    _11041++;
                                                                                                                    _11042 = _11044;
                                                                                                                    continue;
                                                                                                                }
                                                                                                                _11040 = _11042;
                                                                                                            }
                                                                                                        }
                                                                                                        _10937 += _11040;
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                            if (_10947_ladder_break)
                                                                                            {
                                                                                                break;
                                                                                            }
                                                                                            _10936++;
                                                                                            continue;
                                                                                        }
                                                                                        vec2 _11194 = _12770 * vec2(0.5555555820465087890625);
                                                                                        vec2 _11195 = floor(_11194);
                                                                                        vec2 _11174 = ((vec2(_2996.xy) * vec2(0.5555555820465087890625)) + (_11194 - _11195)) + vec2(gi.wetness0.w * 0.07999999821186065673828125, gi.wetness0.w * 0.0500000007450580596923828125);
                                                                                        vec2 _11233 = floor(_11174);
                                                                                        vec2 _11234 = _11174 - _11233;
                                                                                        vec2 _11239 = (_11234 * _11234) * (vec2(3.0) - (_11234 * 2.0));
                                                                                        vec2 _11240 = _11233 + _11195;
                                                                                        uvec2 _11258 = uvec2(ivec2(_11240) + ivec2(1048576));
                                                                                        uint _11263 = (_11258.x * 73856093u) ^ (_11258.y * 19349663u);
                                                                                        uint _11266 = (_11263 ^ (_11263 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11277 = uvec2(ivec2(_11240 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                        uint _11282 = (_11277.x * 73856093u) ^ (_11277.y * 19349663u);
                                                                                        uint _11285 = (_11282 ^ (_11282 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11296 = uvec2(ivec2(_11240 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                        uint _11301 = (_11296.x * 73856093u) ^ (_11296.y * 19349663u);
                                                                                        uint _11304 = (_11301 ^ (_11301 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11315 = uvec2(ivec2(_11240 + vec2(1.0)) + ivec2(1048576));
                                                                                        uint _11320 = (_11315.x * 73856093u) ^ (_11315.y * 19349663u);
                                                                                        uint _11323 = (_11320 ^ (_11320 >> uint(13))) * 1540483477u;
                                                                                        float _11248 = _11239.x;
                                                                                        float _11252 = mix(mix(float((_11266 ^ (_11266 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_11285 ^ (_11285 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _11248), mix(float((_11304 ^ (_11304 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_11323 ^ (_11323 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _11248), _11239.y);
                                                                                        vec2 _11177 = _11174 + vec2(0.1500000059604644775390625, 0.0);
                                                                                        vec2 _11331 = floor(_11177);
                                                                                        vec2 _11332 = _11177 - _11331;
                                                                                        vec2 _11337 = (_11332 * _11332) * (vec2(3.0) - (_11332 * 2.0));
                                                                                        vec2 _11338 = _11331 + _11195;
                                                                                        uvec2 _11356 = uvec2(ivec2(_11338) + ivec2(1048576));
                                                                                        uint _11361 = (_11356.x * 73856093u) ^ (_11356.y * 19349663u);
                                                                                        uint _11364 = (_11361 ^ (_11361 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11375 = uvec2(ivec2(_11338 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                        uint _11380 = (_11375.x * 73856093u) ^ (_11375.y * 19349663u);
                                                                                        uint _11383 = (_11380 ^ (_11380 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11394 = uvec2(ivec2(_11338 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                        uint _11399 = (_11394.x * 73856093u) ^ (_11394.y * 19349663u);
                                                                                        uint _11402 = (_11399 ^ (_11399 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11413 = uvec2(ivec2(_11338 + vec2(1.0)) + ivec2(1048576));
                                                                                        uint _11418 = (_11413.x * 73856093u) ^ (_11413.y * 19349663u);
                                                                                        uint _11421 = (_11418 ^ (_11418 >> uint(13))) * 1540483477u;
                                                                                        vec2 _11180 = _11174 + vec2(0.0, 0.1500000059604644775390625);
                                                                                        vec2 _11429 = floor(_11180);
                                                                                        vec2 _11430 = _11180 - _11429;
                                                                                        vec2 _11435 = (_11430 * _11430) * (vec2(3.0) - (_11430 * 2.0));
                                                                                        vec2 _11436 = _11429 + _11195;
                                                                                        uvec2 _11454 = uvec2(ivec2(_11436) + ivec2(1048576));
                                                                                        uint _11459 = (_11454.x * 73856093u) ^ (_11454.y * 19349663u);
                                                                                        uint _11462 = (_11459 ^ (_11459 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11473 = uvec2(ivec2(_11436 + vec2(1.0, 0.0)) + ivec2(1048576));
                                                                                        uint _11478 = (_11473.x * 73856093u) ^ (_11473.y * 19349663u);
                                                                                        uint _11481 = (_11478 ^ (_11478 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11492 = uvec2(ivec2(_11436 + vec2(0.0, 1.0)) + ivec2(1048576));
                                                                                        uint _11497 = (_11492.x * 73856093u) ^ (_11492.y * 19349663u);
                                                                                        uint _11500 = (_11497 ^ (_11497 >> uint(13))) * 1540483477u;
                                                                                        uvec2 _11511 = uvec2(ivec2(_11436 + vec2(1.0)) + ivec2(1048576));
                                                                                        uint _11516 = (_11511.x * 73856093u) ^ (_11511.y * 19349663u);
                                                                                        uint _11519 = (_11516 ^ (_11516 >> uint(13))) * 1540483477u;
                                                                                        vec2 _10910 = (vec2(mix(mix(float((_11364 ^ (_11364 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_11383 ^ (_11383 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _11337.x), mix(float((_11402 ^ (_11402 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_11421 ^ (_11421 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _11337.x), _11337.y) - _11252, mix(mix(float((_11462 ^ (_11462 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_11481 ^ (_11481 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _11435.x), mix(float((_11500 ^ (_11500 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, float((_11519 ^ (_11519 >> uint(15))) & 16777215u) * 5.9604651880817982601001858711243e-08, _11435.x), _11435.y) - _11252) * _12773) * 1.60000002384185791015625;
                                                                                        vec2 _10911 = _10937 + _10910;
                                                                                        float _10914 = clamp(((abs((_5382 * 2.0) * _8760.z) / (isnan(9.9999997473787516355514526367188e-05) ? gi.unproject.x : (isnan(gi.unproject.x) ? 9.9999997473787516355514526367188e-05 : max(gi.unproject.x, 9.9999997473787516355514526367188e-05)))) / (isnan(0.07999999821186065673828125) ? _2977 : (isnan(_2977) ? 0.07999999821186065673828125 : max(_2977, 0.07999999821186065673828125)))) / (_10899 * 0.5), 0.0, 1.0);
                                                                                        float _10916 = 1.0 - _10914;
                                                                                        vec3 _10009 = normal;
                                                                                        vec3 _10012 = normalize(mix(_10009, normalize(vec3(_10911 * _10916, 1.0)), _10006));
                                                                                        normal = _10012;
                                                                                        roughness = mix(roughness, clamp((0.0500000007450580596923828125 + ((length(_10911) * _10916) * 0.100000001490116119384765625)) + (((0.20000000298023223876953125 * gi.wetness0.z) + (0.100000001490116119384765625 * _12773)) * _10914), 0.0500000007450580596923828125, 0.319999992847442626953125), _10565);
                                                                                        float _11529 = 1.0 - clamp(dot(_10012, _2942), 0.0, 1.0);
                                                                                        float _11530 = _11529 * _11529;
                                                                                        float _10018 = (0.0199999995529651641845703125 + (((0.980000019073486328125 * _11530) * _11530) * _11529)) * _10565;
                                                                                        waterReflectance = _10018;
                                                                                        albedo *= (1.0 - _10018);
                                                                                    }
                                                                                }
                                                                            }
                                                                            float _3924 = 0.5 * waterMask;
                                                                            specularLevel = isnan(_3924) ? specularLevel_1 : (isnan(specularLevel_1) ? _3924 : max(specularLevel_1, _3924));
                                                                        }
                                                                        else
                                                                        {
                                                                            specularLevel = specularLevel_1;
                                                                        }
                                                                        if (debugView == 13)
                                                                        {
                                                                            entryPointParam_fragmentMain = vec4(waterMask, (normal.xy * 0.5) + vec2(0.5), 1.0);
                                                                        }
                                                                        else
                                                                        {
                                                                            vec3 sunIlluminance = light.sunColourScale.xyz * light.sunColourScale.w;
                                                                            vec3 _11541 = mix(vec3(0.07999999821186065673828125 * specularLevel), albedo, vec3(metallic));
                                                                            float _11542 = isnan(0.0199999995529651641845703125) ? roughness : (isnan(roughness) ? 0.0199999995529651641845703125 : max(roughness, 0.0199999995529651641845703125));
                                                                            float _11543 = _11542 * _11542;
                                                                            float _11544 = _11543 * _11543;
                                                                            vec3 _11545 = _2942 + _2114;
                                                                            float _11546 = dot(_11545, _11545);
                                                                            vec3 _11549 = _11545 * inversesqrt(isnan(9.9999999392252902907785028219223e-09) ? _11546 : (isnan(_11546) ? 9.9999999392252902907785028219223e-09 : max(_11546, 9.9999999392252902907785028219223e-09)));
                                                                            float _11551 = clamp(dot(normal, _11549), 0.0, 1.0);
                                                                            float _11555 = clamp(dot(normal, _2114), 0.0, 1.0);
                                                                            float _11559 = clamp(abs(dot(normal, _2942)) + 9.9999997473787516355514526367188e-06, 0.0, 1.0);
                                                                            float _11563 = ((_11551 * _11551) * (_11544 - 1.0)) + 1.0;
                                                                            float _11570 = mix((2.0 * _11555) * _11559, _11555 + _11559, _11543);
                                                                            vec3 sunLight_1 = ((((albedo * (1.0 - metallic)) * (_11555 * 0.3183098733425140380859375)) + (((_11541 + ((vec3(clamp(50.0 * _11541.y, 0.0, 1.0)) - _11541) * pow(1.0 - clamp(dot(_2942, _11549), 0.0, 1.0), 5.0))) * ((_11544 / ((3.1415927410125732421875 * _11563) * _11563)) * (0.5 / (isnan(9.9999999747524270787835121154785e-07) ? _11570 : (isnan(_11570) ? 9.9999999747524270787835121154785e-07 : max(_11570, 9.9999999747524270787835121154785e-07)))))) * _11555)) * sunIlluminance) * visibility;
                                                                            if (waterReflectance > 0.0)
                                                                            {
                                                                                vec3 _4027 = normalize(reflect(worldRayToPixel, normal));
                                                                                float _11596 = (gi.giParams.w * gi.giParams.w) - 40449600.0;
                                                                                float _11601 = acos(clamp(sqrt(isnan(_11596) ? 0.0 : (isnan(0.0) ? _11596 : max(0.0, _11596))) / gi.giParams.w, -1.0, 1.0));
                                                                                float _11602 = 3.1415927410125732421875 - _11601;
                                                                                float _11605 = acos(clamp(_4027.z, -1.0, 1.0));
                                                                                float _11591;
                                                                                if (_11605 < _11602)
                                                                                {
                                                                                    float _11617 = 1.0 - (_11605 / _11602);
                                                                                    _11591 = (1.0 - sqrt(isnan(_11617) ? 0.0 : (isnan(0.0) ? _11617 : max(0.0, _11617)))) * 0.5;
                                                                                }
                                                                                else
                                                                                {
                                                                                    float _11610 = (_11605 - _11602) / (isnan(9.9999999747524270787835121154785e-07) ? _11601 : (isnan(_11601) ? 9.9999999747524270787835121154785e-07 : max(_11601, 9.9999999747524270787835121154785e-07)));
                                                                                    _11591 = (sqrt(isnan(_11610) ? 0.0 : (isnan(0.0) ? _11610 : max(0.0, _11610))) * 0.5) + 0.5;
                                                                                }
                                                                                float _11625 = atan(_4027.y, _4027.x);
                                                                                float _11592;
                                                                                if (_11625 < 0.0)
                                                                                {
                                                                                    _11592 = _11625 + 6.283185482025146484375;
                                                                                }
                                                                                else
                                                                                {
                                                                                    _11592 = _11625;
                                                                                }
                                                                                uvec2 _11640 = uvec2(textureSize(_13508, 0));
                                                                                vec2 _11647 = vec2(float(_11640.x), float(_11640.y));
                                                                                sunLight = sunLight_1 + ((textureLod(_13510, (vec2(_11592 * 0.15915493667125701904296875, _11591) * ((_11647 - vec2(1.0)) / _11647)) + (vec2(0.5) / _11647), 0.0).xyz * waterReflectance) * clamp(_4027.z * 20.0, 0.0, 1.0));
                                                                            }
                                                                            else
                                                                            {
                                                                                sunLight = sunLight_1;
                                                                            }
                                                                            int _4058 = int(lamps.control.x + 0.5);
                                                                            float _4059 = _8760.z;
                                                                            uvec2 _11683 = uvec2(textureSize(_13515, 0));
                                                                            uint _11684 = _11683.x;
                                                                            uint _11668 = _11684;
                                                                            uint _11685 = _11683.y;
                                                                            uint _11669 = _11685;
                                                                            ivec2 _11692 = ivec2(int(_11684) - 1, int(_11685) - 1);
                                                                            uvec2 _11694 = uvec2(textureSize(_13535, 0));
                                                                            vec2 _11701 = vec2(float(_11694.x), float(_11694.y));
                                                                            vec2 _11704 = (input_uv * _11701) - vec2(0.5);
                                                                            vec2 _11705 = fract(_11704);
                                                                            ivec2 _11707 = ivec2(floor(_11704));
                                                                            ivec2 _11710 = ivec2(_11701) - ivec2(1);
                                                                            float _11711 = _11705.x;
                                                                            float _11712 = 1.0 - _11711;
                                                                            float _11713 = _11705.y;
                                                                            float _11714 = 1.0 - _11713;
                                                                            vec4 _11672 = vec4(_11712 * _11714, _11711 * _11714, _11712 * _11713, _11711 * _11713);
                                                                            float _11673 = 1000000015047466219876688855040.0;
                                                                            vec2 _11675 = vec2(1.0, 0.0);
                                                                            int _11677 = 0;
                                                                            vec2 _11676 = vec2(0.0);
                                                                            float _11674 = 0.0;
                                                                            vec2 _11678;
                                                                            float _11679;
                                                                            for (;;)
                                                                            {
                                                                                bool _11722_ladder_break = false;
                                                                                {
                                                                                    if (!(_11677 < 4))
                                                                                    {
                                                                                        _11722_ladder_break = true;
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        ivec2 _11734 = clamp(_11707 + ivec2(_11677 & 1, _11677 >> 1), ivec2(0), _11710);
                                                                                        vec4 _11738 = texelFetch(_13535, ivec3(_11734, 0).xy, 0);
                                                                                        float _11740 = _11738.z;
                                                                                        if (!(_11740 <= 0.0))
                                                                                        {
                                                                                            float _11745 = abs(_11740 - _4059);
                                                                                            if (_11745 < _11673)
                                                                                            {
                                                                                                _11679 = _11745;
                                                                                                _11678 = _11738.xy;
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                _11679 = _11673;
                                                                                                _11678 = _11675;
                                                                                            }
                                                                                            float _11773 = clamp(dot(normalize((texelFetch(_13515, ivec3(clamp(ivec2((vec2(_11734) + vec2(0.5)) * (vec2(float(_11668), float(_11669)) / _11701)), ivec2(0), _11692), 0).xy, 0).xyz * 2.0) - vec3(1.0)), normal), 0.0, 1.0);
                                                                                            float _11778 = 0.02999999932944774627685546875 * _4059;
                                                                                            float _11786 = ((((_11672[_11677] * exp2((-_11745) / (isnan(0.001000000047497451305389404296875) ? _11778 : (isnan(_11778) ? 0.001000000047497451305389404296875 : max(_11778, 0.001000000047497451305389404296875))))) * _11773) * _11773) * _11773) * _11773;
                                                                                            _11673 = _11679;
                                                                                            _11675 = _11678;
                                                                                            _11676 += (_11738.xy * _11786);
                                                                                            _11674 += _11786;
                                                                                        }
                                                                                    }
                                                                                }
                                                                                if (_11722_ladder_break)
                                                                                {
                                                                                    break;
                                                                                }
                                                                                _11677++;
                                                                                continue;
                                                                            }
                                                                            if (_11674 > 9.9999997473787516355514526367188e-05)
                                                                            {
                                                                                _11678 = _11676 / vec2(_11674);
                                                                            }
                                                                            else
                                                                            {
                                                                                _11678 = _11675;
                                                                            }
                                                                            vec3 _11815 = vec3(_11678, _13488);
                                                                            bool lampShadows = lamps.control.y > 0.5;
                                                                            float lampOcclusion;
                                                                            if (lampShadows)
                                                                            {
                                                                                lampOcclusion = clamp(_11815.x, 0.0, 1.0);
                                                                            }
                                                                            else
                                                                            {
                                                                                lampOcclusion = 1.0;
                                                                            }
                                                                            if (debugView == 29)
                                                                            {
                                                                                float _4266 = _11815.y;
                                                                                if (_4266 > 0.0040000001899898052215576171875)
                                                                                {
                                                                                    visibility = clamp(_4266, 0.0, 1.0);
                                                                                }
                                                                                else
                                                                                {
                                                                                    visibility = 0.0;
                                                                                }
                                                                                entryPointParam_fragmentMain = vec4(clamp(_11815.x, 0.0, 1.0), visibility, 0.0, 1.0);
                                                                            }
                                                                            else
                                                                            {
                                                                                float trust;
                                                                                if (debugView == 30)
                                                                                {
                                                                                    float _4282 = clamp(_11815.x, 0.0, 1.0);
                                                                                    float _4283 = _11815.y;
                                                                                    if (_4283 > 0.0)
                                                                                    {
                                                                                        trust = clamp(_4283 - 0.00200000009499490261077880859375, 0.0, 1.0);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        trust = 0.0;
                                                                                    }
                                                                                    entryPointParam_fragmentMain = vec4(clamp((1.0 - _4282) - trust, 0.0, 1.0), _4282, trust, 1.0);
                                                                                }
                                                                                else
                                                                                {
                                                                                    if (debugView == 26)
                                                                                    {
                                                                                        if (lampShadows)
                                                                                        {
                                                                                            _152 = _11815.y <= 0.0;
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            _152 = false;
                                                                                        }
                                                                                        if (_152)
                                                                                        {
                                                                                            _154 = vec4(0.60000002384185791015625, 0.0, 0.0, 1.0);
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            _154 = vec4(lampOcclusion, lampOcclusion, lampOcclusion, 1.0);
                                                                                        }
                                                                                        entryPointParam_fragmentMain = _154;
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        int i = 0;
                                                                                        vec3 lampLight = vec3(0.0);
                                                                                        vec3 _11824;
                                                                                        float _11825;
                                                                                        float _11826;
                                                                                        float _11827;
                                                                                        vec3 _11828;
                                                                                        bool _11829;
                                                                                        float _11977;
                                                                                        float _12012;
                                                                                        float _12013;
                                                                                        float _12014;
                                                                                        for (;;)
                                                                                        {
                                                                                            bool _283_ladder_break = false;
                                                                                            {
                                                                                                if (!(i < _4058))
                                                                                                {
                                                                                                    _283_ladder_break = true;
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    {
                                                                                                        vec3 _11840 = lamps.positionRadius.data[i].xyz - _8760;
                                                                                                        float _11841 = dot(_11840, _11840);
                                                                                                        {
                                                                                                            float _11981 = lamps.positionRadius.data[i].w * lamps.positionRadius.data[i].w;
                                                                                                            if (_11841 >= _11981)
                                                                                                            {
                                                                                                                _11977 = 0.0;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                float _11986 = _11841 / (isnan(9.9999997473787516355514526367188e-05) ? _11981 : (isnan(_11981) ? 9.9999997473787516355514526367188e-05 : max(_11981, 9.9999997473787516355514526367188e-05)));
                                                                                                                float _11989 = clamp(1.0 - (_11986 * _11986), 0.0, 1.0);
                                                                                                                _11977 = _11989 * _11989;
                                                                                                            }
                                                                                                        }
                                                                                                        if (_11977 <= 0.0)
                                                                                                        {
                                                                                                            _11824 = vec3(0.0);
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            vec3 _11851 = (vec4(_11840, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz;
                                                                                                            vec3 _11854 = _11851 * inversesqrt(isnan(9.9999999392252902907785028219223e-09) ? _11841 : (isnan(_11841) ? 9.9999999392252902907785028219223e-09 : max(_11841, 9.9999999392252902907785028219223e-09)));
                                                                                                            if (dot(lamps.direction.data[i].xyz, lamps.direction.data[i].xyz) > 0.25)
                                                                                                            {
                                                                                                                float _12002 = dot(normalize((vec4(lamps.direction.data[i].xyz, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz), -_11854);
                                                                                                                _11825 = _11977 * (isnan(0.0) ? _12002 : (isnan(_12002) ? 0.0 : max(_12002, 0.0)));
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                _11825 = _11977;
                                                                                                            }
                                                                                                            if (_11825 <= 0.0)
                                                                                                            {
                                                                                                                _11824 = vec3(0.0);
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                float _11885 = clamp(lamps.direction.data[i].w, 0.0500000007450580596923828125, 1.0);
                                                                                                                vec3 _11894 = (vec4(lamps.rect.data[i].xyz, 0.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz;
                                                                                                                if (dot(_11894, _11894) > 9.9999997473787516355514526367188e-05)
                                                                                                                {
                                                                                                                    vec3 _11900 = _11851 - _11894;
                                                                                                                    vec3 _11901 = _11894 * 2.0;
                                                                                                                    {
                                                                                                                        float _12018 = dot(normal, _11900);
                                                                                                                        float _12019 = dot(normal, _11901);
                                                                                                                        if (abs(_12019) > 9.9999999747524270787835121154785e-07)
                                                                                                                        {
                                                                                                                            float _12028 = (-_12018) / _12019;
                                                                                                                            if (_12019 > 0.0)
                                                                                                                            {
                                                                                                                                _12013 = 1.0;
                                                                                                                                _12014 = isnan(_12028) ? 0.0 : (isnan(0.0) ? _12028 : max(0.0, _12028));
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                _12013 = isnan(_12028) ? 1.0 : (isnan(1.0) ? _12028 : min(1.0, _12028));
                                                                                                                                _12014 = 0.0;
                                                                                                                            }
                                                                                                                            if (_12013 <= _12014)
                                                                                                                            {
                                                                                                                                _12012 = 0.0;
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                float _12041 = dot(_11901, _11901);
                                                                                                                                float _12042 = dot(_11900, _11901);
                                                                                                                                float _12043 = dot(_11900, _11900);
                                                                                                                                float _12046 = (_12041 * _12043) - (_12042 * _12042);
                                                                                                                                if (_12046 <= ((9.9999997473787516355514526367188e-06 * _12041) * _12043))
                                                                                                                                {
                                                                                                                                    vec3 _12056 = _11900 + (_11901 * (0.5 * (_12014 + _12013)));
                                                                                                                                    float _12057 = dot(_12056, _12056);
                                                                                                                                    float _12058 = isnan(9.9999997473787516355514526367188e-05) ? _12057 : (isnan(_12057) ? 9.9999997473787516355514526367188e-05 : max(_12057, 9.9999997473787516355514526367188e-05));
                                                                                                                                    _12012 = (clamp(dot(normal, _12056) * inversesqrt(_12058), 0.0, 1.0) / _12058) * (_12013 - _12014);
                                                                                                                                }
                                                                                                                                else
                                                                                                                                {
                                                                                                                                    float _12070 = _12041 * _12014;
                                                                                                                                    float _12073 = 2.0 * _12042;
                                                                                                                                    float _12077 = ((_12070 * _12014) + (_12073 * _12014)) + _12043;
                                                                                                                                    float _12081 = _12041 * _12013;
                                                                                                                                    float _12087 = ((_12081 * _12013) + (_12073 * _12013)) + _12043;
                                                                                                                                    float _12108 = (((_12018 * (_12081 + _12042)) - (_12019 * ((_12042 * _12013) + _12043))) / (_12046 * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12087 : (isnan(_12087) ? 9.9999999392252902907785028219223e-09 : max(_12087, 9.9999999392252902907785028219223e-09))))) - (((_12018 * (_12070 + _12042)) - (_12019 * ((_12042 * _12014) + _12043))) / (_12046 * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12077 : (isnan(_12077) ? 9.9999999392252902907785028219223e-09 : max(_12077, 9.9999999392252902907785028219223e-09)))));
                                                                                                                                    _12012 = isnan(0.0) ? _12108 : (isnan(_12108) ? 0.0 : max(_12108, 0.0));
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            if (_12018 <= 0.0)
                                                                                                                            {
                                                                                                                                _12012 = 0.0;
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                _12013 = 1.0;
                                                                                                                                _12014 = 0.0;
                                                                                                                                if (_12013 <= _12014)
                                                                                                                                {
                                                                                                                                    _12012 = 0.0;
                                                                                                                                }
                                                                                                                                else
                                                                                                                                {
                                                                                                                                    float _12041 = dot(_11901, _11901);
                                                                                                                                    float _12042 = dot(_11900, _11901);
                                                                                                                                    float _12043 = dot(_11900, _11900);
                                                                                                                                    float _12046 = (_12041 * _12043) - (_12042 * _12042);
                                                                                                                                    if (_12046 <= ((9.9999997473787516355514526367188e-06 * _12041) * _12043))
                                                                                                                                    {
                                                                                                                                        vec3 _12056 = _11900 + (_11901 * (0.5 * (_12014 + _12013)));
                                                                                                                                        float _12057 = dot(_12056, _12056);
                                                                                                                                        float _12058 = isnan(9.9999997473787516355514526367188e-05) ? _12057 : (isnan(_12057) ? 9.9999997473787516355514526367188e-05 : max(_12057, 9.9999997473787516355514526367188e-05));
                                                                                                                                        _12012 = (clamp(dot(normal, _12056) * inversesqrt(_12058), 0.0, 1.0) / _12058) * (_12013 - _12014);
                                                                                                                                    }
                                                                                                                                    else
                                                                                                                                    {
                                                                                                                                        float _12070 = _12041 * _12014;
                                                                                                                                        float _12073 = 2.0 * _12042;
                                                                                                                                        float _12077 = ((_12070 * _12014) + (_12073 * _12014)) + _12043;
                                                                                                                                        float _12081 = _12041 * _12013;
                                                                                                                                        float _12087 = ((_12081 * _12013) + (_12073 * _12013)) + _12043;
                                                                                                                                        float _12108 = (((_12018 * (_12081 + _12042)) - (_12019 * ((_12042 * _12013) + _12043))) / (_12046 * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12087 : (isnan(_12087) ? 9.9999999392252902907785028219223e-09 : max(_12087, 9.9999999392252902907785028219223e-09))))) - (((_12018 * (_12070 + _12042)) - (_12019 * ((_12042 * _12014) + _12043))) / (_12046 * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12077 : (isnan(_12077) ? 9.9999999392252902907785028219223e-09 : max(_12077, 9.9999999392252902907785028219223e-09)))));
                                                                                                                                        _12012 = isnan(0.0) ? _12108 : (isnan(_12108) ? 0.0 : max(_12108, 0.0));
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                    vec3 _11904 = reflect(-_2942, normal);
                                                                                                                    float _11905 = dot(_11904, _11901);
                                                                                                                    float _11908 = dot(_11901, _11901) - (_11905 * _11905);
                                                                                                                    if (_11908 > 9.9999999747524270787835121154785e-07)
                                                                                                                    {
                                                                                                                        _11826 = ((dot(_11904, _11900) * _11905) - dot(_11900, _11901)) / _11908;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        _11826 = 0.5;
                                                                                                                    }
                                                                                                                    _11828 = _11900 + (_11901 * clamp(_11826, 0.0, 1.0));
                                                                                                                    _11826 = _12012;
                                                                                                                    _11827 = clamp(lamps.rect.data[i].w, 0.0199999995529651641845703125, _11885);
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    float _12008 = _11885 * _11885;
                                                                                                                    _11828 = _11851;
                                                                                                                    _11826 = clamp(dot(normal, _11854), 0.0, 1.0) / (isnan(_12008) ? _11841 : (isnan(_11841) ? _12008 : max(_11841, _12008)));
                                                                                                                    _11827 = _11885;
                                                                                                                }
                                                                                                                float _11927 = dot(_11828, _11828);
                                                                                                                float _11928 = isnan(9.9999999747524270787835121154785e-07) ? _11927 : (isnan(_11927) ? 9.9999999747524270787835121154785e-07 : max(_11927, 9.9999999747524270787835121154785e-07));
                                                                                                                vec3 _11931 = _11828 * inversesqrt(_11928);
                                                                                                                if (_11826 <= 0.0)
                                                                                                                {
                                                                                                                    _11829 = dot(normal, _11931) <= 0.0;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _11829 = false;
                                                                                                                }
                                                                                                                if (_11829)
                                                                                                                {
                                                                                                                    _11824 = vec3(0.0);
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    float _11947 = (isnan(0.0199999995529651641845703125) ? roughness : (isnan(roughness) ? 0.0199999995529651641845703125 : max(roughness, 0.0199999995529651641845703125))) * (isnan(0.0199999995529651641845703125) ? roughness : (isnan(roughness) ? 0.0199999995529651641845703125 : max(roughness, 0.0199999995529651641845703125)));
                                                                                                                    float _11953 = clamp(_11947 + (_11827 / (2.0 * sqrt(_11928))), 0.0, 1.0);
                                                                                                                    float _11957 = sqrt(_11953);
                                                                                                                    vec3 _12118 = mix(vec3(0.07999999821186065673828125 * specularLevel), albedo, vec3(metallic));
                                                                                                                    float _12119 = isnan(0.0199999995529651641845703125) ? _11957 : (isnan(_11957) ? 0.0199999995529651641845703125 : max(_11957, 0.0199999995529651641845703125));
                                                                                                                    float _12120 = _12119 * _12119;
                                                                                                                    float _12121 = _12120 * _12120;
                                                                                                                    vec3 _12122 = _2942 + _11931;
                                                                                                                    float _12123 = dot(_12122, _12122);
                                                                                                                    vec3 _12126 = _12122 * inversesqrt(isnan(9.9999999392252902907785028219223e-09) ? _12123 : (isnan(_12123) ? 9.9999999392252902907785028219223e-09 : max(_12123, 9.9999999392252902907785028219223e-09)));
                                                                                                                    float _12128 = clamp(dot(normal, _12126), 0.0, 1.0);
                                                                                                                    float _12132 = clamp(dot(normal, _11931), 0.0, 1.0);
                                                                                                                    float _12136 = clamp(abs(dot(normal, _2942)) + 9.9999997473787516355514526367188e-06, 0.0, 1.0);
                                                                                                                    float _12140 = ((_12128 * _12128) * (_12121 - 1.0)) + 1.0;
                                                                                                                    float _12147 = mix((2.0 * _12132) * _12136, _12132 + _12136, _12120);
                                                                                                                    float _11963 = _11827 * _11827;
                                                                                                                    _11824 = ((lamps.colourIntensity.data[i].xyz * lamps.colourIntensity.data[i].w) * _11825) * (((albedo * (1.0 - metallic)) * _11826) + ((((((_12118 + ((vec3(clamp(50.0 * _12118.y, 0.0, 1.0)) - _12118) * pow(1.0 - clamp(dot(_2942, _12126), 0.0, 1.0), 5.0))) * ((_12121 / ((3.1415927410125732421875 * _12140) * _12140)) * (0.5 / (isnan(9.9999999747524270787835121154785e-07) ? _12147 : (isnan(_12147) ? 9.9999999747524270787835121154785e-07 : max(_12147, 9.9999999747524270787835121154785e-07)))))) * _12132) * ((_11947 / _11953) * (_11947 / _11953))) * (1.0 / (isnan(_11963) ? _11928 : (isnan(_11928) ? _11963 : max(_11928, _11963))))) * 3.1415927410125732421875));
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                    vec3 lampTerm = _11824 * lampOcclusion;
                                                                                                    if (!(all(lessThanEqual(lampTerm, vec3(0.0)))))
                                                                                                    {
                                                                                                        sunLight += lampTerm;
                                                                                                        lampLight += lampTerm;
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                            if (_283_ladder_break)
                                                                                            {
                                                                                                break;
                                                                                            }
                                                                                            i++;
                                                                                            continue;
                                                                                        }
                                                                                        if (debugView == 14)
                                                                                        {
                                                                                            entryPointParam_fragmentMain = vec4(lampLight, 1.0);
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            vec3 flashLight;
                                                                                            if (any(greaterThan(_8762, vec3(0.0))))
                                                                                            {
                                                                                                vec3 _12170 = mix(vec3(0.07999999821186065673828125 * specularLevel), albedo, vec3(metallic));
                                                                                                float _12171 = isnan(0.0199999995529651641845703125) ? roughness : (isnan(roughness) ? 0.0199999995529651641845703125 : max(roughness, 0.0199999995529651641845703125));
                                                                                                float _12172 = _12171 * _12171;
                                                                                                float _12173 = _12172 * _12172;
                                                                                                vec3 _12174 = _2942 + flashDir;
                                                                                                float _12175 = dot(_12174, _12174);
                                                                                                vec3 _12178 = _12174 * inversesqrt(isnan(9.9999999392252902907785028219223e-09) ? _12175 : (isnan(_12175) ? 9.9999999392252902907785028219223e-09 : max(_12175, 9.9999999392252902907785028219223e-09)));
                                                                                                float _12180 = clamp(dot(normal, _12178), 0.0, 1.0);
                                                                                                float _12184 = clamp(dot(normal, flashDir), 0.0, 1.0);
                                                                                                float _12188 = clamp(abs(dot(normal, _2942)) + 9.9999997473787516355514526367188e-06, 0.0, 1.0);
                                                                                                float _12192 = ((_12180 * _12180) * (_12173 - 1.0)) + 1.0;
                                                                                                float _12199 = mix((2.0 * _12184) * _12188, _12184 + _12188, _12172);
                                                                                                vec3 flashLight_1 = ((((albedo * (1.0 - metallic)) * (_12184 * 0.3183098733425140380859375)) + (((_12170 + ((vec3(clamp(50.0 * _12170.y, 0.0, 1.0)) - _12170) * pow(1.0 - clamp(dot(_2942, _12178), 0.0, 1.0), 5.0))) * ((_12173 / ((3.1415927410125732421875 * _12192) * _12192)) * (0.5 / (isnan(9.9999999747524270787835121154785e-07) ? _12199 : (isnan(_12199) ? 9.9999999747524270787835121154785e-07 : max(_12199, 9.9999999747524270787835121154785e-07)))))) * _12184)) * _8762) * 3.1415927410125732421875;
                                                                                                flashLight = flashLight_1;
                                                                                                sunLight += flashLight_1;
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                flashLight = vec3(0.0);
                                                                                            }
                                                                                            if (debugView == 27)
                                                                                            {
                                                                                                entryPointParam_fragmentMain = vec4(flashLight, 1.0);
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                vec3 diffuseColour = albedo - (albedo * metallic);
                                                                                                bool gathered = gi.giParams.x > 0.0;
                                                                                                bool _4763 = !gathered;
                                                                                                if (_4763)
                                                                                                {
                                                                                                    _152 = true;
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    _152 = debugView == 9;
                                                                                                }
                                                                                                if (_152)
                                                                                                {
                                                                                                    _152 = gi.probeOrigin.w > 0.5;
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    _152 = false;
                                                                                                }
                                                                                                vec3 indirect;
                                                                                                if (_152)
                                                                                                {
                                                                                                    vec3 worldPos = (vec4(_8760, 1.0) * spvWorkaroundRowMajor(gi.viewToWorld)).xyz + gi.camera.xyz;
                                                                                                    vec3 grid = ((worldPos + (normal * gi.probeMisc.x)) - gi.probeOrigin.xyz) / vec3(gi.probeInvCount.w);
                                                                                                    vec3 uvw = (grid + vec3(0.5)) * gi.probeInvCount.xyz;
                                                                                                    if (all(greaterThanEqual(uvw, vec3(0.0))))
                                                                                                    {
                                                                                                        _152 = all(lessThanEqual(uvw, vec3(1.0)));
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        _152 = false;
                                                                                                    }
                                                                                                    if (_152)
                                                                                                    {
                                                                                                        vec4 sh = vec4(1.0, normal);
                                                                                                        float _4831 = dot(textureLod(_13537, uvw, 0.0), sh);
                                                                                                        float _4838 = dot(textureLod(_13539, uvw, 0.0), sh);
                                                                                                        float _4845 = dot(textureLod(_13541, uvw, 0.0), sh);
                                                                                                        vec3 probeLight = vec3(isnan(0.0) ? _4831 : (isnan(_4831) ? 0.0 : max(_4831, 0.0)), isnan(0.0) ? _4838 : (isnan(_4838) ? 0.0 : max(_4838, 0.0)), isnan(0.0) ? _4845 : (isnan(_4845) ? 0.0 : max(_4845, 0.0)));
                                                                                                        if (debugView == 9)
                                                                                                        {
                                                                                                            entryPointParam_fragmentMain = vec4(probeLight * gi.probeSky.xyz, 1.0);
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            vec4 _sampled_3 = textureLod(_13543, uvw, 0.0);
                                                                                                            float _4864 = _sampled_3.x;
                                                                                                            float _4866 = _sampled_3.y - (_4864 * _4864);
                                                                                                            float _4867 = isnan(9.9999997473787516355514526367188e-05) ? _4866 : (isnan(_4866) ? 9.9999997473787516355514526367188e-05 : max(_4866, 9.9999997473787516355514526367188e-05));
                                                                                                            float _4876 = length(worldPos - (gi.probeOrigin.xyz + (round(grid) * gi.probeInvCount.w)));
                                                                                                            if (_4876 > _4864)
                                                                                                            {
                                                                                                                float difference = _4876 - _4864;
                                                                                                                float trust_1 = _4867 / (_4867 + (difference * difference));
                                                                                                                trust = (trust_1 * trust_1) * trust_1;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                trust = 1.0;
                                                                                                            }
                                                                                                            indirect = mix(light.ambient.xyz, probeLight * gi.probeSky.xyz, vec3(trust * gi.probeMisc.y));
                                                                                                            if (debugView == 9)
                                                                                                            {
                                                                                                                entryPointParam_fragmentMain = vec4(0.0, 0.0, 0.0, 1.0);
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                if (gathered)
                                                                                                                {
                                                                                                                    indirect = textureLod(_13519, input_uv, 0.0).xyz * gi.giParams.x;
                                                                                                                }
                                                                                                                float ambientVisibility = _5390.w;
                                                                                                                if (gi.giParams.z > 0.5)
                                                                                                                {
                                                                                                                    trust = ambientVisibility * textureLod(_13517, input_uv, 0.0).x;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    trust = ambientVisibility;
                                                                                                                }
                                                                                                                vec3 indirect_1;
                                                                                                                if (trust < 1.0)
                                                                                                                {
                                                                                                                    vec3 _12224 = vec3(trust);
                                                                                                                    vec3 _12229 = ((((((albedo * 2.040400028228759765625) - vec3(0.3323999941349029541015625)) * trust) + (vec3(0.6417000293731689453125) - (albedo * 4.79510021209716796875))) * trust) + ((albedo * 2.755199909210205078125) + vec3(0.69029998779296875))) * trust;
                                                                                                                    bvec3 _14028 = isnan(_12224);
                                                                                                                    bvec3 _14029 = isnan(_12229);
                                                                                                                    vec3 _14030 = max(_12224, _12229);
                                                                                                                    vec3 _14031 = vec3(_14028.x ? _12229.x : _14030.x, _14028.y ? _12229.y : _14030.y, _14028.z ? _12229.z : _14030.z);
                                                                                                                    vec3 _12230 = vec3(_14029.x ? _12224.x : _14031.x, _14029.y ? _12224.y : _14031.y, _14029.z ? _12224.z : _14031.z);
                                                                                                                    if (gi.probeOrigin.w > 0.5)
                                                                                                                    {
                                                                                                                        _152 = _4763;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        _152 = false;
                                                                                                                    }
                                                                                                                    if (_152)
                                                                                                                    {
                                                                                                                        lampLight = mix(vec3(1.0), _12230, vec3(0.5));
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        lampLight = _12230;
                                                                                                                    }
                                                                                                                    indirect_1 = indirect * lampLight;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    indirect_1 = indirect;
                                                                                                                }
                                                                                                                float _5002 = clamp(dot(normal, _2942), 9.9999997473787516355514526367188e-05, 1.0);
                                                                                                                vec3 _5008 = mix(vec3(0.07999999821186065673828125 * specularLevel), albedo, vec3(metallic));
                                                                                                                float _12233 = 1.0 - roughness;
                                                                                                                float _12234 = _12233 * _12233;
                                                                                                                float _12236 = exp2((-9.27999973297119140625) * _5002);
                                                                                                                float _12244 = 1.03999996185302734375 * ((((isnan(_12236) ? _12234 : (isnan(_12234) ? _12236 : min(_12234, _12236))) * _12233) + 0.0425000004470348358154296875) - (0.0274999998509883880615234375 * roughness));
                                                                                                                vec2 _12249 = vec2((1.03999996185302734375 - (0.572000026702880859375 * roughness)) - _12244, ((0.02199999988079071044921875 * roughness) - 0.039999999105930328369140625) + _12244);
                                                                                                                vec3 ambientSpecular_1 = ((indirect * 0.3183098733425140380859375) * ((_5008 * _12249.x) + vec3(clamp(50.0 * _5008.y, 0.0, 1.0) * _12249.y))) * clamp((pow(_5002 + trust, roughness * roughness) - 1.0) + trust, 0.0, 1.0);
                                                                                                                vec3 ambientSpecular;
                                                                                                                if (gi.shelterMap2.z > 0.0)
                                                                                                                {
                                                                                                                    float _5078 = gi.shelterMap2.z * 0.25;
                                                                                                                    ambientSpecular = ambientSpecular_1 * (1.0 - clamp((gi.shelterMap2.z - roughness) / (isnan(0.001000000047497451305389404296875) ? _5078 : (isnan(_5078) ? 0.001000000047497451305389404296875 : max(_5078, 0.001000000047497451305389404296875))), 0.0, 1.0));
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    ambientSpecular = ambientSpecular_1;
                                                                                                                }
                                                                                                                if (gathered)
                                                                                                                {
                                                                                                                    vec3 _12262 = exp(vec3(-0.01024200022220611572265625, -0.01799800060689449310302734375, -0.03754000365734100341796875) * (_4059 * 0.001000000047497451305389404296875));
                                                                                                                    float _12263 = dot(_2114, worldRayToPixel);
                                                                                                                    float _12290 = 1.6400001049041748046875 + (_12263 * (-1.60000002384185791015625));
                                                                                                                    vec3 _12278 = (((((diffuseColour * 0.3183098733425140380859375) * indirect_1) + ambientSpecular) + sunLight) * _12262) + ((((vec3(0.00580199994146823883056640625, 0.0135580003261566162109375, 0.033100001513957977294921875) * (0.0596831031143665313720703125 * (1.0 + (_12263 * _12263)))) + vec3(0.0039960001595318317413330078125 * (0.359999954700469970703125 / ((12.56637096405029296875 * _12290) * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12290 : (isnan(_12290) ? 9.9999999392252902907785028219223e-09 : max(_12290, 9.9999999392252902907785028219223e-09))))))) * sunIlluminance) * ((vec3(1.0) - _12262) * vec3(97.637176513671875, 55.561725616455078125, 26.6382503509521484375)));
                                                                                                                    vec3 _12298;
                                                                                                                    {
                                                                                                                        bool _12299;
                                                                                                                        if (light.retailFog.w <= 0.0)
                                                                                                                        {
                                                                                                                            _12299 = true;
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            _12299 = gi.fog.z > 0.0;
                                                                                                                        }
                                                                                                                        if (_12299)
                                                                                                                        {
                                                                                                                            _12298 = _12278;
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            _12298 = mix(light.retailFog.xyz, _12278, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _4059 : (isnan(_4059) ? 0.0 : max(_4059, 0.0)))), 0.0, 1.0)));
                                                                                                                        }
                                                                                                                    }
                                                                                                                    vec3 _12331;
                                                                                                                    {
                                                                                                                        if (gi.fog.z <= 0.0)
                                                                                                                        {
                                                                                                                            _12331 = _12298;
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            float _12346 = (_4059 * gi.fog.x) + gi.fog.y;
                                                                                                                            vec4 _12361 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _12346 : (isnan(_12346) ? 9.9999999747524270787835121154785e-07 : max(_12346, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                                                            _12331 = (_12298 * _12361.w) + _12361.xyz;
                                                                                                                        }
                                                                                                                    }
                                                                                                                    entryPointParam_fragmentMain = vec4(_12331, 1.0);
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    vec4 _12371 = vec4(normal, 1.0);
                                                                                                                    vec4 _12387 = _12371.xyzz * _12371.yzzx;
                                                                                                                    vec3 _12412 = (vec3(dot(texelFetch(_13546, ivec2(0), 0), _12371), dot(texelFetch(_13546, ivec2(1, 0), 0), _12371), dot(texelFetch(_13546, ivec2(2, 0), 0), _12371)) + vec3(dot(texelFetch(_13546, ivec2(3, 0), 0), _12387), dot(texelFetch(_13546, ivec2(4, 0), 0), _12387), dot(texelFetch(_13546, ivec2(5, 0), 0), _12387))) + (texelFetch(_13546, ivec2(6, 0), 0).xyz * ((normal.x * normal.x) - (normal.y * normal.y)));
                                                                                                                    bvec3 _14058 = isnan(vec3(0.0));
                                                                                                                    bvec3 _14059 = isnan(_12412);
                                                                                                                    vec3 _14060 = max(vec3(0.0), _12412);
                                                                                                                    vec3 _14061 = vec3(_14058.x ? _12412.x : _14060.x, _14058.y ? _12412.y : _14060.y, _14058.z ? _12412.z : _14060.z);
                                                                                                                    vec3 _12419 = exp(vec3(-0.01024200022220611572265625, -0.01799800060689449310302734375, -0.03754000365734100341796875) * (_4059 * 0.001000000047497451305389404296875));
                                                                                                                    float _12420 = dot(_2114, worldRayToPixel);
                                                                                                                    float _12447 = 1.6400001049041748046875 + (_12420 * (-1.60000002384185791015625));
                                                                                                                    vec3 _12435 = ((((((albedo * indirect_1) * light.sunColourScale.w) + (vec3(_14059.x ? vec3(0.0).x : _14061.x, _14059.y ? vec3(0.0).y : _14061.y, _14059.z ? vec3(0.0).z : _14061.z) * diffuseColour)) + ambientSpecular) + sunLight) * _12419) + ((((vec3(0.00580199994146823883056640625, 0.0135580003261566162109375, 0.033100001513957977294921875) * (0.0596831031143665313720703125 * (1.0 + (_12420 * _12420)))) + vec3(0.0039960001595318317413330078125 * (0.359999954700469970703125 / ((12.56637096405029296875 * _12447) * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12447 : (isnan(_12447) ? 9.9999999392252902907785028219223e-09 : max(_12447, 9.9999999392252902907785028219223e-09))))))) * sunIlluminance) * ((vec3(1.0) - _12419) * vec3(97.637176513671875, 55.561725616455078125, 26.6382503509521484375)));
                                                                                                                    vec3 _12455;
                                                                                                                    {
                                                                                                                        bool _12456;
                                                                                                                        if (light.retailFog.w <= 0.0)
                                                                                                                        {
                                                                                                                            _12456 = true;
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            _12456 = gi.fog.z > 0.0;
                                                                                                                        }
                                                                                                                        if (_12456)
                                                                                                                        {
                                                                                                                            _12455 = _12435;
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            _12455 = mix(light.retailFog.xyz, _12435, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _4059 : (isnan(_4059) ? 0.0 : max(_4059, 0.0)))), 0.0, 1.0)));
                                                                                                                        }
                                                                                                                    }
                                                                                                                    vec3 _12488;
                                                                                                                    {
                                                                                                                        if (gi.fog.z <= 0.0)
                                                                                                                        {
                                                                                                                            _12488 = _12455;
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            float _12503 = (_4059 * gi.fog.x) + gi.fog.y;
                                                                                                                            vec4 _12518 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _12503 : (isnan(_12503) ? 9.9999999747524270787835121154785e-07 : max(_12503, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                                                            _12488 = (_12455 * _12518.w) + _12518.xyz;
                                                                                                                        }
                                                                                                                    }
                                                                                                                    entryPointParam_fragmentMain = vec4(_12488, 1.0);
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        indirect = light.ambient.xyz;
                                                                                                        if (debugView == 9)
                                                                                                        {
                                                                                                            entryPointParam_fragmentMain = vec4(0.0, 0.0, 0.0, 1.0);
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            if (gathered)
                                                                                                            {
                                                                                                                indirect = textureLod(_13519, input_uv, 0.0).xyz * gi.giParams.x;
                                                                                                            }
                                                                                                            float ambientVisibility = _5390.w;
                                                                                                            if (gi.giParams.z > 0.5)
                                                                                                            {
                                                                                                                trust = ambientVisibility * textureLod(_13517, input_uv, 0.0).x;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                trust = ambientVisibility;
                                                                                                            }
                                                                                                            vec3 indirect_1;
                                                                                                            if (trust < 1.0)
                                                                                                            {
                                                                                                                vec3 _12224 = vec3(trust);
                                                                                                                vec3 _12229 = ((((((albedo * 2.040400028228759765625) - vec3(0.3323999941349029541015625)) * trust) + (vec3(0.6417000293731689453125) - (albedo * 4.79510021209716796875))) * trust) + ((albedo * 2.755199909210205078125) + vec3(0.69029998779296875))) * trust;
                                                                                                                bvec3 _14028 = isnan(_12224);
                                                                                                                bvec3 _14029 = isnan(_12229);
                                                                                                                vec3 _14030 = max(_12224, _12229);
                                                                                                                vec3 _14031 = vec3(_14028.x ? _12229.x : _14030.x, _14028.y ? _12229.y : _14030.y, _14028.z ? _12229.z : _14030.z);
                                                                                                                vec3 _12230 = vec3(_14029.x ? _12224.x : _14031.x, _14029.y ? _12224.y : _14031.y, _14029.z ? _12224.z : _14031.z);
                                                                                                                if (gi.probeOrigin.w > 0.5)
                                                                                                                {
                                                                                                                    _152 = _4763;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _152 = false;
                                                                                                                }
                                                                                                                if (_152)
                                                                                                                {
                                                                                                                    lampLight = mix(vec3(1.0), _12230, vec3(0.5));
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    lampLight = _12230;
                                                                                                                }
                                                                                                                indirect_1 = indirect * lampLight;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                indirect_1 = indirect;
                                                                                                            }
                                                                                                            float _5002 = clamp(dot(normal, _2942), 9.9999997473787516355514526367188e-05, 1.0);
                                                                                                            vec3 _5008 = mix(vec3(0.07999999821186065673828125 * specularLevel), albedo, vec3(metallic));
                                                                                                            float _12233 = 1.0 - roughness;
                                                                                                            float _12234 = _12233 * _12233;
                                                                                                            float _12236 = exp2((-9.27999973297119140625) * _5002);
                                                                                                            float _12244 = 1.03999996185302734375 * ((((isnan(_12236) ? _12234 : (isnan(_12234) ? _12236 : min(_12234, _12236))) * _12233) + 0.0425000004470348358154296875) - (0.0274999998509883880615234375 * roughness));
                                                                                                            vec2 _12249 = vec2((1.03999996185302734375 - (0.572000026702880859375 * roughness)) - _12244, ((0.02199999988079071044921875 * roughness) - 0.039999999105930328369140625) + _12244);
                                                                                                            vec3 ambientSpecular_1 = ((indirect * 0.3183098733425140380859375) * ((_5008 * _12249.x) + vec3(clamp(50.0 * _5008.y, 0.0, 1.0) * _12249.y))) * clamp((pow(_5002 + trust, roughness * roughness) - 1.0) + trust, 0.0, 1.0);
                                                                                                            vec3 ambientSpecular;
                                                                                                            if (gi.shelterMap2.z > 0.0)
                                                                                                            {
                                                                                                                float _5078 = gi.shelterMap2.z * 0.25;
                                                                                                                ambientSpecular = ambientSpecular_1 * (1.0 - clamp((gi.shelterMap2.z - roughness) / (isnan(0.001000000047497451305389404296875) ? _5078 : (isnan(_5078) ? 0.001000000047497451305389404296875 : max(_5078, 0.001000000047497451305389404296875))), 0.0, 1.0));
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                ambientSpecular = ambientSpecular_1;
                                                                                                            }
                                                                                                            if (gathered)
                                                                                                            {
                                                                                                                vec3 _12262 = exp(vec3(-0.01024200022220611572265625, -0.01799800060689449310302734375, -0.03754000365734100341796875) * (_4059 * 0.001000000047497451305389404296875));
                                                                                                                float _12263 = dot(_2114, worldRayToPixel);
                                                                                                                float _12290 = 1.6400001049041748046875 + (_12263 * (-1.60000002384185791015625));
                                                                                                                vec3 _12278 = (((((diffuseColour * 0.3183098733425140380859375) * indirect_1) + ambientSpecular) + sunLight) * _12262) + ((((vec3(0.00580199994146823883056640625, 0.0135580003261566162109375, 0.033100001513957977294921875) * (0.0596831031143665313720703125 * (1.0 + (_12263 * _12263)))) + vec3(0.0039960001595318317413330078125 * (0.359999954700469970703125 / ((12.56637096405029296875 * _12290) * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12290 : (isnan(_12290) ? 9.9999999392252902907785028219223e-09 : max(_12290, 9.9999999392252902907785028219223e-09))))))) * sunIlluminance) * ((vec3(1.0) - _12262) * vec3(97.637176513671875, 55.561725616455078125, 26.6382503509521484375)));
                                                                                                                vec3 _12298;
                                                                                                                {
                                                                                                                    bool _12299;
                                                                                                                    if (light.retailFog.w <= 0.0)
                                                                                                                    {
                                                                                                                        _12299 = true;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        _12299 = gi.fog.z > 0.0;
                                                                                                                    }
                                                                                                                    if (_12299)
                                                                                                                    {
                                                                                                                        _12298 = _12278;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        _12298 = mix(light.retailFog.xyz, _12278, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _4059 : (isnan(_4059) ? 0.0 : max(_4059, 0.0)))), 0.0, 1.0)));
                                                                                                                    }
                                                                                                                }
                                                                                                                vec3 _12331;
                                                                                                                {
                                                                                                                    if (gi.fog.z <= 0.0)
                                                                                                                    {
                                                                                                                        _12331 = _12298;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        float _12346 = (_4059 * gi.fog.x) + gi.fog.y;
                                                                                                                        vec4 _12361 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _12346 : (isnan(_12346) ? 9.9999999747524270787835121154785e-07 : max(_12346, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                                                        _12331 = (_12298 * _12361.w) + _12361.xyz;
                                                                                                                    }
                                                                                                                }
                                                                                                                entryPointParam_fragmentMain = vec4(_12331, 1.0);
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                vec4 _12371 = vec4(normal, 1.0);
                                                                                                                vec4 _12387 = _12371.xyzz * _12371.yzzx;
                                                                                                                vec3 _12412 = (vec3(dot(texelFetch(_13546, ivec2(0), 0), _12371), dot(texelFetch(_13546, ivec2(1, 0), 0), _12371), dot(texelFetch(_13546, ivec2(2, 0), 0), _12371)) + vec3(dot(texelFetch(_13546, ivec2(3, 0), 0), _12387), dot(texelFetch(_13546, ivec2(4, 0), 0), _12387), dot(texelFetch(_13546, ivec2(5, 0), 0), _12387))) + (texelFetch(_13546, ivec2(6, 0), 0).xyz * ((normal.x * normal.x) - (normal.y * normal.y)));
                                                                                                                bvec3 _14058 = isnan(vec3(0.0));
                                                                                                                bvec3 _14059 = isnan(_12412);
                                                                                                                vec3 _14060 = max(vec3(0.0), _12412);
                                                                                                                vec3 _14061 = vec3(_14058.x ? _12412.x : _14060.x, _14058.y ? _12412.y : _14060.y, _14058.z ? _12412.z : _14060.z);
                                                                                                                vec3 _12419 = exp(vec3(-0.01024200022220611572265625, -0.01799800060689449310302734375, -0.03754000365734100341796875) * (_4059 * 0.001000000047497451305389404296875));
                                                                                                                float _12420 = dot(_2114, worldRayToPixel);
                                                                                                                float _12447 = 1.6400001049041748046875 + (_12420 * (-1.60000002384185791015625));
                                                                                                                vec3 _12435 = ((((((albedo * indirect_1) * light.sunColourScale.w) + (vec3(_14059.x ? vec3(0.0).x : _14061.x, _14059.y ? vec3(0.0).y : _14061.y, _14059.z ? vec3(0.0).z : _14061.z) * diffuseColour)) + ambientSpecular) + sunLight) * _12419) + ((((vec3(0.00580199994146823883056640625, 0.0135580003261566162109375, 0.033100001513957977294921875) * (0.0596831031143665313720703125 * (1.0 + (_12420 * _12420)))) + vec3(0.0039960001595318317413330078125 * (0.359999954700469970703125 / ((12.56637096405029296875 * _12447) * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12447 : (isnan(_12447) ? 9.9999999392252902907785028219223e-09 : max(_12447, 9.9999999392252902907785028219223e-09))))))) * sunIlluminance) * ((vec3(1.0) - _12419) * vec3(97.637176513671875, 55.561725616455078125, 26.6382503509521484375)));
                                                                                                                vec3 _12455;
                                                                                                                {
                                                                                                                    bool _12456;
                                                                                                                    if (light.retailFog.w <= 0.0)
                                                                                                                    {
                                                                                                                        _12456 = true;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        _12456 = gi.fog.z > 0.0;
                                                                                                                    }
                                                                                                                    if (_12456)
                                                                                                                    {
                                                                                                                        _12455 = _12435;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        _12455 = mix(light.retailFog.xyz, _12435, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _4059 : (isnan(_4059) ? 0.0 : max(_4059, 0.0)))), 0.0, 1.0)));
                                                                                                                    }
                                                                                                                }
                                                                                                                vec3 _12488;
                                                                                                                {
                                                                                                                    if (gi.fog.z <= 0.0)
                                                                                                                    {
                                                                                                                        _12488 = _12455;
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        float _12503 = (_4059 * gi.fog.x) + gi.fog.y;
                                                                                                                        vec4 _12518 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _12503 : (isnan(_12503) ? 9.9999999747524270787835121154785e-07 : max(_12503, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                                                        _12488 = (_12455 * _12518.w) + _12518.xyz;
                                                                                                                    }
                                                                                                                }
                                                                                                                entryPointParam_fragmentMain = vec4(_12488, 1.0);
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    indirect = light.ambient.xyz;
                                                                                                    if (debugView == 9)
                                                                                                    {
                                                                                                        entryPointParam_fragmentMain = vec4(0.0, 0.0, 0.0, 1.0);
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        if (gathered)
                                                                                                        {
                                                                                                            indirect = textureLod(_13519, input_uv, 0.0).xyz * gi.giParams.x;
                                                                                                        }
                                                                                                        float ambientVisibility = _5390.w;
                                                                                                        if (gi.giParams.z > 0.5)
                                                                                                        {
                                                                                                            trust = ambientVisibility * textureLod(_13517, input_uv, 0.0).x;
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            trust = ambientVisibility;
                                                                                                        }
                                                                                                        vec3 indirect_1;
                                                                                                        if (trust < 1.0)
                                                                                                        {
                                                                                                            vec3 _12224 = vec3(trust);
                                                                                                            vec3 _12229 = ((((((albedo * 2.040400028228759765625) - vec3(0.3323999941349029541015625)) * trust) + (vec3(0.6417000293731689453125) - (albedo * 4.79510021209716796875))) * trust) + ((albedo * 2.755199909210205078125) + vec3(0.69029998779296875))) * trust;
                                                                                                            bvec3 _14028 = isnan(_12224);
                                                                                                            bvec3 _14029 = isnan(_12229);
                                                                                                            vec3 _14030 = max(_12224, _12229);
                                                                                                            vec3 _14031 = vec3(_14028.x ? _12229.x : _14030.x, _14028.y ? _12229.y : _14030.y, _14028.z ? _12229.z : _14030.z);
                                                                                                            vec3 _12230 = vec3(_14029.x ? _12224.x : _14031.x, _14029.y ? _12224.y : _14031.y, _14029.z ? _12224.z : _14031.z);
                                                                                                            if (gi.probeOrigin.w > 0.5)
                                                                                                            {
                                                                                                                _152 = _4763;
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                _152 = false;
                                                                                                            }
                                                                                                            if (_152)
                                                                                                            {
                                                                                                                lampLight = mix(vec3(1.0), _12230, vec3(0.5));
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                lampLight = _12230;
                                                                                                            }
                                                                                                            indirect_1 = indirect * lampLight;
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            indirect_1 = indirect;
                                                                                                        }
                                                                                                        float _5002 = clamp(dot(normal, _2942), 9.9999997473787516355514526367188e-05, 1.0);
                                                                                                        vec3 _5008 = mix(vec3(0.07999999821186065673828125 * specularLevel), albedo, vec3(metallic));
                                                                                                        float _12233 = 1.0 - roughness;
                                                                                                        float _12234 = _12233 * _12233;
                                                                                                        float _12236 = exp2((-9.27999973297119140625) * _5002);
                                                                                                        float _12244 = 1.03999996185302734375 * ((((isnan(_12236) ? _12234 : (isnan(_12234) ? _12236 : min(_12234, _12236))) * _12233) + 0.0425000004470348358154296875) - (0.0274999998509883880615234375 * roughness));
                                                                                                        vec2 _12249 = vec2((1.03999996185302734375 - (0.572000026702880859375 * roughness)) - _12244, ((0.02199999988079071044921875 * roughness) - 0.039999999105930328369140625) + _12244);
                                                                                                        vec3 ambientSpecular_1 = ((indirect * 0.3183098733425140380859375) * ((_5008 * _12249.x) + vec3(clamp(50.0 * _5008.y, 0.0, 1.0) * _12249.y))) * clamp((pow(_5002 + trust, roughness * roughness) - 1.0) + trust, 0.0, 1.0);
                                                                                                        vec3 ambientSpecular;
                                                                                                        if (gi.shelterMap2.z > 0.0)
                                                                                                        {
                                                                                                            float _5078 = gi.shelterMap2.z * 0.25;
                                                                                                            ambientSpecular = ambientSpecular_1 * (1.0 - clamp((gi.shelterMap2.z - roughness) / (isnan(0.001000000047497451305389404296875) ? _5078 : (isnan(_5078) ? 0.001000000047497451305389404296875 : max(_5078, 0.001000000047497451305389404296875))), 0.0, 1.0));
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            ambientSpecular = ambientSpecular_1;
                                                                                                        }
                                                                                                        if (gathered)
                                                                                                        {
                                                                                                            vec3 _12262 = exp(vec3(-0.01024200022220611572265625, -0.01799800060689449310302734375, -0.03754000365734100341796875) * (_4059 * 0.001000000047497451305389404296875));
                                                                                                            float _12263 = dot(_2114, worldRayToPixel);
                                                                                                            float _12290 = 1.6400001049041748046875 + (_12263 * (-1.60000002384185791015625));
                                                                                                            vec3 _12278 = (((((diffuseColour * 0.3183098733425140380859375) * indirect_1) + ambientSpecular) + sunLight) * _12262) + ((((vec3(0.00580199994146823883056640625, 0.0135580003261566162109375, 0.033100001513957977294921875) * (0.0596831031143665313720703125 * (1.0 + (_12263 * _12263)))) + vec3(0.0039960001595318317413330078125 * (0.359999954700469970703125 / ((12.56637096405029296875 * _12290) * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12290 : (isnan(_12290) ? 9.9999999392252902907785028219223e-09 : max(_12290, 9.9999999392252902907785028219223e-09))))))) * sunIlluminance) * ((vec3(1.0) - _12262) * vec3(97.637176513671875, 55.561725616455078125, 26.6382503509521484375)));
                                                                                                            vec3 _12298;
                                                                                                            {
                                                                                                                bool _12299;
                                                                                                                if (light.retailFog.w <= 0.0)
                                                                                                                {
                                                                                                                    _12299 = true;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _12299 = gi.fog.z > 0.0;
                                                                                                                }
                                                                                                                if (_12299)
                                                                                                                {
                                                                                                                    _12298 = _12278;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _12298 = mix(light.retailFog.xyz, _12278, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _4059 : (isnan(_4059) ? 0.0 : max(_4059, 0.0)))), 0.0, 1.0)));
                                                                                                                }
                                                                                                            }
                                                                                                            vec3 _12331;
                                                                                                            {
                                                                                                                if (gi.fog.z <= 0.0)
                                                                                                                {
                                                                                                                    _12331 = _12298;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    float _12346 = (_4059 * gi.fog.x) + gi.fog.y;
                                                                                                                    vec4 _12361 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _12346 : (isnan(_12346) ? 9.9999999747524270787835121154785e-07 : max(_12346, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                                                    _12331 = (_12298 * _12361.w) + _12361.xyz;
                                                                                                                }
                                                                                                            }
                                                                                                            entryPointParam_fragmentMain = vec4(_12331, 1.0);
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            vec4 _12371 = vec4(normal, 1.0);
                                                                                                            vec4 _12387 = _12371.xyzz * _12371.yzzx;
                                                                                                            vec3 _12412 = (vec3(dot(texelFetch(_13546, ivec2(0), 0), _12371), dot(texelFetch(_13546, ivec2(1, 0), 0), _12371), dot(texelFetch(_13546, ivec2(2, 0), 0), _12371)) + vec3(dot(texelFetch(_13546, ivec2(3, 0), 0), _12387), dot(texelFetch(_13546, ivec2(4, 0), 0), _12387), dot(texelFetch(_13546, ivec2(5, 0), 0), _12387))) + (texelFetch(_13546, ivec2(6, 0), 0).xyz * ((normal.x * normal.x) - (normal.y * normal.y)));
                                                                                                            bvec3 _14058 = isnan(vec3(0.0));
                                                                                                            bvec3 _14059 = isnan(_12412);
                                                                                                            vec3 _14060 = max(vec3(0.0), _12412);
                                                                                                            vec3 _14061 = vec3(_14058.x ? _12412.x : _14060.x, _14058.y ? _12412.y : _14060.y, _14058.z ? _12412.z : _14060.z);
                                                                                                            vec3 _12419 = exp(vec3(-0.01024200022220611572265625, -0.01799800060689449310302734375, -0.03754000365734100341796875) * (_4059 * 0.001000000047497451305389404296875));
                                                                                                            float _12420 = dot(_2114, worldRayToPixel);
                                                                                                            float _12447 = 1.6400001049041748046875 + (_12420 * (-1.60000002384185791015625));
                                                                                                            vec3 _12435 = ((((((albedo * indirect_1) * light.sunColourScale.w) + (vec3(_14059.x ? vec3(0.0).x : _14061.x, _14059.y ? vec3(0.0).y : _14061.y, _14059.z ? vec3(0.0).z : _14061.z) * diffuseColour)) + ambientSpecular) + sunLight) * _12419) + ((((vec3(0.00580199994146823883056640625, 0.0135580003261566162109375, 0.033100001513957977294921875) * (0.0596831031143665313720703125 * (1.0 + (_12420 * _12420)))) + vec3(0.0039960001595318317413330078125 * (0.359999954700469970703125 / ((12.56637096405029296875 * _12447) * sqrt(isnan(9.9999999392252902907785028219223e-09) ? _12447 : (isnan(_12447) ? 9.9999999392252902907785028219223e-09 : max(_12447, 9.9999999392252902907785028219223e-09))))))) * sunIlluminance) * ((vec3(1.0) - _12419) * vec3(97.637176513671875, 55.561725616455078125, 26.6382503509521484375)));
                                                                                                            vec3 _12455;
                                                                                                            {
                                                                                                                bool _12456;
                                                                                                                if (light.retailFog.w <= 0.0)
                                                                                                                {
                                                                                                                    _12456 = true;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _12456 = gi.fog.z > 0.0;
                                                                                                                }
                                                                                                                if (_12456)
                                                                                                                {
                                                                                                                    _12455 = _12435;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    _12455 = mix(light.retailFog.xyz, _12435, vec3(clamp(exp((-light.retailFog.w) * (isnan(0.0) ? _4059 : (isnan(_4059) ? 0.0 : max(_4059, 0.0)))), 0.0, 1.0)));
                                                                                                                }
                                                                                                            }
                                                                                                            vec3 _12488;
                                                                                                            {
                                                                                                                if (gi.fog.z <= 0.0)
                                                                                                                {
                                                                                                                    _12488 = _12455;
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    float _12503 = (_4059 * gi.fog.x) + gi.fog.y;
                                                                                                                    vec4 _12518 = textureLod(_13505, vec3(input_uv, clamp(((log2(isnan(9.9999999747524270787835121154785e-07) ? _12503 : (isnan(_12503) ? 9.9999999747524270787835121154785e-07 : max(_12503, 9.9999999747524270787835121154785e-07))) * gi.fog.z) - 1.0) * gi.fog.w, 0.0, 1.0)), 0.0);
                                                                                                                    _12488 = (_12455 * _12518.w) + _12518.xyz;
                                                                                                                }
                                                                                                            }
                                                                                                            entryPointParam_fragmentMain = vec4(_12488, 1.0);
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

