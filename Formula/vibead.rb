class Vibead < Formula
  desc "Try test ads and publisher messages in AI coding agents"
  homepage "https://github.com/vibead/cli"
  version "0.1.0-beta.25"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.25/vibead-beta-0.1.0-beta.25-darwin-arm64.tar.gz"
      sha256 "49ef5e57623b3710e52ef159c82e0f7c29bbfbe481de5aa6fd4fa5f2fb7d4c07"
    end
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.25/vibead-beta-0.1.0-beta.25-darwin-x64.tar.gz"
      sha256 "3efd2d0eb8f71d0305c8c1421005de50d2ecb25412ed731d859ca29fc43937be"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.25/vibead-beta-0.1.0-beta.25-linux-x64.tar.gz"
      sha256 "267cd47a7a8aab34003b4c945530688c0e394babe72de7c6b652ad238424f185"
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
    system libexec/"runtime/node", "-e", "require(process.argv[1]); require(process.argv[2])",
           libexec/"cli/node_modules/node-pty", libexec/"runtime/renderer.node"
    manifest = JSON.parse((libexec/"manifest.json").read)
    manifest.fetch("files").each do |file, checksum|
      assert_equal checksum, Digest::SHA256.file(libexec/file).hexdigest, "#{file} changed during installation"
    end
  end
end
