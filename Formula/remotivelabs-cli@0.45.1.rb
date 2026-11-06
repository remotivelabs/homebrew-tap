# Template for the versioned Homebrew formulas published to remotivelabs/homebrew-tap
# as Formula/remotivelabs-cli@<version>.rb — one file per release, next to the
# unversioned Formula/remotivelabs-cli.rb (rendered from remotivelabs-cli.rb.tmpl),
# which keeps tracking the latest release.
#
#   brew install remotivelabs/tap/remotivelabs-cli@0.45.2
#
# A versioned file is written once and never rewritten (the publish job and
# distribution/homebrew/backfill-versioned-formulas.sh skip existing files), so
# its version never changes and `brew upgrade` leaves it where it is.
#
#   0.45.1       CLI version, e.g. 0.45.2
#   RemotivelabsCliAT0451         Homebrew class name for remotivelabs-cli@<version>, e.g. RemotivelabsCliAT0452
#   beamy-public-releases        public GCS bucket name (vars.RELEASE_BUCKET)
#   707c622226e4abbd916c3b2678050c3868643b3aa74da2dd85104afeeb3b4c2f     sha256 of the arm64-darwin bundle
class RemotivelabsCliAT0451 < Formula
  desc "CLI for operating RemotiveCloud and RemotiveBroker (version 0.45.1)"
  homepage "https://github.com/remotivelabs/remotivelabs-cli"
  # version is scanned from the URL (0.45.1) — do not set it explicitly.
  license :cannot_represent # proprietary — see LICENSE

  # Apple Silicon (arm64) only — no Intel/x86_64 macOS build is published.
  on_macos do
    on_arm do
      url "https://storage.googleapis.com/beamy-public-releases/remotivelabs-cli/0.45.1/remotivelabs-cli-0.45.1-arm64-darwin.tar.gz"
      sha256 "707c622226e4abbd916c3b2678050c3868643b3aa74da2dd85104afeeb3b4c2f"
    end
  end

  # Both install bin/remotive, so only one can be linked at a time. homebrew-core
  # wants keg_only :versioned_formula here instead, but that leaves `remotive`
  # off PATH, which defeats the point for a CLI; conflicts_with keeps it linked
  # and makes brew ask to `brew unlink remotivelabs-cli` first. (`brew style`
  # reports this as FormulaAudit/Conflicts; that is expected.)
  conflicts_with "remotivelabs-cli", because: "both install the `remotive` command"

  def install
    # Same layout as the unversioned formula: the self-contained bundle under
    # libexec, launched through an absolute-path wrapper.
    libexec.install Dir["*"]
    (bin/"remotive").write <<~SH
      #!/bin/bash
      exec "#{libexec}/python/bin/python" "#{libexec}/python/bin/remotive" "$@"
    SH
    chmod 0755, bin/"remotive"
    # Releases before 0.44.0 do not ship the man page.
    man_page = libexec/"python/share/man/man1/remotive.1"
    man1.install_symlink man_page if man_page.exist?
  end

  test do
    assert_match "remotive", shell_output("#{bin}/remotive --help")
  end
end
