#!/usr/bin/env bash
# audit-dod.sh — generate a machine-readable DoD compliance report
# Safe to run even if nothing is staged/untracked; checks are existence-based.
# Writes: .kinda/compliance_report.json
# NOTE: Non-blocking for now (always exits 0). We’ll wire it as a gate next step.

set -u -o pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

mkdir -p .kinda
REPORT=".kinda/compliance_report.json"

# -------- helpers --------
have_cmd() { command -v "$1" >/dev/null 2>&1; }

json_escape() {
  # escape double quotes/newlines for JSON string values
  sed 's/\\/\\\\/g; s/"/\\"/g; s/\r//g'
}

branch_name="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git-branch")"

# -------- tests-added (existence-based) --------
tests_added=false
if [ -d tests ] || [ -d test ]; then
  if find tests test 2>/dev/null -type f \
      \( -name "test_*.py" -o -name "*_test.py" -o -name "*.t" \) \
      -print -quit | grep -q .; then
    tests_added=true
  fi
fi

# -------- ci-green (pytest) --------
ci_green=false
ci_notes="pytest not installed"
if have_cmd pytest; then
  ci_notes="pytest run"
  set +e
  PYTEST_OUT="$(pytest -q 2>&1)"
  PYTEST_RC=$?
  set -e
  if [ "$PYTEST_RC" -eq 0 ]; then
    ci_green=true
    ci_notes="pytest passed"
  else
    ci_notes="pytest failed"
  fi
fi

# -------- style-pass (black --check) --------
style_pass=false
style_notes="black not installed"
if have_cmd black; then
  set +e
  black --check . >/dev/null 2>&1
  BLACK_RC=$?
  set -e
  if [ "$BLACK_RC" -eq 0 ]; then
    style_pass=true
    style_notes="black --check passed"
  else
    style_notes="black --check failed"
  fi
fi

# -------- docs-updated (existence-based: docs/ or README.* present with at least one file) --------
docs_updated=false
if [ -f README.md ] || [ -f README.rst ] || [ -d docs ]; then
  if [ -f README.md ] || [ -f README.rst ] || find docs 2>/dev/null -type f -print -quit | grep -q .; then
    docs_updated=true
  fi
fi

# -------- examples-updated (existence-based: any file under examples/) --------
examples_updated=false
if [ -d examples ]; then
  if find examples 2>/dev/null -type f -print -quit | grep -q .; then
    examples_updated=true
  fi
fi

# -------- overall & missing --------
OVERALL=true
MISSING=()
$tests_added        || { OVERALL=false; MISSING+=("\"tests-added\""); }
$ci_green           || { OVERALL=false; MISSING+=("\"ci-green\""); }
$style_pass         || { OVERALL=false; MISSING+=("\"style-pass\""); }
$docs_updated       || { OVERALL=false; MISSING+=("\"docs-updated\""); }
$examples_updated   || { OVERALL=false; MISSING+=("\"examples-updated\""); }

# -------- write JSON report --------
cat > "$REPORT" <<JSON
{
  "task_id": "$branch_name",
  "dod_checklist": [
    {"id":"tests-added","required":true,"met":$tests_added,"notes":"at least one test file exists"},
    {"id":"ci-green","required":true,"met":$ci_green,"notes":"$(echo "$ci_notes" | json_escape)"},
    {"id":"style-pass","required":true,"met":$style_pass,"notes":"$(echo "$style_notes" | json_escape)"},
    {"id":"docs-updated","required":true,"met":$docs_updated,"notes":"docs/ or README present"},
    {"id":"examples-updated","required":true,"met":$examples_updated,"notes":"examples/ contains files"}
  ],
  "overall_pass": $OVERALL,
  "missing": [$(IFS=,; echo "${MISSING[*]}")]
}
JSON

echo "Wrote $REPORT"
# Non-blocking for now; we’ll make it a hard gate in the next step.
exit 0

