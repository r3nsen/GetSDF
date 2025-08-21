#if OPENGL
#define SV_POSITION POSITION
#define VS_SHADERMODEL vs_3_0
#define PS_SHADERMODEL ps_3_0
#else
#define VS_SHADERMODEL vs_5_0
#define PS_SHADERMODEL ps_5_0
#endif

Texture2D tex;
float2 size;
sampler2D texture_sampler = sampler_state
{
	Texture = <tex>;
};

struct VertexShaderInput
{
	float4 position : POSITION0;
	float4 color : COLOR0;
	float2 tex: TEXCOORD0;
};
struct VertexShaderOutput
{
	float4 position : SV_POSITION;
	float4 color : COLOR0;
	float2 tex: TEXCOORD0;
};

matrix WorldViewProjection;

VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

	output.position = mul(input.position, WorldViewProjection);
	output.color = input.color;
	output.tex = input.tex;

	return output;
}

float getOutline(float2 uv)
{
	float currdepth = abs(tex2D(texture_sampler, uv).a);
	float up = tex2D(texture_sampler, uv - float2(0, 1 / size.y)).a,
		dn = tex2D(texture_sampler, uv + float2(0, 1 / size.y)).a,
		lt = tex2D(texture_sampler, uv - float2(1/ size.x, 0)).a,
		rt = tex2D(texture_sampler, uv + float2(1/ size.x, 0)).a;

	float outline = sign(
		abs(currdepth - lt) * (lt > currdepth) +
		abs(currdepth - rt) * (rt > currdepth) +
		abs(currdepth - up) * (up > currdepth) +
		abs(currdepth - dn) * (dn > currdepth));
	return outline;
}
float4 MainPS(VertexShaderOutput input) : COLOR
{
	float2 uv = input.tex;
	float currentOutline = getOutline(input.tex);
	float mindist = 0.;// getOutline(input);
	float4 col = tex2D(texture_sampler, uv);
	float currdepth = abs(tex2D(texture_sampler, input.tex).a);
	float s = 8.;

	if (currentOutline < .1||true) {
		mindist = 1000.;
		[loop] for (float i = -s; i < s; i++)
			[loop]for (float j = -s; j < s; j++)
		{
			float tempOutline = getOutline(input.tex + float2(i, j) / size);
			float dist = length(float2(i, j)) / s;
			if (tempOutline != 0)
				mindist = min(mindist, dist /** (col.a * 2. - 1.)*/);
		}
	}
	///*if (getOutline(float2(i,j)) > .9)*/ mindist = min(mindist, length(uv - float2(i, j)));
	float outside = (1. - mindist *(1. - col.a))*.5;
	float inside = (1. - (1. - mindist * (col.a))) * .5;
	float4 cor = (float4)(outside + inside);
	//cor.b = col.r;
	return cor;
	//return float4(mindist * (col.a * 2. - 1.),0.,-mindist * (col.a * 2. - 1.),1.);// abs(ddx(col.a)) + abs(ddy(col.a)) * input.color;// +col;
}

technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};