{ mkCargoDerivation
, trunk
, wasm-bindgen-cli
, binaryen
, nodePackages
}:

{
  # this is not called cargoArtifacts to push users
  # away from giving us useless artifacts built
  # for native target instead of wasm32-unknown-unknown
  cargoArtifactsWasm
, indexPath ? "./index.html"
, trunkExtraArgs ? ""
, trunkExtraBuildArgs ? ""
, ...
}@origArgs:
let
  args = builtins.removeAttrs origArgs [
    "trunkExtraArgs"
    "trunkExtraBuildArgs"
  ];
in
mkCargoDerivation (args // {
  cargoArtifacts = cargoArtifactsWasm;
  pnameSuffix = "-trunk";

  buildPhaseCargoCommand = ''
    trunk ${trunkExtraArgs} build --release ${trunkExtraBuildArgs} ${indexPath}
  '';

  installPhase = ''
    cp -r "$(dirname ${indexPath})/dist" $out
  '';

  buildInputs = (args.buildInputs or [ ]) ++ [
    trunk
    wasm-bindgen-cli
    binaryen
    # dart-sass compiled to javascript
    # TODO: replace with a native version when it comes to nixpkgs
    nodePackages.sass
  ];
})
