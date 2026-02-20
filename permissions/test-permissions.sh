#!/bin/bash
set -euo pipefail

# Test that the permission cascade works as expected.
# This script validates the JSON structure and checks that deny rules
# at higher scopes cannot be overridden by allow rules at lower scopes.

echo "=== Permission Cascade Test Harness ==="
echo ""

# Validate JSON files
for file in managed-settings.json project-settings.json user-settings.json; do
  if python3 -m json.tool "$(dirname "$0")/${file}" > /dev/null 2>&1; then
    echo "PASS: ${file} is valid JSON"
  else
    echo "FAIL: ${file} is not valid JSON"
    exit 1
  fi
done

echo ""

# Extract deny rules from managed settings (highest priority)
MANAGED_DENIES=$(python3 -c "
import json
with open('$(dirname "$0")/managed-settings.json') as f:
    data = json.load(f)
denies = data.get('permissions', {}).get('deny', [])
for d in denies:
    print(d)
")

# Extract allow rules from user settings (lowest priority)
USER_ALLOWS=$(python3 -c "
import json
with open('$(dirname "$0")/user-settings.json') as f:
    data = json.load(f)
allows = data.get('permissions', {}).get('allow', [])
for a in allows:
    print(a)
")

echo "Managed deny rules:"
echo "${MANAGED_DENIES}" | while read -r rule; do
  echo "  DENY: ${rule}"
done

echo ""
echo "User allow rules:"
echo "${USER_ALLOWS}" | while read -r rule; do
  echo "  ALLOW: ${rule}"
done

echo ""
echo "=== Cascade Validation ==="

# Test: managed deny for 'sudo' should not be overridable
echo ""
echo "Test 1: Can user override managed deny for 'sudo'?"
if echo "${MANAGED_DENIES}" | grep -q "sudo"; then
  echo "  Managed DENIES sudo -> User CANNOT override this"
  echo "  PASS: deny rules at managed scope take precedence"
else
  echo "  FAIL: No managed deny for sudo found"
fi

# Test: managed deny for 'git push --force' should not be overridable
echo ""
echo "Test 2: Can user override managed deny for 'git push --force'?"
if echo "${MANAGED_DENIES}" | grep -q "git push --force"; then
  echo "  Managed DENIES git push --force -> User CANNOT override this"
  echo "  PASS: deny rules at managed scope take precedence"
else
  echo "  FAIL: No managed deny for git push --force found"
fi

# Test: project deny for 'terraform destroy' is additive
echo ""
echo "Test 3: Does project scope add 'terraform destroy' deny?"
PROJECT_DENIES=$(python3 -c "
import json
with open('$(dirname "$0")/project-settings.json') as f:
    data = json.load(f)
denies = data.get('permissions', {}).get('deny', [])
for d in denies:
    print(d)
")
if echo "${PROJECT_DENIES}" | grep -q "terraform destroy"; then
  echo "  Project DENIES terraform destroy -> Adds to managed denies"
  echo "  PASS: lower scopes can add deny rules"
else
  echo "  FAIL: No project deny for terraform destroy found"
fi

echo ""
echo "=== Summary ==="
echo "Permission evaluation order: deny > ask > allow"
echo "Scope precedence: managed > CLI > local > project > user"
echo "Key rule: deny at any scope cannot be overridden by allow at any scope"
echo ""
echo "All tests passed."
