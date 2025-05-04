{
  description = "A flake that showcases how to use nvidia GPUs inside nix sandbox";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    };
  in {
    packages.x86_64-linux.nvidia-smi = pkgs.stdenvNoCC.mkDerivation {
      name = "nvidia-smi-runner";
      version = "0.0.0";

      src = null;
      unpackPhase = "true";

      cudaSupport = true;
      requiredSystemFeatures = ["cuda"];
      env = {
        LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [pkgs.linuxPackages.nvidia_x11_beta]}";
      };
      nativeBuildInputs = [
        (pkgs.python312.withPackages (
          ppkgs: [pkgs.python312Packages.torchWithCuda]
        ))
      ];

      buildPhase = ''
        mkdir -p $out
        python -c "import torch; print(f'{torch.cuda.is_available()=}')"
        ${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi > $out/output.log
      '';
    };
  };
}
