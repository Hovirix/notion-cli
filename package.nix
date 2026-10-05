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
      hash = "sha256-/LTtG7Q7ekZR7UGYEQ63mkEWwGD9Ed6Qc81DiJ76vOQ=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-SHY1E/ZOBPkM5RBLievQlCYkf/tsJ289u01z9eulZy4=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-hzvtfDFT5XlGXgH20psBNc6lG1X24R0fAd4waDpuyCo=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-methlVdxMDgCnDxeNTSKF66cbgJABGpDHOlUzhArFJs=";
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
    version = "0.23.17";

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
