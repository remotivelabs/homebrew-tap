# Template for the Homebrew formula published to remotivelabs/homebrew-tap.
# The `publish-homebrew` job in .github/workflows/cli-release.yaml renders this
# by substituting the @@TOKENS@@ below and pushes the result to
# homebrew-tap/Formula/remotive-cli.rb.
#
#   0.23.6       CLI version, e.g. 0.23.1
#   beamy-public-releases        public GCS bucket name (vars.RELEASE_BUCKET)
#   33125a6c361746f806d441b1a444d53902c047da32e10299c56bd0041193e8bc     sha256 of the arm64-darwin bundle
#
# The bundle ships its own CPython, so the formula has no Python dependency and
# just symlinks the `remotive` wrapper into the Homebrew prefix.
class RemotiveCli < Formula
  desc "CLI for operating RemotiveCloud and RemotiveBroker"
  homepage "https://github.com/remotivelabs/remotivelabs-cli"
  # version is scanned from the URL (0.23.6) — do not set it explicitly.
  license :cannot_represent # proprietary — see LICENSE

  # Apple Silicon (arm64) only — no Intel/x86_64 macOS build is published.
  on_macos do
    on_arm do
      url "https://storage.googleapis.com/beamy-public-releases/remotivelabs-cli/0.23.6/remotivelabs-cli-0.23.6-arm64-darwin.tar.gz"
      sha256 "33125a6c361746f806d441b1a444d53902c047da32e10299c56bd0041193e8bc"
    end
  end

  def install
    # The tarball's single top-level dir (remotivelabs-cli/) is stripped by
    # Homebrew, so the staging dir already holds python/ and the remotive
    # wrapper directly. Install the whole self-contained bundle under libexec.
    libexec.install Dir["*"]
    # Launch via an absolute path rather than symlinking the bundled wrapper:
    # that wrapper derives its dir from $BASH_SOURCE, which would resolve to
    # bin/ (not libexec/) if reached through a Homebrew symlink.
    (bin/"remotive").write <<~SH
      #!/bin/bash
      exec "#{libexec}/python/bin/python" "#{libexec}/python/bin/remotive" "$@"
    SH
    chmod 0755, bin/"remotive"
  end

  test do
    assert_match "remotive", shell_output("#{bin}/remotive --help")
  end
end
