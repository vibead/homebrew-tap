class Vibead < Formula
  desc "Clearly labelled sponsored lines while your AI agent works"
  homepage "https://github.com/vibead/cli"
  version "0.1.0-beta.34"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.34/vibead-beta-0.1.0-beta.34-darwin-arm64.tar.gz"
      sha256 "b508b97d31d47611eccbe79a1b40b20cf57fed39cbf354753ee842ec189b6153"
    end
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.34/vibead-beta-0.1.0-beta.34-darwin-x64.tar.gz"
      sha256 "f235d131a4b74c9c9d1918b710f887eb9b877ffece6b406d8d54741578142641"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.34/vibead-beta-0.1.0-beta.34-linux-x64.tar.gz"
      sha256 "62e529bb34d2ee7804138cc23a3962db5d0e0e59c540d94920a7b78c351e1437"
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

      VibeAd shows a short sponsored line, labelled [Ad], in your agent's
      status area while it works. It does not read or change your prompts,
      code or replies. Turn it off at any time with: vibead disable
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
