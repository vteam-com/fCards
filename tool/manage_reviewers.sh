#!/bin/bash

# =============================================================================
# VTeam Cards - Reviewer Access Management
# =============================================================================
# Adds reviewer users to Realtime Database and deploys database rules.
#
# Usage examples:
#   ./tool/manage_reviewers.sh UID_1 UID_2
#   ./tool/manage_reviewers.sh --uid UID_1 --uid UID_2
#   ./tool/manage_reviewers.sh --uids-file ./reviewers.txt
#   ./tool/manage_reviewers.sh --uid UID_1 --project vteam-cards
#   ./tool/manage_reviewers.sh --list-auth-users
#   ./tool/manage_reviewers.sh --list-auth-users --email-only
#   ./tool/manage_reviewers.sh --find-email reviewer@example.com
#   ./tool/manage_reviewers.sh --rules-only
#   ./tool/manage_reviewers.sh --uid UID_1 --skip-rules
#
# Notes:
# - Requires Firebase CLI and an authenticated session.
# - Reviewer flags are written under: reviewers/{uid} = true
# - Rules deployment uses: firebase deploy --only database
# =============================================================================

set -euo pipefail

PROJECT_ID="vteam-cards"
RULES_ONLY=false
SKIP_RULES=false
LIST_AUTH_USERS=false
EMAIL_ONLY=false
FIND_EMAIL=""
UIDS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
  cat <<'EOF'
Reviewer Access Management Script

Usage:
  ./tool/manage_reviewers.sh [options] [UID ...]

Options:
  --uid <uid>          Add one reviewer UID (repeatable)
  --uids-file <path>   Load reviewer UIDs from file (one UID per line, '#' comments allowed)
  --project <id>       Firebase project ID (default: vteam-cards)
  --list-auth-users    List Firebase Auth users with UID, email, and display name
  --email-only         With --list-auth-users, only show users that have an email
  --find-email <mail>  Print matching Firebase Auth user records for an email
  --rules-only         Deploy database rules only (do not add reviewers)
  --skip-rules         Add reviewers only (do not deploy rules)
  -h, --help           Show this help text

Examples:
  ./tool/manage_reviewers.sh UID_1 UID_2
  ./tool/manage_reviewers.sh --uid UID_1 --uid UID_2
  ./tool/manage_reviewers.sh --uids-file ./reviewers.txt
  ./tool/manage_reviewers.sh --uid UID_1 --project vteam-cards
  ./tool/manage_reviewers.sh --list-auth-users
  ./tool/manage_reviewers.sh --list-auth-users --email-only
  ./tool/manage_reviewers.sh --find-email reviewer@example.com
  ./tool/manage_reviewers.sh --rules-only
EOF
}

if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

fail() {
  echo -e "${RED}❌ $1${NC}" >&2
  exit 1
}

check_prerequisites() {
  if ! command -v firebase >/dev/null 2>&1; then
    fail "Firebase CLI not found. Install with: npm install -g firebase-tools"
  fi

  if ! firebase projects:list >/dev/null 2>&1; then
    fail "Not logged into Firebase CLI. Run: firebase login"
  fi

  if [[ ! -f "database.rules.json" ]]; then
    fail "database.rules.json not found. Run this script from repository root."
  fi
}

check_python_prerequisite() {
  if ! command -v python3 >/dev/null 2>&1; then
    fail "python3 is required for Firebase Auth UID lookup modes."
  fi
}

read_uids_file() {
  local file_path="$1"
  [[ -f "$file_path" ]] || fail "UID file not found: $file_path"

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # Skip empty lines and comments
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue

    UIDS+=("$line")
  done <"$file_path"
}

is_valid_uid() {
  local uid="$1"

  # Firebase Auth UIDs must not contain '/' and should be non-empty.
  if [[ -z "$uid" ]]; then
    return 1
  fi

  if [[ "$uid" == *"/"* ]]; then
    return 1
  fi

  if [[ "$uid" =~ [[:space:]] ]]; then
    return 1
  fi

  return 0
}

deploy_rules() {
  echo -e "${YELLOW}🔥 Deploying Realtime Database rules to project '${PROJECT_ID}'...${NC}"
  firebase deploy --only database --project "$PROJECT_ID"
  echo -e "${GREEN}✅ Rules deployed successfully.${NC}"
}

