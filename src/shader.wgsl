// Vertex shader

struct VertexInput {
  @location(0) position: vec3<f32>,
  @location(1) tex_coords: vec2<f32>,
};

struct VertexOutput {
  @builtin(position) clip_position: vec4<f32>,
  @location(0) tex_coords: vec2<f32>,
};

@vertex
fn vs_main(
  model: VertexInput,
) -> VertexOutput {
  var out: VertexOutput;
  out.tex_coords = model.tex_coords;
  out.clip_position = vec4<f32>(model.position, 1.0);
  return out;
}

// Fragment shader
@group(0) @binding(0)
var t_diffuse: texture_2d<f32>;
@group(0)@binding(1)
var s_diffuse: sampler;

fn step(pos: vec2<f32>, startPos: vec2<f32>) -> vec2<f32> {
  return vec2<f32>(pos.x * pos.x - pos.y * pos.y, 2.0 * (pos.x * pos.y)) + startPos;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  let tex_color = textureSample(t_diffuse, s_diffuse, in.tex_coords * 2.0 - 0.5);

  let max_steps = 100u;

  let startZoom = 2.7;
  let startPos = vec2<f32>((in.tex_coords.x - 0.7) * startZoom, (in.tex_coords.y - 0.5) * startZoom);
  var stepPos: vec2<f32> = startPos;
  var breakStep: f32 = 0.0;
  for (var i=0u; i < max_steps; i++) {
    if (length(stepPos) > 1000000.0) {
      breakStep = f32(i);
      break;
    }
    stepPos = step(stepPos, startPos);
  }

  let rb = clamp(breakStep, 0.0, 1.0);

  let background_color = vec3<f32>(rb * clamp(breakStep * breakStep / f32(max_steps), 0., 1.), clamp(breakStep * 2. / f32(max_steps), 0., 1.), rb * clamp(breakStep * 0.2 / f32(max_steps), 0., 1.));

  return vec4<f32>(vec3<f32>(1.0) * tex_color.a + background_color * (1.0 - tex_color.a), 1.0);
}
