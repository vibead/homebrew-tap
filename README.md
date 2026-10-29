<h1 align="center">VibeAd for Homebrew</h1>

<p align="center"><b>Your AI agent thinks. You get paid.</b></p>

<p align="center">
<a href="https://www.vibead.ai">Website</a> · <a href="https://github.com/vibead/cli">Guide</a> · <a href="https://github.com/vibead/cli/releases/latest">Latest release</a> · <a href="https://github.com/vibead/cli/issues/new">Report a problem</a>
</p>

<p align="center"><img src="https://raw.githubusercontent.com/vibead/cli/main/docs/readme-ad-claude.gif" alt="Real capture: Claude Code showing a labelled [Ad] line while it thinks" width="100%"><br><sub>Real capture: Claude Code</sub></p>

## Quick start

```sh
brew install vibead/tap/vibead && vibead          # install, then connect the agents on this computer
claude                                            # or codex, opencode: use your agent as usual
vibead disable                                    # turn ads off and restore your settings
```

**Codex** gets a `codex` shell function that runs `vibead codex`; `vibead disable` removes it. Open a new terminal after the first `vibead` run; Codex asks once whether to trust VibeAd's hooks, and ads show after you choose Trust.

VibeAd never reads or changes your prompts, code or agent output.

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
<summary><b>What the first <code>vibead</code> run (or <code>vibead enable</code>) changes</b></summary>

The first `vibead` run connects the agents it finds, without a question, and prints what it did. `vibead enable` (to turn ads back on after `vibead disable`) lists every file it will change and asks first (`--dry-run` previews only). Ads are labelled `[Ad]` and appear only in status or notification UI. `vibead disable` restores your files exactly.
</details>

<details>
<summary><b>Switching from npm</b></summary>

Run `vibead disable` and `npm uninstall -g @vibead/cli` first, so two installs don't provide the same command.
</details>

<details>
<summary><b>More details</b></summary>

- The formula downloads the official release archive from `vibead/cli`, verifies its SHA-256 and keeps the bundled runtime together.
- macOS builds are ad hoc signed, not Apple-notarized.
- Linux ARM64 and Alpine/musl are not supported.
</details>

<details>
<summary><b>Maintaining this tap</b></summary>

The `Update formula` workflow checks npm `latest` for `@vibead/cli` every 30 minutes and updates the version, platform URLs and SHA-256 values together (no token, no hand step; run it from the Actions tab to update at once). It stops unless npm's tarball and the release's `SHA256SUMS` agree. This formula only moves forward to newer releases; it never rolls back to an older one. When npm `latest` is not newer than the formula (SemVer order, prerelease included, so beta.10 is after beta.9), it changes nothing (`scripts/test-update-formula.sh` tests this). Keep the complete kit in `libexec`. The install workflow checks Linux x64, Mac Apple Silicon and Mac Intel; it does not launch model sessions.

**Release order (PENDING NINA).** The scheduled update keeps the caveats and `brew test` the formula already has, so a new version ships through a tap PR, in this order: (1) the GitHub Release and npm `next` exist; (2) the real published archives are hashed and re-gated; (3) on the tap PR branch, `VIBEAD_TAP_VERSION=<version> scripts/update-formula.sh`, commit, push, and the PR's install run is green; (4) merge the tap PR; (5) only then npm `latest` (vibead/cli's Release stops before `latest` unless tap main already ships the version). The formula's `caveats-for` line names the version its caveats were written for: `update-formula.sh` never moves past it, and the `Formula check` workflow stays red until the formula ships it.
</details>
