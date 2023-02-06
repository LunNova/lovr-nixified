{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    msdfgen = { url = "github:bjornbytes/msdfgen/lovr"; flake = false; };
    glslang = { url = "github:bjornbytes/glslang"; flake = false; };
    ode = { url = "github:bjornbytes/ode/lovr"; flake = false; };
    openxr = { url = "github:khronosgroup/openxr-sdk"; flake = false; };
  };

  outputs = flakeArgs@{ self, ... }:
    let
      lib = flakeArgs.nixpkgs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = lib.genAttrs supportedSystems
        (system: {
          lovr = flakeArgs.nixpkgs.legacyPackages.${system}.callPackage ./default.nix
            {
              inherit (flakeArgs) msdfgen ode glslang openxr;
            };
        });
    };
}
