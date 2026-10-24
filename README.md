<h1 align="center">VibeAd for Homebrew</h1>

<p align="center"><b>Your AI agent thinks. You get paid.</b></p>

<p align="center">
<a href="https://www.vibead.ai">Website</a> · <a href="https://github.com/vibead/cli">Guide</a> · <a href="https://github.com/vibead/cli/releases/latest">Latest release</a> · <a href="https://github.com/vibead/cli/issues/new">Report a problem</a>
</p>

<p align="center"><img src="https://raw.githubusercontent.com/vibead/cli/main/docs/readme-ad-claude.gif" alt="Real capture: Claude Code showing a labelled [Ad] line while it thinks" width="100%"><br><sub>Real capture: Claude Code</sub></p>

## Quick start

```sh
brew install vibead/tap/vibead && vibead enable   # install, then review and approve the changes
claude                                            # or opencode: use your agent as usual
vibead disable                                    # turn ads off and restore your settings
```

**Codex** is opt-in: accept the `codex` alias that `vibead enable` offers, or run `vibead codex`.

VibeAd never reads or changes your prompts, code or agent output. Payouts launching soon.

## Update and uninstall

```sh
brew update && brew upgrade vibead/tap/vibead                          # update
vibead uninstall && brew uninstall vibead && brew untap vibead/tap     # remove everything
```

## Requirements

- macOS (Apple Silicon or Intel), or Linux x64 with glibc 2.34+
- Claude Code, Codex or OpenCode already working in your terminal
- No Node.js needed: the formula includes its own runtime

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

The `Update formula` workflow checks npm `latest` for `@vibead/cli` every 30 minutes and updates the version, platform URLs and SHA-256 values together (no token, no hand step; run it from the Actions tab to update at once). It stops unless npm's tarball and the release's `SHA256SUMS` agree. Keep the complete kit in `libexec`. The install workflow checks Linux x64, Mac Apple Silicon and Mac Intel; it does not launch model sessions.
</details>
