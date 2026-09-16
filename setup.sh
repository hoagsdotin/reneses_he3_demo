#!/usr/bin/env bash
#
# setup.sh — creates the expected workspace layout, writes a
# build-secrets.env template, and runs the health check.
# Changes nothing outside your workspace (per README).
#
# DEMO STUB: creates real directories/files but doesn't install
# toolchains — that's still the manual "Install the toolchains" step
# in the README.

set -euo pipefail

WORKSPACE="${HOAGS_WORKSPACE:-$HOME}"

echo "Setting up workspace at: $WORKSPACE"

mkdir -p "$WORKSPACE/renesas-devicefiles/RL78/Common"

SECRETS_FILE="$WORKSPACE/build-secrets.env"
if [ ! -f "$SECRETS_FILE" ]; then
    cat > "$SECRETS_FILE" <<'EOF'
HOAGS_GIT_TOKEN=ghp_your_own_token
HOAGS_GIT_USER=your-github-username
EOF
    chmod 600 "$SECRETS_FILE"
    echo "Created template: $SECRETS_FILE (chmod 600)"
else
    echo "Found existing: $SECRETS_FILE (left untouched)"
fi

echo
echo "Next steps:"
echo "  1. Install toolchains (see README section 2)"
echo "  2. Clone firmware repos into \$WORKSPACE (see README section 3)"
echo "  3. Fill in $SECRETS_FILE with your own GitHub token"
echo "  4. Run: cd new_build_system && ./hoags-build doctor"
