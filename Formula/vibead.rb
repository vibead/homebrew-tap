class Vibead < Formula
  desc "Clearly labelled sponsored lines while your AI agent works"
  homepage "https://github.com/vibead/cli"
  version "0.1.0-beta.41"
  # caveats-for: 0.1.0-beta.41
  # The caveats and brew test below were written for that version. update-formula.sh
  # never moves the formula past it, and the "Formula check" workflow stays red until
  # the formula ships it: change the caveats in a reviewed tap PR, then this line.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.41/vibead-beta-0.1.0-beta.41-darwin-arm64.tar.gz"
      sha256 "073d9f60dbbd5fd5da2c5eb67c653a825237c8c6e93f7e9cbec628e421224faf"
    end
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.41/vibead-beta-0.1.0-beta.41-darwin-x64.tar.gz"
      sha256 "8427d1e99d3644bc8bd4a18ff76bacc42e0f19cfd93bf0cd687ba1a668543693"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.41/vibead-beta-0.1.0-beta.41-linux-x64.tar.gz"
      sha256 "d17e9d229877996576fddfb6d3f9e65cb4e2b198ca19722e2eea6b52e54fe788"
    end
  end

  # Preserve the signed executables, native modules and their relative paths.
  skip_clean "libexec"

  def install
    if OS.linux? && Version.new(Utils.safe_popen_read("getconf", "GNU_LIBC_VERSION").split.last) < Version.new("2.34")
      odie "VibeAd requires Linux x64 with glibc 2.34 or newer."
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
  end

  def caveats
    <<~EOS
      Run vibead once to connect Claude Code, Codex and OpenCode:
        vibead
      It prints what it changed. Then start your agent as usual.
      Codex: open a new terminal.
      Codex asks you to trust VibeAd's hooks; ads show after you choose Trust. It asks again each time you turn VibeAd off and back on.

      VibeAd shows a short sponsored line, labelled [Ad], in the agent's
      status line, working indicator or notification area while it works.
      It does not read or change your prompts, code or replies.
      Turn it off at any time with: vibead disable
      Remove it with: vibead uninstall && brew uninstall vibead
      Your normal AI provider charges still apply.
      Guide: https://github.com/vibead/cli
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/vibead --version").strip
    help = shell_output("#{bin}/vibead --help")
    assert_match "labelled [Ad]", help
    assert_match "vibead uninstall", help
    refute_match(/gemini|Vibead standalone beta/i, help)
    refute_path_exists bin/"vibead-beta"
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