export_auth_users_json() {
  local output_file="$1"
  firebase auth:export "$output_file" --format=json --project "$PROJECT_ID" >/dev/null
}

export_reviewers_json() {
  local output_file="$1"
  firebase database:get "/reviewers" --project "$PROJECT_ID" >"$output_file"
}

list_auth_users() {
  check_python_prerequisite

  local temp_file
  local reviewers_file
  temp_file="$(mktemp -t cards-auth-users.XXXXXX.json)"
  reviewers_file="$(mktemp -t cards-reviewers.XXXXXX.json)"
  trap 'rm -f "$temp_file" "$reviewers_file"' RETURN

  echo -e "${YELLOW}🔎 Exporting Firebase Auth users from project '${PROJECT_ID}'...${NC}"
  export_auth_users_json "$temp_file"
  export_reviewers_json "$reviewers_file"

  python3 - "$temp_file" "$reviewers_file" "$EMAIL_ONLY" <<'PY'
import json
import sys

auth_path = sys.argv[1]
reviewers_path = sys.argv[2]
email_only = sys.argv[3].strip().lower() == 'true'
with open(auth_path, 'r', encoding='utf-8') as handle:
    payload = json.load(handle)

with open(reviewers_path, 'r', encoding='utf-8') as handle:
    reviewer_payload = json.load(handle)

reviewers = reviewer_payload if isinstance(reviewer_payload, dict) else {}

users = payload.get('users', [])
if not users:
    print('No Firebase Auth users found.')
    sys.exit(0)

visible_users = []
for user in users:
    email = (user.get('email') or '').strip()
    if email_only and not email:
        continue
    visible_users.append(user)

if not visible_users:
    print('No Firebase Auth users found for the selected filter.')
    sys.exit(0)

display_name_width = 28

def clamp_display_name(value):
    if len(value) <= display_name_width:
        return value
    return value[:display_name_width - 3] + '...'

rows = []
for user in visible_users:
    uid = user.get('localId', '')
    email = user.get('email', '')
    display_name = clamp_display_name(user.get('displayName', ''))
    disabled = str(user.get('disabled', False)).lower()
    reviewer_value = reviewers.get(uid)
    reviewer = 'true' if reviewer_value is True else 'false'
    rows.append((uid, email, display_name, disabled, reviewer))

headers = ('UID', 'EMAIL', 'DISPLAY_NAME', 'DISABLED', 'REVIEWER')
widths = [len(header) for header in headers]
for row in rows:
    for index, value in enumerate(row):
        widths[index] = max(widths[index], len(value))

widths[2] = max(widths[2], display_name_width)

def format_row(row):
    return '  '.join(value.ljust(widths[index]) for index, value in enumerate(row))

print(format_row(headers))
print(format_row(tuple('-' * width for width in widths)))
for row in rows:
    print(format_row(row))
PY
}

find_user_by_email() {
  local email="$1"
  check_python_prerequisite

  local temp_file
  local reviewers_file
  temp_file="$(mktemp -t cards-auth-users.XXXXXX.json)"
  reviewers_file="$(mktemp -t cards-reviewers.XXXXXX.json)"
  trap 'rm -f "$temp_file" "$reviewers_file"' RETURN

  echo -e "${YELLOW}🔎 Looking up Firebase Auth user for '${email}' in project '${PROJECT_ID}'...${NC}"
  export_auth_users_json "$temp_file"
  export_reviewers_json "$reviewers_file"

  python3 - "$temp_file" "$reviewers_file" "$email" <<'PY'
import json
import sys

auth_path = sys.argv[1]
reviewers_path = sys.argv[2]
target = sys.argv[3].strip().lower()

with open(auth_path, 'r', encoding='utf-8') as handle:
    payload = json.load(handle)

with open(reviewers_path, 'r', encoding='utf-8') as handle:
    reviewer_payload = json.load(handle)

reviewers = reviewer_payload if isinstance(reviewer_payload, dict) else {}

matches = []
for user in payload.get('users', []):
    email = (user.get('email') or '').strip().lower()
    if email == target:
        matches.append(user)

if not matches:
    print(f'No Firebase Auth user found for email: {target}')
    sys.exit(1)

display_name_width = 28

def clamp_display_name(value):
    if len(value) <= display_name_width:
        return value
    return value[:display_name_width - 3] + '...'

rows = []
for user in matches:
    uid = user.get('localId', '')
    email = user.get('email', '')
    display_name = clamp_display_name(user.get('displayName', ''))
    disabled = str(user.get('disabled', False)).lower()
    reviewer_value = reviewers.get(uid)
    reviewer = 'true' if reviewer_value is True else 'false'
    rows.append((uid, email, display_name, disabled, reviewer))

headers = ('UID', 'EMAIL', 'DISPLAY_NAME', 'DISABLED', 'REVIEWER')
widths = [len(header) for header in headers]
for row in rows:
    for index, value in enumerate(row):
        widths[index] = max(widths[index], len(value))

widths[2] = max(widths[2], display_name_width)

def format_row(row):
    return '  '.join(value.ljust(widths[index]) for index, value in enumerate(row))

print(format_row(headers))
print(format_row(tuple('-' * width for width in widths)))
for row in rows:
    print(format_row(row))
PY
}

