#!/bin/bash
set -euo pipefail

# Deploy managed settings and CLAUDE.md to the appropriate system paths.
# Adapt this script for your MDM tool (Jamf, Intune, Fleet, etc.).

SETTINGS_FILE="${1:-managed-settings-baseline.json}"
CLAUDE_MD_FILE="managed-CLAUDE.md"

# Detect platform
case "$(uname -s)" in
  Darwin)
    SETTINGS_DIR="/Library/Application Support/ClaudeCode"
    ;;
  Linux)
    SETTINGS_DIR="/etc/claude-code"
    ;;
  *)
    echo "Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

echo "Deploying to: ${SETTINGS_DIR}"
echo "Settings file: ${SETTINGS_FILE}"

# Validate JSON before deploying
if ! python3 -m json.tool "${SETTINGS_FILE}" > /dev/null 2>&1; then
  echo "ERROR: ${SETTINGS_FILE} is not valid JSON" >&2
  exit 1
fi

# Create directory (requires elevated privileges in production)
# sudo mkdir -p "${SETTINGS_DIR}"
echo "[DRY RUN] Would create: ${SETTINGS_DIR}"

# Copy managed settings
# sudo cp "${SETTINGS_FILE}" "${SETTINGS_DIR}/managed-settings.json"
echo "[DRY RUN] Would copy: ${SETTINGS_FILE} -> ${SETTINGS_DIR}/managed-settings.json"

# Copy managed CLAUDE.md
# sudo cp "${CLAUDE_MD_FILE}" "${SETTINGS_DIR}/CLAUDE.md"
echo "[DRY RUN] Would copy: ${CLAUDE_MD_FILE} -> ${SETTINGS_DIR}/CLAUDE.md"

# Set permissions (readable by all users, writable only by root)
# sudo chmod 644 "${SETTINGS_DIR}/managed-settings.json"
# sudo chmod 644 "${SETTINGS_DIR}/CLAUDE.md"
echo "[DRY RUN] Would set 644 permissions on deployed files"

echo ""
echo "Deployment complete (dry run)."
echo "Remove the DRY RUN lines and uncomment the real commands for production use."
echo "Verify with: claude /settings"
