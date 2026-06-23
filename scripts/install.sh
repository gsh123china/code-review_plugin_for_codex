#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [options]

Install the codex-review command and, optionally, the /prompts:code-review shim.

Options:
  --help              Show this help text.
  --prefix <dir>      Install codex-review into <dir>. Default: $HOME/.local/bin.
  --copy              Copy instead of symlink.
  --symlink           Symlink instead of copy. Default.
  --prompt-shim       Install the optional custom prompt shim as /prompts:code-review.
  --codex-home <dir>  Codex home for --prompt-shim. Default: $CODEX_HOME or $HOME/.codex.
  --no-command        Skip installing the codex-review shell command.
  --force             Replace an existing target.
  --dry-run           Print the planned action without changing files.

Manual installation:
  Add the repository scripts directory to PATH, or symlink scripts/codex-review
  into a directory that is already on PATH. For the optional prompt shim, copy
  prompts/custom-prompts/code-review.md to $CODEX_HOME/prompts/code-review.md
  or $HOME/.codex/prompts/code-review.md, then restart Codex.
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
PROMPT_SHIM_SOURCE="$PLUGIN_ROOT/prompts/custom-prompts/code-review.md"

[ -f "$SOURCE" ] || die "codex-review was not found at $SOURCE."

if [ -n "${HOME:-}" ]; then
  PREFIX="$HOME/.local/bin"
else
  PREFIX=""
fi
MODE="symlink"
FORCE="false"
DRY_RUN="false"
INSTALL_COMMAND="true"
INSTALL_PROMPT_SHIM="false"
CODEX_HOME_DIR="${CODEX_HOME:-}"

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
    --prompt-shim)
      INSTALL_PROMPT_SHIM="true"
      ;;
    --codex-home)
      shift
      [ "$#" -gt 0 ] || die "--codex-home requires a directory."
      CODEX_HOME_DIR=$1
      ;;
    --no-command)
      INSTALL_COMMAND="false"
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

[ "$INSTALL_COMMAND" = "true" ] || [ "$INSTALL_PROMPT_SHIM" = "true" ] || die "Nothing to install."

if [ "$INSTALL_COMMAND" = "true" ]; then
  [ -n "$PREFIX" ] || die "No install prefix was provided and HOME is not set."
  TARGET="$PREFIX/codex-review"

  printf 'Plugin root: %s\n' "$PLUGIN_ROOT"
  printf 'Source: %s\n' "$SOURCE"
  printf 'Target: %s\n' "$TARGET"
  printf 'Mode: %s\n' "$MODE"
fi

if [ "$INSTALL_PROMPT_SHIM" = "true" ]; then
  [ -f "$PROMPT_SHIM_SOURCE" ] || die "Prompt shim was not found at $PROMPT_SHIM_SOURCE."
  if [ -z "$CODEX_HOME_DIR" ]; then
    if [ -n "${HOME:-}" ]; then
      CODEX_HOME_DIR="$HOME/.codex"
    else
      die "No Codex home was provided and HOME is not set."
    fi
  fi
  PROMPT_TARGET="$CODEX_HOME_DIR/prompts/code-review.md"

  printf 'Prompt shim source: %s\n' "$PROMPT_SHIM_SOURCE"
  printf 'Prompt shim target: %s\n' "$PROMPT_TARGET"
fi

if [ "$DRY_RUN" = "true" ]; then
  printf 'Dry run only. No files changed.\n'
  exit 0
fi

if [ "$INSTALL_COMMAND" = "true" ]; then
  mkdir -p "$PREFIX" || die "Could not create install prefix: $PREFIX"

  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    if [ "$FORCE" != "true" ]; then
      if [ -L "$TARGET" ] && command_exists readlink; then
        current=$(readlink "$TARGET" || true)
        if [ "$current" = "$SOURCE" ]; then
          chmod +x "$SOURCE" || die "Could not make source executable: $SOURCE"
          printf 'codex-review is already installed at %s.\n' "$TARGET"
          INSTALL_COMMAND="false"
        fi
      fi
      if [ "$INSTALL_COMMAND" = "true" ]; then
        die "Target already exists: $TARGET. Re-run with --force to replace it."
      fi
    fi
    if [ "$INSTALL_COMMAND" = "true" ]; then
      rm -f "$TARGET" || die "Could not replace existing target: $TARGET"
    fi
  fi

  if [ "$INSTALL_COMMAND" = "true" ]; then
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
  fi

  case ":$PATH:" in
    *":$PREFIX:"*) ;;
    *)
      printf '\nNote: %s is not currently on PATH.\n' "$PREFIX"
      printf 'Add it to PATH or invoke the command by absolute path:\n'
      printf '  %s\n' "$TARGET"
      ;;
  esac
fi

if [ "$INSTALL_PROMPT_SHIM" = "true" ]; then
  PROMPT_DIR=$(dirname "$PROMPT_TARGET")
  mkdir -p "$PROMPT_DIR" || die "Could not create prompt directory: $PROMPT_DIR"

  if [ -e "$PROMPT_TARGET" ] || [ -L "$PROMPT_TARGET" ]; then
    if [ "$FORCE" != "true" ]; then
      die "Prompt shim target already exists: $PROMPT_TARGET. Re-run with --force to replace it."
    fi
    rm -f "$PROMPT_TARGET" || die "Could not replace existing prompt shim: $PROMPT_TARGET"
  fi

  cp "$PROMPT_SHIM_SOURCE" "$PROMPT_TARGET" || die "Could not copy prompt shim to $PROMPT_TARGET"
  printf 'Installed custom prompt shim: %s\n' "$PROMPT_TARGET"
  printf 'Restart Codex and invoke it as /prompts:code-review.\n'
fi
