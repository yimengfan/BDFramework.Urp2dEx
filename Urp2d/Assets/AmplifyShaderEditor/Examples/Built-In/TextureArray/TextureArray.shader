// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/TextureArray"
{
	Properties
	{
		_TextureArrayAlbedo("Texture Array Albedo", 2DArray) = "white" {}
		_TextureArrayNormal("Texture Array Normal", 2DArray) = "white" {}
		_NormalScale("Normal Scale", Float) = 1
		_RoughScale("Rough Scale", Range( 0 , 1)) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.5
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D_ARRAY(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D_ARRAY(tex,samplertex,coord) tex2DArray(tex,coord)
		#endif//ASE Sampling Macros

		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_TextureArrayNormal);
		uniform float4 _TextureArrayNormal_ST;
		SamplerState sampler_TextureArrayNormal;
		uniform float _NormalScale;
		UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_TextureArrayAlbedo);
		uniform float4 _TextureArrayAlbedo_ST;
		SamplerState sampler_TextureArrayAlbedo;
		uniform float _RoughScale;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_TextureArrayNormal = i.uv_texcoord * _TextureArrayNormal_ST.xy + _TextureArrayNormal_ST.zw;
			o.Normal = UnpackScaleNormal( SAMPLE_TEXTURE2D_ARRAY( _TextureArrayNormal, sampler_TextureArrayNormal, float3(uv_TextureArrayNormal,0.0) ), _NormalScale );
			float2 uv_TextureArrayAlbedo = i.uv_texcoord * _TextureArrayAlbedo_ST.xy + _TextureArrayAlbedo_ST.zw;
			o.Albedo = SAMPLE_TEXTURE2D_ARRAY( _TextureArrayAlbedo, sampler_TextureArrayAlbedo, float3(uv_TextureArrayAlbedo,3.0) ).rgb;
			o.Smoothness = ( SAMPLE_TEXTURE2D_ARRAY( _TextureArrayAlbedo, sampler_TextureArrayAlbedo, float3(uv_TextureArrayAlbedo,1.0) ).r * _RoughScale );
			o.Occlusion = SAMPLE_TEXTURE2D_ARRAY( _TextureArrayAlbedo, sampler_TextureArrayAlbedo, float3(uv_TextureArrayAlbedo,1.0) ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
1995;19;1920;995;1011.642;221.5289;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;109;-559,64;Float;True;Constant;_RoughnessIndex;Roughness Index;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-553.9034,-373.3005;Float;False;Constant;_AlbedoIndex;Albedo Index;1;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-544,320;Float;False;Constant;_OcclusionIndex;Occlusion Index;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-304,240;Float;False;Property;_RoughScale;Rough Scale;3;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;105;-310.502,63.60038;Inherit;True;Property;_TextureArray2;Texture Array 2;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;108;Auto;Texture2DArray;8;0;SAMPLER2DARRAY;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;111;-614,-82;Float;False;Constant;_NormalIndex;Normal Index;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-598,-161;Float;False;Property;_NormalScale;Normal Scale;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;99.54906,25.52966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;108;-306.7961,-432.2489;Inherit;True;Property;_TextureArrayAlbedo;Texture Array Albedo;0;0;Create;True;0;0;0;False;0;False;-1;None;2a1e45aec61cb9b41830e680aef0d4bf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2DArray;8;0;SAMPLER2DARRAY;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;104;-320,320;Inherit;True;Property;_TextureArray3;Texture Array 3;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;108;Auto;Texture2DArray;8;0;SAMPLER2DARRAY;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;103;-304,-193;Inherit;True;Property;_TextureArrayNormal;Texture Array Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;18abd59f757787242ac884d340d0718c;True;0;False;white;Auto;True;Object;-1;Auto;Texture2DArray;8;0;SAMPLER2DARRAY;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;407.6068,-183.0747;Float;False;True;-1;3;ASEMaterialInspector;0;0;StandardSpecular;ASESampleShaders/TextureArray;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;105;6;109;0
WireConnection;117;0;105;1
WireConnection;117;1;118;0
WireConnection;108;6;113;0
WireConnection;104;6;110;0
WireConnection;103;5;123;0
WireConnection;103;6;111;0
WireConnection;0;0;108;0
WireConnection;0;1;103;0
WireConnection;0;4;117;0
WireConnection;0;5;104;1
ASEEND*/
//CHKSM=4045B7B05C1ADBE92F4EAD8DAC3CE77520FEDFFD