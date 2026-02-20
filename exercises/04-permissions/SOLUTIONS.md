# Module 4: Permissions and Security -- Solutions

## Exercise 1: Write Deny Rules

### Analysis of existing rules

The `permissions/managed-settings.json` has these deny rules:

```json
"deny": [
  "Bash(sudo *)",
  "Bash(rm -rf /)",
  "Bash(curl * | bash)",
  "Bash(git push --force *)",
  "Edit(//etc/*)",
  "Read(//etc/shadow)"
]
```

### Gaps and bypass patterns

**Missing coverage:**

1. `rm -rf /` only blocks the root path. `rm -rf *` or `rm -rf ~/` would bypass it.
2. No protection against `wget * | bash` (only `curl` variant is blocked).
3. No protection against `git branch -D` (force-delete branches).
4. No protection against `docker run --privileged` (container escape risk).
5. No protection against reading `.env` files (credential exposure).
6. `Read(//etc/shadow)` is blocked but `Read(//etc/passwd)` is not (user enumeration).

**Shell metacharacter bypass:**

Claude Code's Bash rules are shell-aware: `Bash(sudo *)` will NOT match `echo foo && sudo rm -rf /` because the rule evaluator parses the command and checks each statement independently. So `sudo` in a chained command is still caught.

However, these patterns could bypass rules:

- `Bash(rm -rf /)` doesn't match `rm -rf ./` or `rm -rf ~/*`
- `Bash(curl * | bash)` doesn't match `curl url | sh` (different shell)

### Additional deny rules

```json
"deny": [
  "Bash(sudo *)",
  "Bash(rm -rf *)",
  "Bash(curl * | bash)",
  "Bash(curl * | sh)",
  "Bash(wget * | bash)",
  "Bash(wget * | sh)",
  "Bash(git push --force *)",
  "Bash(git reset --hard *)",
  "Bash(git branch -D *)",
  "Bash(docker * --privileged *)",
  "Read(//**/.env)",
  "Read(//**/.env.*)",
  "Edit(//**/.env)",
  "Edit(//**/.env.*)",
  "Edit(//etc/*)",
  "Read(//etc/shadow)",
  "Read(//etc/passwd)"
]
```

## Exercise 2: Test the Permission Cascade

### Can a user force push?

Managed settings deny `git push --force *`. User settings allow `git push *`.

**No, the user cannot force push.** The evaluation order is:

1. Collect rules from all scopes
2. **Deny rules are evaluated first** -- if any scope denies the action, it's denied
3. Allow rules are only checked if no deny matched

Since managed settings have a deny for `git push --force *`, and deny from any scope always wins, the user's allow rule is irrelevant. This is by design -- it prevents lower-privilege scopes from weakening security controls.

### Attempting to allow `sudo`

`user-settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(sudo *)"]
  }
}
```

**This won't work.** The managed settings deny `Bash(sudo *)`. Since deny rules from any scope take precedence over allow rules from any scope, the user's allow rule is ignored.

The only way to allow `sudo` would be to remove the deny rule from managed settings -- which requires root access to the system-level path.

### Permission cascade test harness

```bash
#!/bin/bash
set -euo pipefail

echo "Permission Cascade Test"
echo "======================"
echo ""

# Test 1: Managed deny should block regardless of other allows
echo "Test 1: Managed deny overrides user allow"
echo "  Managed: deny Bash(sudo *)"
echo "  User:    allow Bash(sudo *)"
echo "  Result:  DENIED (deny from any scope wins)"
echo ""

# Test 2: Project allow should work when managed doesn't deny
echo "Test 2: Project allow works when no managed deny exists"
echo "  Managed: (no rule for npm)"
echo "  Project: allow Bash(npm *)"
echo "  Result:  ALLOWED (project allow, no deny anywhere)"
echo ""

# Test 3: allowManagedPermissionRulesOnly blocks project rules
echo "Test 3: Managed-only mode blocks project rules"
echo "  Managed: allowManagedPermissionRulesOnly: true"
echo "  Project: allow Bash(npm *)"
echo "  Result:  ASK (project rule ignored, falls to default)"
echo ""

# Test 4: Multiple deny scopes
echo "Test 4: Deny in both managed and project"
echo "  Managed: deny Bash(rm -rf *)"
echo "  Project: deny Bash(rm -rf *)"
echo "  Result:  DENIED (redundant but both apply)"
echo ""

echo "All cascade tests documented."
echo "To verify in practice, deploy settings and run: claude /settings"
```

## Exercise 3: Sandboxing

### macOS Seatbelt

Claude Code uses macOS's Seatbelt sandbox (built into the OS, no installation needed). When enabled, a sandbox profile restricts:

- **File system access:** Limited to the project directory and system libraries
- **Network access:** Limited to configured endpoints
- **Process execution:** Limited to approved binaries

Seatbelt is applied automatically when Claude Code runs in its default mode. The sandbox profile is compiled into the binary.

### Verification test

```bash
#!/bin/bash
# Test that sandboxing restricts file access

echo "Test: Read file inside project directory"
claude -p "Read README.md and print the first line" 2>/dev/null
echo "Expected: Success"
echo ""

echo "Test: Read file outside project directory"
claude -p "Read /etc/passwd and print the first line" 2>/dev/null
echo "Expected: Denied by sandbox or permission rules"
```

### Seatbelt vs bubblewrap comparison

| Feature              | macOS Seatbelt                  | Linux bubblewrap                            |
| -------------------- | ------------------------------- | ------------------------------------------- |
| Installation         | Built into macOS                | Requires `apt install bubblewrap` + `socat` |
| Mechanism            | Kernel extension (sandbox_init) | User namespaces (unshare)                   |
| File restrictions    | Profile-based path filtering    | Mount namespace isolation                   |
| Network restrictions | Profile-based                   | Network namespace isolation                 |
| Granularity          | Per-operation rules             | Coarse namespace boundaries                 |
| Overhead             | Minimal (kernel-level)          | Minimal (namespace setup)                   |
| Bypass difficulty    | Requires SIP disable            | Requires root or namespace escape           |

**Stronger isolation:** bubblewrap provides stronger isolation through Linux namespaces (true filesystem isolation), but Seatbelt is more convenient (no installation, integrated with macOS security).

**Tradeoff:** bubblewrap requires `socat` for network proxying (Claude Code needs to reach Bedrock), adding operational complexity. Seatbelt works transparently.
