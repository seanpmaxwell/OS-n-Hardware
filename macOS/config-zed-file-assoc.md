#!/usr/bin/env bash
# Make Zed the default app for text and source files on macOS.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "❌ This script only supports macOS."
  exit 1
fi

# --- Dependencies -----------------------------------------------------------

if ! command -v duti &>/dev/null; then
  if ! command -v brew &>/dev/null; then
    echo "❌ duti is required, and Homebrew is not installed: https://brew.sh/"
    exit 1
  fi
  read -r -p "📦 duti is required. Install it with Homebrew? [Y/n] " reply
  if [[ "${reply:-Y}" =~ ^[Nn] ]]; then
    echo "🚫 Cancelled."
    exit 0
  fi
  brew install duti
fi

# --- Pick a Zed channel -----------------------------------------------------

echo "Which version of Zed do you want to use?"
PS3="Choose [1-4]: "
ZED_APP_NAME=""
ZED_BUNDLE_ID=""

select choice in "Zed" "Zed Preview" "Zed Nightly" "Cancel"; do
  case "$choice" in
    "Zed")         ZED_BUNDLE_ID="dev.zed.Zed" ;;
    "Zed Preview") ZED_BUNDLE_ID="dev.zed.Zed-Preview" ;;
    "Zed Nightly") ZED_BUNDLE_ID="dev.zed.Zed-Nightly" ;;
    "Cancel")      break ;;
    *)             echo "Invalid option."; continue ;;
  esac
  ZED_APP_NAME="$choice"
  break
done

# Covers both "Cancel" and Ctrl-D (EOF), which leaves the variable empty.
if [[ -z "$ZED_APP_NAME" ]]; then
  echo
  echo "🚫 Cancelled."
  exit 0
fi

# Check the app is installed without triggering AppleScript's "Where is…?" dialog.
app_path="$(mdfind "kMDItemCFBundleIdentifier == '$ZED_BUNDLE_ID'" 2>/dev/null | head -1 || true)"
if [[ -z "$app_path" ]]; then
  for candidate in "/Applications/$ZED_APP_NAME.app" "$HOME/Applications/$ZED_APP_NAME.app"; do
    [[ -d "$candidate" ]] && app_path="$candidate" && break
  done
fi
if [[ -z "$app_path" ]]; then
  echo "❌ Could not find $ZED_APP_NAME ($ZED_BUNDLE_ID). Make sure it's installed."
  exit 1
fi

echo "✅ Using $ZED_APP_NAME ($ZED_BUNDLE_ID)"
echo "   $app_path"

# --- What to associate ------------------------------------------------------

# Well-known system UTIs. Setting a parent UTI doesn't override child types
# that already have their own handler, hence the extension list below too.
# Deliberately excludes public.unix-executable and public.script.
UTIS=(
  public.plain-text
  public.utf8-plain-text
  public.source-code
  public.json
  public.xml
  public.yaml
  public.css
  public.shell-script
  public.python-script
  public.ruby-script
  public.perl-script
  public.php-script
  public.c-source
  public.c-header
  public.c-plus-plus-source
  public.objective-c-source
  public.java-source
  public.swift-source
  com.netscape.javascript-source
  net.daringfireball.markdown
)

# Extensions without the leading dot (added when calling duti -s).
# Deliberately excluded:
#   ts     – also MPEG transport-stream video (moved to OPTIONAL_EXTENSIONS)
#   plist  – often binary; unreadable in a text editor
#   dotfiles (.gitignore etc.) and extensionless files (Makefile, Dockerfile)
#          – can't be matched by extension
EXTENSIONS=(
  txt md markdown mdx log rst adoc asciidoc
  json jsonc json5 yaml yml toml ini cfg conf env xml
  js jsx mjs cjs tsx mts cts
  css scss sass less
  vue svelte astro
  sh bash zsh fish
  py pyi rb erb php phtml pl pm
  go rs c h cpp hpp cc cxx hh m mm swift java kt kts scala cs fs fsx vb
  sql graphql gql
  gradle groovy lua r hs clj cljs cljc edn ex exs erl hrl dart
  zig nim jl tf tfvars tfstate hcl nix proto
  asm s mk cmake
  diff patch
  properties
  tex bib rake
)

# These take double-click away from other apps (browser, Numbers, Preview,
# video players). Ask before including them.
OPTIONAL_EXTENSIONS=(ts html htm xhtml svg csv tsv)

echo
echo "Optional: also take over these from their current apps?"
echo "  ${OPTIONAL_EXTENSIONS[*]/#/.}"
echo "  (.ts is also used for MPEG video; .html/.svg normally open in a browser;"
echo "   .csv/.tsv normally open in Numbers or Excel)"
read -r -p "Include them? [y/N] " reply
if [[ "${reply:-N}" =~ ^[Yy] ]]; then
  EXTENSIONS+=("${OPTIONAL_EXTENSIONS[@]}")
  UTIS+=(public.html)
fi

# --- Apply ------------------------------------------------------------------

failed=()
succeeded=()

apply() {
  local err
  # Role "all" is what Finder uses for double-click; "editor" alone may not win.
  if err="$(duti -s "$ZED_BUNDLE_ID" "$1" all 2>&1)"; then
    succeeded+=("$1")
  else
    failed+=("$1${err:+  ($err)}")
  fi
}

echo
echo "📝 Associating file types with $ZED_APP_NAME..."

for uti in "${UTIS[@]}"; do
  apply "$uti"
done

for ext in "${EXTENSIONS[@]}"; do
  apply ".$ext"
done

# --- Verify -----------------------------------------------------------------

echo
echo "🔍 Spot check:"

mismatches=0
for e in txt md json yaml toml js tsx css sh py rs go sql; do
  # duti -x prints: app name, app path, bundle id
  handler_id="$(duti -x "$e" 2>/dev/null | sed -n 3p || true)"
  handler_name="$(duti -x "$e" 2>/dev/null | head -1 || true)"
  if [[ "$handler_id" == "$ZED_BUNDLE_ID" ]]; then
    mark="✅"
  else
    mark="❌"
    mismatches=$((mismatches + 1))
  fi
  printf '  %s .%-6s -> %s\n' "$mark" "$e" "${handler_name:-<none>}"
done

echo
echo "✅ Associated: ${#succeeded[@]}"

if ((${#failed[@]})); then
  echo "⚠️  Failed (${#failed[@]}):"
  printf '  %s\n' "${failed[@]}"
fi

if ((mismatches)); then
  echo
  echo "⚠️  Some spot checks don't point to $ZED_APP_NAME yet."
  echo "   Try relaunching Finder:  killall Finder"
fi

echo
echo "🎉 Done. If double-click still opens the old app, relaunch Finder or log out and back in."
