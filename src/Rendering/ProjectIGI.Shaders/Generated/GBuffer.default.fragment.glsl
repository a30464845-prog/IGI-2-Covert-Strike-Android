#version 430

#ifndef SPIRV_CROSS_CONSTANT_ID_64
#define SPIRV_CROSS_CONSTANT_ID_64 1
#endif
const int cClipYDown = SPIRV_CROSS_CONSTANT_ID_64;
#ifndef SPIRV_CROSS_CONSTANT_ID_0
#define SPIRV_CROSS_CONSTANT_ID_0 0.501960813999176025390625
#endif
const float cAlphaReference = SPIRV_CROSS_CONSTANT_ID_0;
#ifndef SPIRV_CROSS_CONSTANT_ID_66
#define SPIRV_CROSS_CONSTANT_ID_66 0
#endif
const int cSamplerDecodes = SPIRV_CROSS_CONSTANT_ID_66;
#ifndef SPIRV_CROSS_CONSTANT_ID_13
#define SPIRV_CROSS_CONSTANT_ID_13 0.0
#endif
const float cSunDirectionX = SPIRV_CROSS_CONSTANT_ID_13;
#ifndef SPIRV_CROSS_CONSTANT_ID_14
#define SPIRV_CROSS_CONSTANT_ID_14 0.0
#endif
const float cSunDirectionY = SPIRV_CROSS_CONSTANT_ID_14;
#ifndef SPIRV_CROSS_CONSTANT_ID_15
#define SPIRV_CROSS_CONSTANT_ID_15 0.0
#endif
const float cSunDirectionZ = SPIRV_CROSS_CONSTANT_ID_15;
#ifndef SPIRV_CROSS_CONSTANT_ID_6
#define SPIRV_CROSS_CONSTANT_ID_6 0.0
#endif
const float cSunAmbientRed = SPIRV_CROSS_CONSTANT_ID_6;
#ifndef SPIRV_CROSS_CONSTANT_ID_7
#define SPIRV_CROSS_CONSTANT_ID_7 0.0
#endif
const float cSunAmbientGreen = SPIRV_CROSS_CONSTANT_ID_7;
#ifndef SPIRV_CROSS_CONSTANT_ID_8
#define SPIRV_CROSS_CONSTANT_ID_8 0.0
#endif
const float cSunAmbientBlue = SPIRV_CROSS_CONSTANT_ID_8;
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
const bool _248 = (cClipYDown != 0);
const bool _515 = (cSamplerDecodes != 0);

layout(binding = 1, std140) uniform GBufferPush_std140
{
    layout(row_major) mat4 modelViewProjection;
    vec4 normal0;
    vec4 normal1;
    vec4 normal2;
    vec4 material;
} push;

layout(binding = 0, std140) uniform SurfaceSettings_std140
{
    vec4 surface;
} frame;

layout(binding = 0) uniform sampler2D _1157;
layout(binding = 1) uniform sampler2D _1159;
layout(binding = 2) uniform sampler2D _1161;

layout(location = 0) out vec4 entryPointParam_fragmentMain_baseColour;
layout(location = 1) out vec4 entryPointParam_fragmentMain_normal;
layout(location = 2) out vec4 entryPointParam_fragmentMain_material;
layout(location = 3) out vec4 entryPointParam_fragmentMain_baked;
layout(location = 0) in vec2 input_diffuseUv;
layout(location = 1) in vec2 input_lightmapUv;
layout(location = 2) in vec4 input_color;
layout(location = 3) in vec3 input_worldNormal;
layout(location = 4) in float input_fade;
layout(location = 5) in vec3 input_surfacePosition;