add_reviewers() {
  local unique_uids=()
  local seen=" "

  for uid in "${UIDS[@]}"; do
    if ! is_valid_uid "$uid"; then
      fail "Invalid UID '$uid'. UIDs cannot be empty, contain spaces, or include '/'."
    fi

    if [[ "$seen" != *" $uid "* ]]; then
      unique_uids+=("$uid")
      seen+="$uid "
    fi
  done

  if [[ ${#unique_uids[@]} -eq 0 ]]; then
    fail "No reviewer UIDs provided. Add UIDs or use --rules-only."
  fi

  echo -e "${YELLOW}👥 Adding ${#unique_uids[@]} reviewer(s) in project '${PROJECT_ID}'...${NC}"

  for uid in "${unique_uids[@]}"; do
    echo -e "${BLUE}→ Setting reviewers/${uid} = true${NC}"
    firebase database:set "/reviewers/${uid}" --data true --project "$PROJECT_ID" --force
  done

  echo -e "${GREEN}✅ Reviewer assignment completed.${NC}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uid)
      [[ $# -ge 2 ]] || fail "--uid requires a value"
      UIDS+=("$2")
      shift 2
      ;;
    --uids-file)
      [[ $# -ge 2 ]] || fail "--uids-file requires a path"
      read_uids_file "$2"
      shift 2
      ;;
    --project)
      [[ $# -ge 2 ]] || fail "--project requires a value"
      PROJECT_ID="$2"
      shift 2
      ;;
    --list-auth-users)
      LIST_AUTH_USERS=true
      shift
      ;;
    --email-only)
      EMAIL_ONLY=true
      shift
      ;;
    --find-email)
      [[ $# -ge 2 ]] || fail "--find-email requires a value"
      FIND_EMAIL="$2"
      shift 2
      ;;
    --rules-only)
      RULES_ONLY=true
      shift
      ;;
    --skip-rules)
      SKIP_RULES=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        UIDS+=("$1")
        shift
      done
      ;;
    -* )
      fail "Unknown option: $1"
      ;;
    *)
      UIDS+=("$1")
      shift
      ;;
  esac
done

if [[ "$RULES_ONLY" == true && "$SKIP_RULES" == true ]]; then
  fail "--rules-only and --skip-rules cannot be used together"
fi

if [[ "$LIST_AUTH_USERS" == true && -n "$FIND_EMAIL" ]]; then
  fail "--list-auth-users and --find-email cannot be used together"
fi

if [[ "$EMAIL_ONLY" == true && "$LIST_AUTH_USERS" == false ]]; then
  fail "--email-only can only be used together with --list-auth-users"
fi

check_prerequisites

echo -e "${BLUE}🚀 Reviewer access workflow started${NC}"

echo -e "${BLUE}Project:${NC} ${PROJECT_ID}"

if [[ "$LIST_AUTH_USERS" == true ]]; then
  list_auth_users
  exit 0
fi

if [[ -n "$FIND_EMAIL" ]]; then
  find_user_by_email "$FIND_EMAIL"
  exit 0
fi

if [[ "$RULES_ONLY" == true ]]; then
  deploy_rules
  echo -e "${GREEN}🎉 Done.${NC}"
  exit 0
fi

add_reviewers

if [[ "$SKIP_RULES" == false ]]; then
  deploy_rules
else
  echo -e "${YELLOW}⚠️  Rules deployment skipped (--skip-rules).${NC}"
fi

echo -e "${GREEN}🎉 All requested operations completed successfully.${NC}"
