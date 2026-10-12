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
      hash = "sha256-i6nqY5gdgiZUKGB98bXAjFQa/sQPfRVqKsf6vNBtTOA=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-xpXV49iQeCUwKCYxMR4iYBCe05BZ70bzfS8g4AcMk+0=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-Qwif6bWj5QsNG1g7XhEDz8j+9rWFhY6b6Xc6FD0PM5I=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-sL+DvlpRi4TdvQs3JOmiabOoDSATPk974UM+4TuLUzA=";
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
    version = "0.23.19";

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
