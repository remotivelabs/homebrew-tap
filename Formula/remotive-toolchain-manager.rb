# Template for the Homebrew formula published to remotivelabs/homebrew-tap.
# The `publish-homebrew` job in .github/workflows/TOOLCHAIN-MANAGER_release.yaml
# renders this by substituting the @@TOKENS@@ below and pushes the result to
# homebrew-tap/Formula/remotive-toolchain-manager.rb.
#
#   0.0.16       Toolchain Manager version, e.g. 0.0.16
#   beamy-public-releases        public GCS bucket name (vars.RELEASE_BUCKET)
#   8237022e872d80f0282aef942ba4e05bc6100b2da57f1537bec5941a0cfda01b     sha256 of the arm64-darwin archive
#
# The archive holds the Toolchain Manager (one signed, static binary) and its man
# page. The RemotiveCLI versions it runs are downloaded by it, not by Homebrew.
class RemotiveToolchainManager < Formula
  desc "Installs and runs the RemotiveCLI version a workspace asks for"
  homepage "https://github.com/remotivelabs/remotivelabs-cli"
  # version is scanned from the URL (0.0.16) — do not set it explicitly.
  license :cannot_represent # proprietary — see LICENSE

  # RemotiveCLI also installs `remotive`: only one of the two can be installed
  conflicts_with "remotivelabs/tap/remotivelabs-cli", because: "both install the remotive command"

  # Apple Silicon (arm64) only, as RemotiveCLI
  on_macos do
    on_arm do
      url "https://storage.googleapis.com/beamy-public-releases/remotivelabs-cli/toolchain-manager/0.0.16/remotive-toolchain-manager-0.0.16-arm64-darwin.tar.gz"
      sha256 "8237022e872d80f0282aef942ba4e05bc6100b2da57f1537bec5941a0cfda01b"
    end
  end

  def install
    # Homebrew strips the archive's single top-level dir (remotive-toolchain-manager/)
    bin.install "remotive"
    man1.install "remotive.1"
  end

  def caveats
    <<~EOS
      `remotive` installs the RemotiveCLI version it runs on first use.
      Update RemotiveCLI and the rest of the toolchain with:  remotive toolchain update
    EOS
  end

  test do
    assert_match "Toolchain Manager", shell_output("#{bin}/remotive toolchain --version")
    assert_path_exists man1/"remotive.1"
  end
end
