{ inputs, ... }:

{
  imports = [ inputs.glyphtune.homeManagerModules.default ];

  glyphtune.icc.enable = true;
}
