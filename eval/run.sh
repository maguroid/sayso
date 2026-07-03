#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVAL_DIR="$ROOT_DIR/eval"
SCENARIOS_DIR="$EVAL_DIR/scenarios"
RUNS_DIR="$EVAL_DIR/runs"
FRAMEWORK_FILE="$ROOT_DIR/framework/ORCHESTRATOR.md"

usage() {
  cat <<'USAGE'
使い方: ./eval/run.sh <S1..S6|all> [baseline|framework|both] [--dry-run]

例:
  ./eval/run.sh S1 baseline
  ./eval/run.sh S1 both --dry-run
  ./eval/run.sh all framework
USAGE
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

scenario_arg="${1:-}"
arm_arg="${2:-both}"
dry_run=0

if [[ "${3:-}" == "--dry-run" || "$arm_arg" == "--dry-run" ]]; then
  dry_run=1
  if [[ "$arm_arg" == "--dry-run" ]]; then
    arm_arg="both"
  fi
fi

if [[ -z "$scenario_arg" || "$scenario_arg" == "-h" || "$scenario_arg" == "--help" ]]; then
  usage
  exit 0
fi

case "$arm_arg" in
  baseline|framework|both) ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if [[ "$scenario_arg" == "all" ]]; then
  scenarios=(S1 S2 S3 S4 S5 S6)
else
  scenarios=("$scenario_arg")
fi

if [[ "$arm_arg" == "both" ]]; then
  arms=(baseline framework)
else
  arms=("$arm_arg")
fi

mkdir -p "$RUNS_DIR"

run_one() {
  local scenario="$1"
  local arm="$2"
  local scenario_dir="$SCENARIOS_DIR/$scenario"
  local fixture_dir="$scenario_dir/fixture"
  local prompt_file="$scenario_dir/prompt.txt"

  if [[ ! "$scenario" =~ ^S[1-6]$ || ! -d "$fixture_dir" || ! -f "$prompt_file" ]]; then
    echo "不正なシナリオです: $scenario" >&2
    return 2
  fi

  local timestamp
  timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
  local output_file="$RUNS_DIR/${timestamp}-${scenario}-${arm}.jsonl"
  local workdir
  workdir="$(mktemp -d)"

  cp -R "$fixture_dir/." "$workdir/"
  if [[ -d "$workdir/dot-git" ]]; then
    mv "$workdir/dot-git" "$workdir/.git"
  fi
  cp "$prompt_file" "$workdir/prompt.txt"

  if [[ "$arm" == "framework" ]]; then
    {
      printf '\n\n# ORCHESTRATOR.md 追記\n\n'
      cat "$FRAMEWORK_FILE"
    } >> "$workdir/CLAUDE.md"
  fi

  local started ended duration exit_code command_text claude_result_is_error
  command_text='claude -p "$(cat prompt.txt)" --model claude-sonnet-5 --output-format stream-json --verbose --dangerously-skip-permissions'
  started="$(date +%s)"

  if [[ "$dry_run" -eq 1 ]]; then
    printf '{"type":"dry_run","scenario":"%s","arm":"%s","workdir":%s,"command":%s}\n' \
      "$scenario" "$arm" \
      "$(printf '%s' "$workdir" | json_escape)" \
      "$(printf '%s' "$command_text" | json_escape)" > "$output_file"
    exit_code=0
  else
    (
      cd "$workdir" &&
      claude -p "$(cat prompt.txt)" --model claude-sonnet-5 --output-format stream-json --verbose --dangerously-skip-permissions
    ) > "$output_file"
    exit_code=$?
  fi

  ended="$(date +%s)"
  duration=$((ended - started))
  claude_result_is_error=false
  if grep -q '"is_error":true' "$output_file"; then
    claude_result_is_error=true
  fi

  printf '{"type":"runner_result","scenario":"%s","arm":"%s","exit_code":%d,"claude_result_is_error":%s,"duration_seconds":%d,"workdir":%s}\n' \
    "$scenario" "$arm" "$exit_code" "$claude_result_is_error" "$duration" "$(printf '%s' "$workdir" | json_escape)" >> "$output_file"

  echo "$output_file exit_code=$exit_code claude_result_is_error=$claude_result_is_error duration_seconds=$duration"
  if [[ "$claude_result_is_error" == "true" ]]; then
    return 1
  fi
  return "$exit_code"
}

overall=0
for scenario in "${scenarios[@]}"; do
  for arm in "${arms[@]}"; do
    if ! run_one "$scenario" "$arm"; then
      overall=1
    fi
  done
done

exit "$overall"
