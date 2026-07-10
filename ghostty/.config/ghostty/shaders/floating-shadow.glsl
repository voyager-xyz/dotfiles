// floating-shadow.glsl
// Makes terminal text look lifted off the surface by casting a soft drop
// shadow down-and-right of every glyph. No motion - a calm, work-friendly
// "floating" look. Shadow is rendered by darkening the background under a
// blurred, offset copy of the glyph coverage; the original text is left
// untouched on top so it stays crisp.
//
// Tune these to taste:
const vec2  SHADOW_OFFSET   = vec2(3.0, 4.0); // pixels: x = right, y = down
const float SHADOW_BLUR     = 1.6;            // softness radius (pixel step per tap)
const float SHADOW_STRENGTH = 0.6;            // 0 = no shadow, 1 = pure black

float lum(vec3 c) {
  return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 res = iResolution.xy;
  vec2 uv  = fragCoord / res;

  // The glyph that casts a shadow onto this pixel sits up-and-left of it.
  // fragCoord has y pointing up, so "down" on screen is -y.
  vec2 glyphCoord = fragCoord - vec2(SHADOW_OFFSET.x, -SHADOW_OFFSET.y);

  // Blurred glyph coverage = soft shadow mask. Gaussian-weighted 5x5 kernel.
  float shadowMask = 0.0;
  float total      = 0.0;
  for (int x = -2; x <= 2; x++) {
    for (int y = -2; y <= 2; y++) {
      vec2  o = vec2(float(x), float(y)) * SHADOW_BLUR;
      float w = exp(-float(x * x + y * y) / 4.0);
      shadowMask += lum(texture(iChannel0, (glyphCoord + o) / res).rgb) * w;
      total      += w;
    }
  }
  shadowMask /= total;

  vec4  src  = texture(iChannel0, uv);
  float here = lum(src.rgb); // how much ink is on THIS pixel

  // Only darken where this pixel is background, so glyphs themselves stay lit.
  float shade = shadowMask * (1.0 - smoothstep(0.0, 0.3, here));
  vec3  col   = src.rgb * (1.0 - SHADOW_STRENGTH * shade);

  fragColor = vec4(col, src.a);
}
