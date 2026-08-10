# Template for the Homebrew cask published to remotivelabs/homebrew-tap.
# The `publish-homebrew-cask` job in remotive-studio-desktop_release.yaml
# renders this by substituting the @@TOKENS@@ and pushes the result to
# homebrew-tap/Casks/remotive-studio-desktop.rb.
#
#   0.0.46      app version, e.g. 0.0.41
#   1de2fdbf6798173eb0db755805f85ff72e30e19e9fe3a8ee2b7f820e11ff8197    sha256 of the arm64 DMG
#
# The DMG is Developer ID signed and notarized, so Gatekeeper accepts the
# installed app without a quarantine exception.
cask "remotive-studio-desktop" do
  version "0.0.46"
  sha256 "1de2fdbf6798173eb0db755805f85ff72e30e19e9fe3a8ee2b7f820e11ff8197"

  url "https://releases.beamylabs.com/remotive-studio-desktop/remotive-studio-desktop-#{version}/RemotiveStudio-#{version}-arm64.dmg",
      verified: "releases.beamylabs.com/remotive-studio-desktop/"
  name "RemotiveStudio"
  desc "Desktop app for RemotiveStudio, the RemotiveLabs recording workspace"
  homepage "https://remotivelabs.com/"

  # Only an Apple Silicon build is published; minimumSystemVersion is 12.0.
  depends_on arch: :arm64
  depends_on macos: :monterey

  livecheck do
    url "https://releases.beamylabs.com/remotive-studio-desktop/latest/latest-version.txt"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  app "RemotiveStudio.app"

  zap trash: [
    "~/Library/Application Support/RemotiveStudio",
    "~/Library/Logs/RemotiveStudio",
    "~/Library/Preferences/com.remotivelabs.studio.desktop.plist",
    "~/Library/Saved Application State/com.remotivelabs.studio.desktop.savedState",
  ]
end
