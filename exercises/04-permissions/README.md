# Module 4: Permissions and Security

Practice writing permission rules, testing the cascade, and configuring sandboxing.

## Setup

Review the files in `permissions/` before starting. These represent settings at three different scopes: managed (organization), project, and user.

## Exercise 1: Write Deny Rules

Review `permissions/managed-settings.json` which defines organization-level deny rules.

1. Ask Claude to analyze the rules:

   > "Review the deny rules in permissions/managed-settings.json. Are there any dangerous bash commands that are missing? What about shell metacharacter bypass -- could someone evade these rules with pipes or semicolons?"

2. Ask Claude to add rules:

   > "Add deny rules that prevent: deleting git branches with -D flag, running docker with --privileged, and accessing any .env files. Make sure the patterns can't be bypassed with shell metacharacters."

## Exercise 2: Test the Permission Cascade

Run the test harness to understand how scopes interact:

```bash
cd permissions && bash test-permissions.sh
```

1. Ask Claude about the cascade:

   > "If managed settings deny 'git push --force' but user settings allow 'git push \*', can a user force push? Explain the evaluation order."

2. Try to create a scenario where a lower scope overrides a higher scope deny:

   > "Write a user-settings.json that attempts to allow 'sudo'. Then explain why it won't work based on the permission cascade rules."

## Exercise 3: Sandboxing

Ask Claude to help configure sandboxing:

> "Explain how Seatbelt sandboxing works on macOS for Claude Code. Write a test that verifies Claude Code can read files inside the project directory but cannot read /etc/passwd when sandboxing is enabled."

Compare sandboxing approaches:

> "What's the difference between macOS Seatbelt and Linux bubblewrap for Claude Code sandboxing? Which provides stronger isolation, and what are the tradeoffs?"
