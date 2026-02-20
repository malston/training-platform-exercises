# Module 3: Configuration and Policy -- Solutions

## Exercise 1: Write Managed Settings

### Baseline vs strict comparison

| Control                     | Baseline | Strict                 |
| --------------------------- | -------- | ---------------------- |
| Bedrock routing             | Yes      | Yes                    |
| Block non-essential traffic | Yes      | Yes                    |
| Deny `rm -rf /`             | Yes      | Expanded to `rm -rf *` |
| Deny `sudo`                 | Yes      | Yes                    |
| Deny pipe-to-shell          | Yes      | Yes                    |
| Deny `chmod 777`            | No       | Yes                    |
| Deny `git push --force`     | No       | Yes                    |
| Deny `git reset --hard`     | No       | Yes                    |
| Block `/etc/` access        | No       | Yes                    |
| Disable bypass mode         | No       | Yes                    |
| Managed rules only          | No       | Yes                    |
| Managed hooks only          | No       | Yes                    |

**When to use baseline:** During Cohort 1 pilot, where you want developers to have flexibility while learning. Allows project-level customization of rules and hooks.

**When to use strict:** After GA rollout, for teams handling sensitive code (security, compliance, infrastructure). Locks down all rule modification to the platform team.

### Custom variant for us-west-2, git push allowed, Opus default

```json
{
  "$schema": "https://docs.anthropic.com/claude-code/managed-settings.schema.json",
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "AWS_REGION": "us-west-2",
    "ANTHROPIC_MODEL": "us.anthropic.claude-opus-4-6-20260219"
  },
  "permissions": {
    "allow": [],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)"
    ]
  },
  "disableBypassPermissionsMode": true
}
```

Note: `git push` is allowed (no deny rule for plain `git push`). Only `git push --force` is denied. The `allowManagedPermissionRulesOnly` flag is omitted to let projects add their own rules.

### Validate

```bash
python3 -m json.tool policies/custom-settings.json > /dev/null && echo "Valid JSON"
```

## Exercise 2: Write a Managed CLAUDE.md

### Enhanced managed CLAUDE.md

Add to `policies/managed-CLAUDE.md`:

```markdown
## Team Practices

- Use conventional commit messages: feat:, fix:, docs:, chore:, refactor:, test:
- Always create a feature branch and submit a pull request -- never commit directly to main
- Do not deploy to production on Fridays (deployment freeze Friday 3 PM through Monday 9 AM)
```

### Which rule wins?

If a project CLAUDE.md says "commit directly to main is fine" but the managed CLAUDE.md says "always use feature branches":

**The managed CLAUDE.md wins.** Managed CLAUDE.md is loaded from the system-level path and takes precedence in the settings cascade (managed > CLI > local > project > user). Claude Code treats managed CLAUDE.md instructions as higher priority than project-level instructions.

However, this is a behavioral guideline, not a permission rule. Claude follows the instruction but isn't mechanically prevented from committing to main. To enforce it mechanically, add a deny rule:

```json
"deny": ["Bash(git push origin main)", "Bash(git push origin master)"]
```

## Exercise 3: Deploy and Verify

### Adapting for Jamf

Replace the dry-run lines in `deploy-settings.sh` with Jamf commands:

```bash
#!/bin/bash
set -euo pipefail

SETTINGS_FILE="${1:-managed-settings-baseline.json}"
CLAUDE_MD_FILE="managed-CLAUDE.md"
SETTINGS_DIR="/Library/Application Support/ClaudeCode"

# Validate JSON
if ! python3 -m json.tool "${SETTINGS_FILE}" > /dev/null 2>&1; then
  echo "ERROR: ${SETTINGS_FILE} is not valid JSON" >&2
  exit 1
fi

# Create directory
mkdir -p "${SETTINGS_DIR}"

# Deploy files
cp "${SETTINGS_FILE}" "${SETTINGS_DIR}/managed-settings.json"
cp "${CLAUDE_MD_FILE}" "${SETTINGS_DIR}/CLAUDE.md"

# Set permissions
chmod 644 "${SETTINGS_DIR}/managed-settings.json"
chmod 644 "${SETTINGS_DIR}/CLAUDE.md"
chown root:wheel "${SETTINGS_DIR}/managed-settings.json"
chown root:wheel "${SETTINGS_DIR}/CLAUDE.md"

echo "Deployed to ${SETTINGS_DIR}"
```

For automated Jamf deployment, upload this as a script in Jamf Pro and create a policy that:

1. Scopes to the target Smart Group (Cohort 1 machines)
2. Runs at enrollment and on a recurring check-in schedule
3. Includes the settings JSON and CLAUDE.md as payload files

### For Intune (Windows/Linux)

Use a PowerShell script deployed via Intune's script deployment:

```powershell
$settingsDir = "$env:ProgramData\ClaudeCode"
New-Item -ItemType Directory -Force -Path $settingsDir
Copy-Item "managed-settings.json" "$settingsDir\managed-settings.json"
```

### For Fleet (osquery-based)

Use a Fleet policy that checks for the file's existence and content hash, with a remediation script that deploys it when missing.

### Verification

After deployment, verify on a target machine:

```bash
# Check file exists
ls -la "/Library/Application Support/ClaudeCode/managed-settings.json"

# Verify content
python3 -m json.tool "/Library/Application Support/ClaudeCode/managed-settings.json"

# Verify Claude Code reads it
claude /settings
```
