# Module 3: Configuration and Policy

Practice writing and deploying organization-wide Claude Code configuration.

## Setup

Review the files in `policies/` before starting. You'll work with managed settings and organizational CLAUDE.md files.

## Exercise 1: Write Managed Settings

Review `policies/managed-settings-baseline.json` and the strict variant.

1. Ask Claude to explain the difference:

   > "Compare managed-settings-baseline.json and managed-settings-strict.json. What additional controls does the strict variant add, and when would you use each?"

2. Create your own variant. Ask Claude:

   > "Write a managed-settings.json for a team that uses Bedrock in us-west-2, needs to allow git push but deny force push, and should use Opus as the default model. Start from the baseline."

3. Validate your settings are valid JSON: `python3 -m json.tool policies/your-settings.json`

## Exercise 2: Write a Managed CLAUDE.md

Review `policies/managed-CLAUDE.md` and customize it.

1. Ask Claude to add rules specific to your organization:

   > "Add 3 rules to the managed CLAUDE.md that enforce our team's practices: we use conventional commits, we require code review before merge, and we never deploy to production on Fridays."

2. Test the interaction between managed CLAUDE.md and project CLAUDE.md:

   > "If a project CLAUDE.md says 'commit directly to main is fine' but the managed CLAUDE.md says 'always use feature branches', which rule wins and why?"

## Exercise 3: Deploy and Verify

Review the deployment script `policies/deploy-settings.sh`.

1. Ask Claude to adapt it for your MDM tool:

   > "Modify deploy-settings.sh to work with [Jamf/Intune/Fleet]. What changes are needed for automated deployment to 100+ machines?"

2. Run the dry-run deployment locally and verify the paths are correct for your platform.
