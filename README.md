# VibeAd for Homebrew

**Your AI agent thinks. You get paid.**

```sh
brew install vibead/tap/vibead && vibead enable
```

**Use:** run `claude`, `codex` or `opencode` as usual. Codex is opt-in: accept the `codex` alias when `vibead enable` offers it, or run `vibead codex`.

**Turn off**

```sh
vibead disable
```

VibeAd never reads or changes your prompts, code or agent output. Payouts launching soon.

**Update**

```sh
brew update && brew upgrade vibead/tap/vibead
```

**Uninstall**

```sh
vibead uninstall && brew uninstall vibead && brew untap vibead/tap
```

**Requirements:** macOS (Apple Silicon or Intel) or Linux x64 with glibc 2.34+, and Claude Code, Codex or OpenCode already working. No Node.js needed.

[Latest release](https://github.com/vibead/cli/releases/latest) · [Guide](https://github.com/vibead/cli) · [Report a problem](https://github.com/vibead/cli/issues/new)

---

<details>
<summary><b>What <code>vibead enable</code> changes</b></summary>

It lists every file it will change and asks first (`--dry-run` previews only). Ads are labelled `[Ad]` and appear only in status or notification UI. `vibead disable` restores your files exactly.
</details>

<details>
<summary><b>Switching from npm</b></summary>

Run `vibead disable` and `npm uninstall -g @vibead/cli` first, so two installs don't provide the same command.
</details>

<details>
<summary><b>More details</b></summary>

- The formula downloads the official release archive from `vibead/cli`, verifies its SHA-256 and keeps the bundled runtime together.
- macOS builds are ad hoc signed, not Apple-notarized.
- Windows, Linux ARM64 and Alpine/musl are not supported.
</details>

<details>
<summary><b>Maintaining this tap</b></summary>

Update the version, platform URLs and SHA-256 values together for each release. Keep the complete kit in `libexec`. The install workflow checks Linux x64, Mac Apple Silicon and Mac Intel; it does not launch model sessions.
</details>
