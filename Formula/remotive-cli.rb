# AUTO-GENERATED — do not edit by hand.
# The `publish-homebrew` job in remotivelabs/remotivelabs-cli's
# .github/workflows/cli-release.yaml regenerates and pushes this file on every
# final release (from distribution/homebrew/remotive-cli.rb.tmpl). The version
# and sha256 values below are placeholders until the first release with macOS
# artifacts runs.
#
# The bundle ships its own CPython, so the formula has no Python dependency and
# just launches the bundled interpreter.
class RemotiveCli < Formula
  desc "CLI for operating RemotiveCloud and RemotiveBroker"
  homepage "https://github.com/remotivelabs/remotivelabs-cli"
  # version is scanned from the URL — do not set it explicitly.
  license :cannot_represent # proprietary — see LICENSE

  on_macos do
    on_arm do
      url "https://storage.googleapis.com/beamy-public-releases/remotivelabs-cli/0.0.0/remotivelabs-cli-0.0.0-arm64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://storage.googleapis.com/beamy-public-releases/remotivelabs-cli/0.0.0/remotivelabs-cli-0.0.0-x86_64-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
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
