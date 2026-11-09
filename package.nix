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
      hash = "sha256-y73AMRe3hsMeHJJE+I1TWL7y+QkW/s2cLgYDre8C+2Q=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-xcsq26txS7wNzIOkAhb74xzXQt+X+Ry3KUrRUx91KTE=";
    };
    x86_64-darwin = {
      target = "x86_64-apple-darwin";
      hash = "sha256-Ed6euf0o4El9sNBenDWMQ8z8PZCVk65WV10yi7gPVHE=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-l1XK+f6qqiYrANqE2U0FcaHn3VVMjFMZLAw5454MZkM=";
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
    version = "0.23.28";

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
