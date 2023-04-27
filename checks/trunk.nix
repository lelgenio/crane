{ pkgs
, myLib
, runCommand
}:

let
  wasmToolchain = pkgs.rust-bin.stable.latest.default.override {
    targets = [ "wasm32-unknown-unknown" ];
  };

  myLibWasm = myLib.overrideToolchain wasmToolchain;

  defaultArgs = {
    src = ./trunk;
    doCheck = false;
  };

  # default build
  cargoArtifactsWasm = myLibWasm.buildDepsOnly (defaultArgs // {
    cargoExtraArgs = "--target=wasm32-unknown-unknown";
  });
  trunkSimple = myLibWasm.buildTrunkPackage (defaultArgs // {
    inherit cargoArtifactsWasm;
    pname = "trunk-simple";
  });

  # Trying to build when cargoArtifacts does not contain
  # the wasm32-unknown-unknown target should throw an exception
  cargoArtifacts = myLibWasm.buildDepsOnly defaultArgs;
  trunkSimpleIncorrectArgs = myLibWasm.buildTrunkPackage (defaultArgs // {
    cargoArtifactsWasm = cargoArtifacts;
    pname = "trunk-simple-incorrect-args";
  });
in

assert (builtins.tryEval trunkSimpleIncorrectArgs).success == false;

runCommand "trunkTests" { } ''
  test -f ${trunkSimple}/*.wasm
  mkdir -p $out
''
