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
      hash = "sha256-BRWPqQml9ELfFY8qJMEs5LGrufmQRsOu37RxswXRjGg=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-C4M7d2v9T7IJ+DjwKVaVD5HCgt61TgNbdmSr3AW2dUQ=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-Fd17VHVWi0Iww+ZCM/ykpJT510jEBAPFWiiAYEvYFFg=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-uDMx9ILEPRCeX1xIuMXzw79joG8GhEQ3GTgB6PI+8dU=";
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
    version = "0.23.31";

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