void main()
{
    {
        vec4 _sampled = texture(_1157, input_diffuseUv);
        float alpha = _sampled.w * input_color.w;
        float _965 = fwidth(alpha);
        bool _392;
        if (push.normal2.w > 0.0)
        {
            _392 = _965 > 0.00200000009499490261077880859375;
        }
        else
        {
            _392 = false;
        }
        if (_392)
        {
            if (fract(sin(dot(gl_FragCoord.xy, vec2(12.98980045318603515625, 78.233001708984375)) + push.normal2.w) * 43758.546875) > clamp(((alpha - cAlphaReference) / _965) + 0.5, 0.0, 1.0))
            {
                discard;
            }
        }
        else
        {
            if (alpha < cAlphaReference)
            {
                discard;
            }
        }
        vec3 _505 = _sampled.xyz;
        vec3 _966;
        if (_515)
        {
            _966 = _505;
        }
        else
        {
            vec3 _981 = (_505 + vec3(0.054999999701976776123046875)) * vec3(0.947867333889007568359375);
            bvec3 _1163 = isnan(_981);
            bvec3 _1164 = isnan(vec3(0.0));
            vec3 _1165 = max(_981, vec3(0.0));
            vec3 _1166 = vec3(_1163.x ? vec3(0.0).x : _1165.x, _1163.y ? vec3(0.0).y : _1165.y, _1163.z ? vec3(0.0).z : _1165.z);
            _966 = mix(pow(vec3(_1164.x ? _981.x : _1166.x, _1164.y ? _981.y : _1166.y, _1164.z ? _981.z : _1166.z), vec3(2.400000095367431640625)), _505 * vec3(0.077399380505084991455078125), step(_505, vec3(0.040449999272823333740234375)));
        }
        vec3 _993 = (input_color.xyz + vec3(0.054999999701976776123046875)) * vec3(0.947867333889007568359375);
        bvec3 _1168 = isnan(_993);
        bvec3 _1169 = isnan(vec3(0.0));
        vec3 _1170 = max(_993, vec3(0.0));
        vec3 _1171 = vec3(_1168.x ? vec3(0.0).x : _1170.x, _1168.y ? vec3(0.0).y : _1170.y, _1168.z ? vec3(0.0).z : _1170.z);
        vec3 albedo_1 = (_966 * mix(pow(vec3(_1169.x ? _993.x : _1171.x, _1169.y ? _993.y : _1171.y, _1169.z ? _993.z : _1171.z), vec3(2.400000095367431640625)), input_color.xyz * vec3(0.077399380505084991455078125), step(input_color.xyz, vec3(0.040449999272823333740234375)))) * input_fade;
        vec4 _sampled_1 = texture(_1159, input_lightmapUv);
        vec3 _558 = _sampled_1.xyz;
        vec3 _998;
        if (_515)
        {
            _998 = _558;
        }
        else
        {
            vec3 _1013 = (_558 + vec3(0.054999999701976776123046875)) * vec3(0.947867333889007568359375);
            bvec3 _1173 = isnan(_1013);
            bvec3 _1174 = isnan(vec3(0.0));
            vec3 _1175 = max(_1013, vec3(0.0));
            vec3 _1176 = vec3(_1173.x ? vec3(0.0).x : _1175.x, _1173.y ? vec3(0.0).y : _1175.y, _1173.z ? vec3(0.0).z : _1175.z);
            _998 = mix(pow(vec3(_1174.x ? _1013.x : _1176.x, _1174.y ? _1013.y : _1176.y, _1174.z ? _1013.z : _1176.z), vec3(2.400000095367431640625)), _558 * vec3(0.077399380505084991455078125), step(_558, vec3(0.040449999272823333740234375)));
        }
        vec4 _1126;
        vec4 _1127;
        if (push.normal0.w > 3.5)
        {
            _1126 = vec4(0.0);
            _1127 = vec4(0.0);
            vec3 _1025 = (input_color.xyz + vec3(0.054999999701976776123046875)) * vec3(0.947867333889007568359375);
            bvec3 _1178 = isnan(_1025);
            bvec3 _1179 = isnan(vec3(0.0));
            vec3 _1180 = max(_1025, vec3(0.0));
            vec3 _1181 = vec3(_1178.x ? vec3(0.0).x : _1180.x, _1178.y ? vec3(0.0).y : _1180.y, _1178.z ? vec3(0.0).z : _1180.z);
            entryPointParam_fragmentMain_baseColour = vec4(0.0);
            entryPointParam_fragmentMain_normal = vec4(0.0);
            entryPointParam_fragmentMain_material = vec4(0.0);
            entryPointParam_fragmentMain_baked = vec4(_966 * mix(pow(vec3(_1179.x ? _1025.x : _1181.x, _1179.y ? _1025.y : _1181.y, _1179.z ? _1025.z : _1181.z), vec3(2.400000095367431640625)), input_color.xyz * vec3(0.077399380505084991455078125), step(input_color.xyz, vec3(0.040449999272823333740234375))), 1.0);
        }
        else
        {
            vec3 baked;
            vec3 albedo;
            if (push.normal0.w > 2.5)
            {
                vec4 _sampled_2 = texture(_1159, input_lightmapUv);
                vec3 _604 = _sampled_2.xyz;
                vec3 _1030;
                if (_515)
                {
                    _1030 = _604;
                }
                else
                {
                    vec3 _1045 = (_604 + vec3(0.054999999701976776123046875)) * vec3(0.947867333889007568359375);
                    bvec3 _1183 = isnan(_1045);
                    bvec3 _1184 = isnan(vec3(0.0));
                    vec3 _1185 = max(_1045, vec3(0.0));
                    vec3 _1186 = vec3(_1183.x ? vec3(0.0).x : _1185.x, _1183.y ? vec3(0.0).y : _1185.y, _1183.z ? vec3(0.0).z : _1185.z);
                    _1030 = mix(pow(vec3(_1184.x ? _1045.x : _1186.x, _1184.y ? _1045.y : _1186.y, _1184.z ? _1045.z : _1186.z), vec3(2.400000095367431640625)), _604 * vec3(0.077399380505084991455078125), step(_604, vec3(0.040449999272823333740234375)));
                }
                baked = vec3(push.material.w, push.material.w, push.material.w);
                albedo = albedo_1 * _1030;
            }
            else
            {
                baked = _998 * push.material.w;
                albedo = albedo_1;
            }
            vec3 _621 = normalize(input_worldNormal);
            if (push.normal0.w > 0.100000001490116119384765625)
            {
                _392 = push.normal0.w < 0.5;
            }
            else
            {
                _392 = false;
            }
            if (_392)
            {
                float _640 = ((cSunDirectionX * cSunDirectionX) + (cSunDirectionY * cSunDirectionY)) + (cSunDirectionZ * cSunDirectionZ);
                if (_640 > 9.9999999392252902907785028219223e-09)
                {
                    float _653 = (((_621.x * cSunDirectionX) + (_621.y * cSunDirectionY)) + (_621.z * cSunDirectionZ)) * inversesqrt(_640);
                    baked = clamp(vec3(cSunAmbientRed, cSunAmbientGreen, cSunAmbientBlue) + (vec3(cSunRed, cSunGreen, cSunBlue) * (isnan(0.0) ? _653 : (isnan(_653) ? 0.0 : max(_653, 0.0)))), vec3(0.0), vec3(1.0));
                }
            }
            bool matte = push.normal0.w < (-0.5);
            vec3 normal;
            float roughness;
            float occlusion;
            if (frame.surface.x > 0.0)
            {
                vec4 _sampled_3 = texture(_1161, input_diffuseUv);
                vec3 _688 = vec3((_sampled_3.xy * 2.0) - vec2(1.0), 0.0);
                vec2 _691 = _688.xy;
                float _693 = 1.0 - dot(_691, _691);
                _688.z = sqrt(isnan(0.0) ? _693 : (isnan(_693) ? 0.0 : max(_693, 0.0)));
                vec2 _1082 = dFdx(input_diffuseUv);
                vec2 _1085 = dFdy(input_diffuseUv);
                vec3 _1055 = cross(dFdy(input_surfacePosition), _621);
                vec3 _1056 = cross(_621, dFdx(input_surfacePosition));
                vec3 _1061 = (_1055 * _1082.x) + (_1056 * _1085.x);
                vec3 _1066 = (_1055 * _1082.y) + (_1056 * _1085.y);
                float _1067 = dot(_1061, _1061);
                float _1068 = dot(_1066, _1066);
                float _1069 = isnan(_1068) ? _1067 : (isnan(_1067) ? _1068 : max(_1067, _1068));
                float _1071 = inversesqrt(isnan(9.9999999392252902907785028219223e-09) ? _1069 : (isnan(_1069) ? 9.9999999392252902907785028219223e-09 : max(_1069, 9.9999999392252902907785028219223e-09)));
                normal = normalize(mix(_621, (((_1061 * _1071) * _688.x) + ((_1066 * _1071) * _688.y)) + (_621 * _688.z), vec3(frame.surface.x)));
                roughness = clamp(push.material.x * mix(1.0, _sampled_3.z * 2.0, clamp(frame.surface.x, 0.0, 1.0)), 0.0199999995529651641845703125, 1.0);
                occlusion = _sampled_3.w;
            }
            else
            {
                normal = _621;
                roughness = push.material.x;
                occlusion = 1.0;
            }
            if (frame.surface.y != 1.0)
            {
                _392 = !matte;
            }
            else
            {
                _392 = false;
            }
            if (_392)
            {
                float _812 = roughness * mix(1.0, frame.surface.y, smoothstep(0.550000011920928955078125, 0.85000002384185791015625, clamp(normal.z, 0.0, 1.0)));
                roughness = isnan(1.0) ? _812 : (isnan(_812) ? 1.0 : min(_812, 1.0));
            }
            vec3 _1088 = dFdx(normal);
            vec3 _1091 = dFdy(normal);
            float _825 = roughness;
            float _828 = (dot(_1088, _1088) + dot(_1091, _1091)) * 0.5;
            float _831 = (_825 * _825) + (isnan(0.180000007152557373046875) ? _828 : (isnan(_828) ? 0.180000007152557373046875 : min(_828, 0.180000007152557373046875)));
            _1126 = vec4(albedo, occlusion);
            _1127 = vec4((normalize(normal) * 0.5) + vec3(0.5), 0.0);
            int shadingModel;
            if (push.material.z > 0.0)
            {
                shadingModel = 0;
            }
            else
            {
                shadingModel = 1;
            }
            if (shadingModel == 0)
            {
                roughness = (128.0 + (clamp(push.material.z, 0.0625, 7.9375) * 16.0)) * 0.0039215688593685626983642578125;
            }
            else
            {
                roughness = 0.5;
            }
            float specular;
            if (push.normal0.w > 0.5)
            {
                specular = 0.0;
                roughness = 1.0;
            }
            else
            {
                specular = roughness;
                roughness = sqrt(isnan(_831) ? 1.0 : (isnan(1.0) ? _831 : min(1.0, _831)));
            }
            if (matte)
            {
                _392 = shadingModel == 1;
            }
            else
            {
                _392 = false;
            }
            float metallic;
            if (_392)
            {
                metallic = 0.0;
                specular = 0.0;
                roughness = 1.0;
                shadingModel |= 16;
            }
            else
            {
                metallic = push.material.y;
            }
            entryPointParam_fragmentMain_baseColour = _1126;
            entryPointParam_fragmentMain_normal = _1127;
            entryPointParam_fragmentMain_material = vec4(metallic, specular, isnan(0.015625) ? roughness : (isnan(roughness) ? 0.015625 : max(roughness, 0.015625)), float(shadingModel) * 0.0039215688593685626983642578125);
            entryPointParam_fragmentMain_baked = vec4(baked, 1.0);
        }
    }
}

