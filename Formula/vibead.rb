class Vibead < Formula
  desc "Try test ads and publisher messages in AI coding agents"
  homepage "https://github.com/vibead/cli"
  version "0.1.0-beta.12"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.12/vibead-beta-0.1.0-beta.12-darwin-arm64.tar.gz"
      sha256 "389e6591444c4fe4a0e0de97389ce7d27eb2401a8b5d232f3a15f00a72ade8a4"
    end
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.12/vibead-beta-0.1.0-beta.12-darwin-x64.tar.gz"
      sha256 "ae0dbfce66e971f04813d39d597541caa542fbad84ec2d07b41760822bcf4b0d"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.12/vibead-beta-0.1.0-beta.12-linux-x64.tar.gz"
      sha256 "940af00180c3534447a480aae1816b7da7f1b865cec73b4904f5a3b984737571"
    end
  end

  # Preserve the signed executables, native modules and their relative paths.
  skip_clean "libexec"

  def install
    if OS.linux? && Version.new(Utils.safe_popen_read("getconf", "GNU_LIBC_VERSION").split.last) < Version.new("2.34")
      odie "Vibead requires Linux x64 with glibc 2.34 or newer."
    end

    libexec.install Dir["*"]
    (bin/"vibead").write <<~EOS
      #!/bin/sh
      if [ "$#" -eq 1 ] && { [ "$1" = "--version" ] || [ "$1" = "-v" ]; }; then
        printf '%s\\n' '#{version}'
        exit 0
      fi
      exec "#{libexec}/vibead-beta" "$@"
    EOS
    bin.install_symlink bin/"vibead" => "vibead-beta"
  end

  def caveats
    <<~EOS
      Start from a project where your agent already works:
        vibead claude
        vibead codex
        vibead gemini
        vibead opencode

      This beta uses simulated ads and generates no earnings or credits.
      Your normal AI provider charges still apply.
      Guide: https://github.com/vibead/cli
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/vibead --version").strip
    assert_match "Vibead standalone beta", shell_output("#{bin}/vibead --help")
    assert_match "--test-publisher", shell_output("#{bin}/vibead-beta --help")
    assert_predicate libexec/"runtime/node", :executable?
    assert_path_exists libexec/"runtime/renderer.node"
    assert_path_exists libexec/"cli/node_modules/node-pty/build/Release/pty.node"
    manifest = JSON.parse((libexec/"manifest.json").read)
    manifest.fetch("files").each do |file, checksum|
      assert_equal checksum, Digest::SHA256.file(libexec/file).hexdigest, "#{file} changed during installation"
    end
  end
end
