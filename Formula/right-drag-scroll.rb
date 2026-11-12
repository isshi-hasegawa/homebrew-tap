class RightDragScroll < Formula
  desc "Scroll by dragging with the right mouse button on macOS"
  homepage "https://github.com/isshi-hasegawa/right-drag-scroll"
  url "https://github.com/isshi-hasegawa/right-drag-scroll/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "64e0878e43413dadb71fa6fc5221762cb795b5ba5a0c90aa2a5af7a3efa2110e"
  license "MIT"

  depends_on :macos

  BUNDLE_ID = "io.github.isshi-hasegawa.RightDragScroll".freeze

  def install
    system "swiftc", "-O", "Sources/main.swift", "-o", "RightDragScroll"

    contents = prefix/"RightDragScroll.app/Contents"
    (contents/"MacOS").install "RightDragScroll"
    (contents/"Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
      <key>CFBundleIdentifier</key><string>#{BUNDLE_ID}</string>
      <key>CFBundleName</key><string>RightDragScroll</string>
      <key>CFBundleExecutable</key><string>RightDragScroll</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>#{version}</string>
      <key>CFBundleVersion</key><string>#{version}</string>
      <key>LSUIElement</key><true/>
      </dict></plist>
    XML

    # Sign with an identifier-only requirement so the Accessibility grant survives upgrades.
    system "codesign", "--force", "--sign", "-",
           "-r=designated => identifier \"#{BUNDLE_ID}\"", prefix/"RightDragScroll.app"

    bin.install_symlink contents/"MacOS/RightDragScroll" => "right-drag-scroll"
  end

  service do
    run opt_prefix/"RightDragScroll.app/Contents/MacOS/RightDragScroll"
    keep_alive true
    process_type :interactive
  end

  def caveats
    <<~EOS
      Start it (and at every login) with:
        brew services start right-drag-scroll

      Then allow it once in System Settings > Privacy & Security > Accessibility:
        #{opt_prefix}/RightDragScroll.app
    EOS
  end

  test do
    assert_match "scrollMultiplier", shell_output("#{bin}/right-drag-scroll --show-settings")
  end
end
