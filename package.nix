{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
}:

let
  sources = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-hyEJu7GR8L6MuYV0uLxzwTxLXEkmxQL93+lq8m/s27o=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-+KngaVAzJANoC0tILiIDVwxpbVG1LFOhFoIdQIGqYVQ=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-GGxWrtfik1g2R8zE9oQ7MUFkxOu2S28TIt9y4CbQTrI=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-9vfH1rgkeg0h8UHCuTmgWkyHrZWPm8b4Jz9OYOabi/E=";
    };
  };
in
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    source =
      sources.${stdenvNoCC.hostPlatform.system}
        or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
  in
  {
    pname = "ntn";
    version = "0.23.10";

    src = fetchurl {
      url = "https://ntn.dev/releases/v${finalAttrs.version}/ntn-${source.target}.tar.gz";
      inherit (source) hash;
    };

    sourceRoot = "ntn-${source.target}";
    dontBuild = true;
    strictDeps = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 ntn $out/bin/ntn

      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgramArg = "--version";

    meta = {
      description = "Command-line interface for the Notion API";
      homepage = "https://developers.notion.com/cli/get-started/overview";
      downloadPage = "https://ntn.dev/";
      license = lib.licenses.mit;
      mainProgram = "ntn";
      maintainers = [
        {
          name = "hovirix";
          github = "hovirix";
          githubId = 184756415;
        }
      ];
      platforms = builtins.attrNames sources;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  }
)
