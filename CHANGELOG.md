# Changelog

All notable changes to this project will be documented in this file.

## [1.1] - 2026-07-09

### Added
- **Shared library** (`auto-scanner/lib/common.sh`) — centralized colors, domain parsing, tool checking, and safe temp directory creation
- `--help` and `--version` flags for `bugbounty-hunter.sh`
- `LICENSE` (MIT)
- `CONTRIBUTING.md` — contribution guidelines and code standards
- `CHANGELOG.md` — this file
- `.github/workflows/shellcheck.yml` — CI with ShellCheck static analysis
- Auto-detect URL in `pentest.sh` — `pentest https://target.com` now runs pro scan directly
- GitHub API rate limit detection in `github-scan.sh`

### Fixed
- **Broken URLs** in `show_platforms()` — Chinese characters replaced with real URLs
- **Banner box** not closing properly in `bugbounty-hunter.sh`
- **SQL Injection test** in `autopentest.sh` never injected the payload — now properly URL-encodes and appends
- **Missing `BLUE` color** in `file-upload-scanner.sh` caused invisible output
- **Indentation bugs** in `autopentest-pro.sh`, `autopentest.sh`, and `quickscan.sh`
- **Variable scope leaks** — `MISSING_HEADERS`, `COOKIES`, `CORS`, `TARGET_IP` now properly globalized
- **`encoding_bypass()`** removed from `full` pipeline (reference-only, not a scan)
- **`set -e` + `((TOTAL++))`** crash in `tool-checker.sh`
- **`$?` pattern** incompatible with `set -e` in `auto-scan-daemon.sh`

### Security
- All `/tmp` directories now use `mktemp` with unpredictable names (prevents symlink attacks)
- Added `trap cleanup EXIT` to all scripts that create temp dirs
- Report generation uses heredoc with variable expansion instead of fragile `sed` replacements
- Added `set -o pipefail` to all scripts

### Changed
- **Language standardized to English** — all user-facing output, comments, and function names
- Consistent `PHASE` naming (was mixed `FASE`/`PHASE`)
- `REPORT_DIR` uses `$SCRIPT_DIR`-based paths instead of fragile `../reports`
- `threat-intel-monitor.sh` uses `BASH_SOURCE` path resolution
- `pentest.sh` help banner uses proper English title
- Version bumped to 1.1

### Documentation
- Fixed `README.md` — wrong `cd pentesting-lab` directory, added T3MP3ST clone instructions, TOC, dynamic badges
- Updated `auto-scanner/README.md` with complete file listing
- Fixed `QUICK-REFERENCE.md` placeholder handle → `dev101x`
- `.gitignore` comments translated to English

## [1.0] - 2025

### Added
- Initial release
- `bugbounty-hunter.sh` — scope-enforced bug bounty workflow
- `auto-scanner/` — 400+ tool arsenal with multiple scan modes
- `programs/` — HackerOne scope tracker
- `legacy-vm-practice/` — local VM lab
- T3MP3ST integration
- Threat intelligence monitoring
- Burp Suite integration
