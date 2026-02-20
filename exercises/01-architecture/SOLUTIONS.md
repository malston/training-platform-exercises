# Module 1: Architecture -- Solutions

## Exercise 1: Diagram the Request Flow

### The four-hop path

```text
Developer workstation → LLM Gateway (ALB) → VPC Endpoint → Bedrock Runtime
```

| Hop                    | Public Internet?         | Who Controls? | Failure Impact                   |
| ---------------------- | ------------------------ | ------------- | -------------------------------- |
| Workstation → Gateway  | No (VPC internal or VPN) | Platform team | Developers can't use Claude Code |
| Gateway → VPC Endpoint | No (private subnet)      | Platform team | All requests fail, no fallback   |
| VPC Endpoint → Bedrock | No (AWS private link)    | AWS           | Service unavailable, retry later |

**Why no public internet:** With `CLAUDE_CODE_USE_BEDROCK=1` and VPC endpoints configured with `private_dns_enabled = true`, the AWS SDK resolves `bedrock-runtime.us-east-1.amazonaws.com` to a private IP inside the VPC. Traffic never leaves the AWS network.

**Without VPC endpoints:** Traffic would route over the public internet to Bedrock's public endpoint. This is unacceptable for regulated environments where data must stay within the corporate network boundary.

## Exercise 2: Identify Enforcement Points

| Policy                                   | Gateway | Managed Settings | Both |
| ---------------------------------------- | ------- | ---------------- | ---- |
| Block Opus access for junior developers  | **X**   |                  |      |
| Prevent `sudo` commands                  |         | **X**            |      |
| Rate-limit tokens per user per day       | **X**   |                  |      |
| Route all traffic through VPC endpoints  |         | **X**            |      |
| Disable `--dangerously-skip-permissions` |         | **X**            |      |
| Log all requests for audit               | **X**   |                  |      |

### Reasoning

- **Block Opus by role:** The gateway inspects the request's model field and the user's identity (from IAM or a header). Managed settings can set the default model but can't enforce per-user model restrictions.
- **Prevent sudo:** This is a client-side behavior control. The `deny` rule in managed settings blocks Claude from running `sudo` commands before they reach the shell.
- **Rate limiting:** The gateway counts tokens per user per time window. Client-side settings can't enforce rate limits because the client could be modified.
- **VPC endpoint routing:** Setting `CLAUDE_CODE_USE_BEDROCK=1` in managed settings forces the AWS SDK to use Bedrock endpoints. Combined with VPC endpoints and DNS resolution, traffic stays private.
- **Disable bypass mode:** `disableBypassPermissionsMode: true` is a managed setting that prevents developers from using the `--dangerously-skip-permissions` flag.
- **Audit logging:** The gateway logs every request with user identity, model, token count, and timestamp. Client-side logging is unreliable because developers could disable it.

## Exercise 3: Configuration Hierarchy

### Hierarchy rule

```text
managed settings > CLI flags > local settings > project settings > user settings
```

Managed settings always win because they're deployed to a system-level path (`/Library/Application Support/ClaudeCode/` on macOS, `/etc/claude-code/` on Linux) that requires root access to modify. Claude Code reads these first and treats them as immutable overrides.

### Scenario 1: Bedrock routing

A developer sets `CLAUDE_CODE_USE_BEDROCK=0` in their user settings. Managed settings set `CLAUDE_CODE_USE_BEDROCK=1`.

**Result:** Bedrock stays enabled. Managed settings override user settings. The developer cannot opt out of the corporate routing path.

### Scenario 2: Permission rules

A project's `.claude/settings.json` adds `allow` rules for `Bash(npm *)`. Managed settings deny `Bash(curl *)`.

**Can the project override the managed deny?** No. Deny rules from any scope always win, regardless of hierarchy level. Even if user settings explicitly allow `curl`, the managed deny takes precedence.

**Can the project add its own allows?** Yes, unless `allowManagedPermissionRulesOnly: true` is set. If that flag is set, only rules from managed settings are evaluated -- project and user rules are ignored entirely.

### Rule evaluation order

1. Collect all rules from all scopes (managed, CLI, local, project, user)
2. Evaluate deny rules first -- if any scope denies the action, it's denied
3. Evaluate allow rules -- if any scope allows the action, it's allowed
4. Default: ask the user for permission

This "deny from any scope wins" design prevents lower-privilege scopes from overriding security controls set by higher-privilege scopes.
