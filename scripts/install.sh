#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [options]

Install the codex-review command by linking or copying scripts/codex-review.

Options:
  --help            Show this help text.
  --prefix <dir>    Install into <dir>. Default: $HOME/.local/bin.
  --copy            Copy instead of symlink.
  --symlink         Symlink instead of copy. Default.
  --force           Replace an existing target.
  --dry-run         Print the planned action without changing files.

Manual installation:
  Add the repository scripts directory to PATH, or symlink scripts/codex-review
  into a directory that is already on PATH.
EOF
}

die() {
  printf '%s\n' "install.sh: $*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

resolve_script_dir() {
  target=$0
  case "$target" in
    */*) ;;
    *)
      found=$(command -v "$target" 2>/dev/null || true)
      if [ -n "$found" ]; then
        target=$found
      fi
      ;;
  esac

  while [ -L "$target" ] && command_exists readlink; do
    link=$(readlink "$target") || break
    case "$link" in
      /*) target=$link ;;
      *) target=$(dirname "$target")/$link ;;
    esac
  done

  dir=$(dirname "$target")
  (CDPATH='' cd "$dir" 2>/dev/null && pwd -P) || printf '.\n'
}

SCRIPT_DIR=$(resolve_script_dir)
PLUGIN_ROOT=$(CDPATH='' cd "$SCRIPT_DIR/.." 2>/dev/null && pwd -P)
SOURCE="$PLUGIN_ROOT/scripts/codex-review"

[ -f "$SOURCE" ] || die "codex-review was not found at $SOURCE."

if [ -n "${HOME:-}" ]; then
  PREFIX="$HOME/.local/bin"
else
  PREFIX=""
fi
MODE="symlink"
FORCE="false"
DRY_RUN="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --prefix)
      shift
      [ "$#" -gt 0 ] || die "--prefix requires a directory."
      PREFIX=$1
      ;;
    --copy)
      MODE="copy"
      ;;
    --symlink)
      MODE="symlink"
      ;;
    --force)
      FORCE="true"
      ;;
    --dry-run)
      DRY_RUN="true"
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

[ -n "$PREFIX" ] || die "No install prefix was provided and HOME is not set."

TARGET="$PREFIX/codex-review"

printf 'Plugin root: %s\n' "$PLUGIN_ROOT"
printf 'Source: %s\n' "$SOURCE"
printf 'Target: %s\n' "$TARGET"
printf 'Mode: %s\n' "$MODE"

if [ "$DRY_RUN" = "true" ]; then
  printf 'Dry run only. No files changed.\n'
  exit 0
fi

mkdir -p "$PREFIX" || die "Could not create install prefix: $PREFIX"

if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  if [ "$FORCE" != "true" ]; then
    if [ -L "$TARGET" ] && command_exists readlink; then
      current=$(readlink "$TARGET" || true)
      if [ "$current" = "$SOURCE" ]; then
        chmod +x "$SOURCE" || die "Could not make source executable: $SOURCE"
        printf 'codex-review is already installed at %s.\n' "$TARGET"
        exit 0
      fi
    fi
    die "Target already exists: $TARGET. Re-run with --force to replace it."
  fi
  rm -f "$TARGET" || die "Could not replace existing target: $TARGET"
fi

chmod +x "$SOURCE" || die "Could not make source executable: $SOURCE"

if [ "$MODE" = "symlink" ]; then
  if ln -s "$SOURCE" "$TARGET" 2>/dev/null; then
    printf 'Installed symlink: %s -> %s\n' "$TARGET" "$SOURCE"
  else
    printf 'Symlink failed; falling back to copy.\n' >&2
    cp "$SOURCE" "$TARGET" || die "Could not copy codex-review to $TARGET"
    chmod +x "$TARGET" || die "Could not make target executable: $TARGET"
    printf 'Installed copy: %s\n' "$TARGET"
  fi
else
  cp "$SOURCE" "$TARGET" || die "Could not copy codex-review to $TARGET"
  chmod +x "$TARGET" || die "Could not make target executable: $TARGET"
  printf 'Installed copy: %s\n' "$TARGET"
fi

case ":$PATH:" in
  *":$PREFIX:"*) ;;
  *)
    printf '\nNote: %s is not currently on PATH.\n' "$PREFIX"
    printf 'Add it to PATH or invoke the command by absolute path:\n'
    printf '  %s\n' "$TARGET"
    ;;
esac
