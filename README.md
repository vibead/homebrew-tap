# Vibead for Homebrew

Install [Vibead](https://github.com/vibead/cli) with Homebrew on **Mac (Apple Silicon or Intel)** or **Linux x64**. No Homebrew account, npm installation or separate Node.js installation is needed.

## Install and start

With [Homebrew](https://brew.sh) installed, run:

```sh
brew install vibead/tap/vibead
```

Then open a project where your AI coding agent already works and choose one command:

| Your agent | Run |
| --- | --- |
| Claude Code | `vibead claude` |
| Codex | `vibead codex` |
| Gemini CLI | `vibead gemini` |
| OpenCode | `vibead opencode` |

Send a prompt and look for a message marked `[Ad]` while the agent thinks. Very short turns may finish before an ad appears. Your normal agent login, settings, project and provider charges stay in use. Exit your agent normally when done.

This is **beta.12**: ads are simulated and generate no earnings or credits. To test a publisher message instead, run `vibead claude --test-publisher` and follow the [publisher guide](https://github.com/vibead/cli/blob/main/ENTERPRISE-DEMO.md).

## Check, update or remove

```sh
vibead --version
vibead --help
```

To update:

```sh
brew update
brew upgrade vibead/tap/vibead
```

To remove, first exit any running Vibead sessions:

```sh
brew uninstall vibead
brew untap vibead/tap
```

Session reports under `~/.vibead-beta/results` remain after uninstalling.

## Requirements and help

- Your chosen coding agent must already be installed and working.
- Linux requires **x64 and glibc 2.34+**. Windows, Linux ARM64 and Alpine/musl are not supported by this release.
- Mac archives are ad hoc signed, without Apple notarization. Physical Mac terminal acceptance remains pending; Homebrew installation tests do not certify the interactive display.
- OpenCode has a known issue where ads can be missing on later turns.
- Installation downloads the complete official release archive (about 72–84 MB), verifies its SHA-256 checksum, and keeps the bundled runtime together.
- If you already installed Vibead globally through npm, exit its sessions and run `npm uninstall -g @vibead/cli` before switching to Homebrew. This avoids two installations providing the same command.

[Read the beta guide](https://github.com/vibead/cli/blob/main/BETA.md) · [Report a problem](https://github.com/vibead/cli/issues/new) · [Release notes and downloads](https://github.com/vibead/cli/releases/tag/v0.1.0-beta.12)

## Maintaining this tap

The formula installs the published archives from `vibead/cli`; it does not rebuild or relicense them. Update the version, platform URLs and SHA-256 values together for a new release. Keep the complete kit in `libexec` so its native modules and runtime remain available.

The install workflow checks Linux x64, Mac Apple Silicon and Mac Intel. It tests the command entry points and required runtime files. It does not launch paid model sessions.
