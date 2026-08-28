{
  lib,
  rustPlatform,
  fetchFromGitHub,
  perl,
}:

rustPlatform.buildRustPackage rec {
  pname = "atlassian-cli";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "omar16100";
    repo = "atlassian-cli";
    rev = "v${version}";
    hash = "sha256-Rwk6/rSbMnJ3NFWp2IHxwna1uwR+KNZmIF2cdg2IjIs=";
  };

  cargoHash = "sha256-L8JGAIQKrK/lPzIMS6o4TsNImcQ58xWn1fAEsWqMeT0=";

  # reqwest is built with `native-tls-vendored`, which compiles OpenSSL from
  # source via openssl-src. That build is driven by perl.
  nativeBuildInputs = [ perl ];

  # The auth tests read and write `$HOME/.atlassian-cli/credentials.enc`
  # directly (fixed upstream after 0.7.2, which moved CredentialStore onto an
  # injected directory). The sandbox HOME is read-only, so give them a
  # throwaway one rather than disabling the test.
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  meta = {
    description = "Unified CLI for Atlassian Cloud products (Jira, Confluence, Bitbucket)";
    homepage = "https://atlassiancli.com";
    changelog = "https://github.com/omar16100/atlassian-cli/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "atlassian-cli";
    platforms = lib.platforms.unix;
  };
}
