{ pkgs
, myLib
, runCommand
}:

let
  wasmToolchain = pkgs.rust-bin.stable.latest.default.override {
    targets = [ "wasm32-unknown-unknown" ];
  };

  myLibWasm = myLib.overrideToolchain wasmToolchain;

  src = ./trunk;

  cargoArtifactsWasm = myLibWasm.buildDepsOnly {
    inherit src;
    cargoExtraArgs = "--target=wasm32-unknown-unknown";
    doCheck = false;
  };

  trunkSimple = myLibWasm.buildTrunkPackage {
    inherit src cargoArtifactsWasm;
    pname = "trunk-simple";
  };
in
runCommand "trunkTests" { } ''
  test -f ${trunkSimple}/*.wasm
  mkdir -p $out
''
