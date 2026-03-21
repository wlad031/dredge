#!/usr/bin/env bash
#
# install.sh — Installer for this project. Delegates to the-satellite for
# OS/arch detection, binary download (GitHub releases), and fallback
# source build. Run from the repo root: bash install.sh
#
# COPY-PASTE ACROSS PROJECTS: only edit the BRANDING section below.
#
# REQUIREMENTS in main.go (cmd/<binary>/main.go):
#   - A package-level const named exactly `githubRepo` with value "user/repo":
#       const githubRepo = "DeprecatedLuar/dredge"
#   - GITHUB_REPO in the BRANDING section below must mirror this value.
#   - REPO_USER, REPO_NAME, BINARY_NAME, PROJECT_NAME, and BUILD_CMD are
#     all derived from GITHUB_REPO at install time.
#
# REQUIREMENTS in the release workflow:
#   - GitHub releases must exist with assets named:
#       <binary>_<os>_<arch>  OR  <binary>-<os>-<arch>
#     (the-satellite tries both patterns automatically)
#
# NEXT_STEPS format: pipe-separated strings, each shown as a separate line.

# ===== BRANDING =====
GITHUB_REPO="DeprecatedLuar/dredge"  # mirrors const githubRepo in cmd/<binary>/main.go
MSG_FINAL="Happy dredging"
NEXT_STEPS="Run: dredge --help|Initialize git sync: dredge init <user/repo>|First add: dredge add"
ASCII_ART=''
# ===== END BRANDING =====

set -e

REPO_USER=$(echo "$GITHUB_REPO" | cut -d'/' -f1)
REPO_NAME=$(echo "$GITHUB_REPO" | cut -d'/' -f2)
BINARY_NAME="$REPO_NAME"
PROJECT_NAME="$BINARY_NAME"
INSTALL_DIR="$HOME/.local/bin"
BUILD_CMD="go build -ldflags='-s -w' -o ${BINARY_NAME} ./cmd/${BINARY_NAME}"

curl -sSL https://raw.githubusercontent.com/DeprecatedLuar/the-satellite/main/satellite.sh | \
    bash -s -- install \
        "$PROJECT_NAME" \
        "$BINARY_NAME" \
        "$REPO_USER" \
        "$REPO_NAME" \
        "$INSTALL_DIR" \
        "$BUILD_CMD" \
        "$ASCII_ART" \
        "$MSG_FINAL" \
        "$NEXT_STEPS"
