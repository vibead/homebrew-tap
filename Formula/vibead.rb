class Vibead < Formula
  desc "Clearly labelled sponsored lines while your AI agent works"
  homepage "https://github.com/vibead/cli"
  version "0.1.0-beta.42"
  # caveats-for: 0.1.0-beta.42
  # The caveats and brew test below were written for that version. update-formula.sh
  # never moves the formula past it, and the "Formula check" workflow stays red until
  # the formula ships it: change the caveats in a reviewed tap PR, then this line.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.42/vibead-beta-0.1.0-beta.42-darwin-arm64.tar.gz"
      sha256 "01b36394f07d859dc2afa324c4d3eff9d2a875e07802e630a8e04c5c2598b8f7"
    end
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.42/vibead-beta-0.1.0-beta.42-darwin-x64.tar.gz"
      sha256 "b4a37f21afc7d3a305db44c294c65422b8a432464d704dc79d31f1389ee6e64b"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    on_intel do
      url "https://github.com/vibead/cli/releases/download/v0.1.0-beta.42/vibead-beta-0.1.0-beta.42-linux-x64.tar.gz"
      sha256 "6d2416ba2a9818995c466e853fbfd21a46387db334ebcf8b84469f3166e93545"
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
      Run `vibead` once after installing or upgrading. It connects Claude
      Code, Codex and OpenCode when they are installed, and prints what it
      did. Then start your agent as usual: `claude`, `codex` or `opencode`.
      Open a new terminal first for Codex: it gets a `codex` shell function
      that runs `vibead codex`.
      Codex will ask you to review VibeAd's hooks ("Hooks need review"). Choose "Trust all and continue" to see ads; "Continue without trusting" runs Codex normally without ads. It asks again each time you turn VibeAd off and back on.

      VibeAd shows a short sponsored line, labelled [Ad], in the agent's
      status line, working indicator or notification area while it works.
      It does not read or change your prompts, code or replies.
      Turn it off at any time with: vibead disable
      Remove it with: vibead uninstall && brew uninstall vibead
      Your normal AI provider charges still apply.
      Guide: https://github.com/vibead/cli
      Account: signed out. Ads still show, but you're not earning. Run `vibead login`.
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
