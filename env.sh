# PicoLink environment setup. Source this file:  `source env.sh`

# Refuse to run if executed instead of sourced.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "env.sh must be sourced, not executed:  source env.sh" >&2
    exit 1
fi

export PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


case ":$PATH:" in
    *":$PROJ_ROOT/scripts:"*) ;;
    *) export PATH="$PROJ_ROOT/scripts:$PATH" ;;
esac

# Python venv for documentation tooling
_VENV="$PROJ_ROOT/.venv"
if [[ ! -d "$_VENV" ]]; then
    echo "[env.sh] Creating Python venv at $_VENV ..."
    python3 -m venv "$_VENV"
fi
source "$_VENV/bin/activate"

if ! python3 -c "import sphinx, sphinxcontrib.mermaid" 2>/dev/null; then
    echo "[env.sh] Installing Python documentation dependencies..."
    python3 -m pip install --quiet -r "$PROJ_ROOT/docs/requirements.txt"
fi

__show_git_branch() {
    git -C "$PROJ_ROOT" symbolic-ref --short HEAD 2>/dev/null
}

_C_GREEN='\[\e[01;32m\]'
_C_BLUE='\[\e[01;34m\]'
_C_YELLOW='\001\e[01;33m\002'
_C_RESET='\[\e[00m\]'
_C_RESET_SUB='\001\e[00m\002'

if [[ -n "${BASH_VERSION:-}" ]]; then
    # Only install the prompt once per shell.
    # if [[ "${PS1:-}" != *__show_git_branch* ]]; then
        export PS1="${_C_GREEN}"'\u@\h'"${_C_RESET}"':'"${_C_BLUE}"'\w'"${_C_RESET}"'$( b=$(__show_git_branch); [ -n "$b" ] && printf " '"${_C_YELLOW}"'(%s)'"${_C_RESET_SUB}"'" "$b") \$ '
    # fi
fi

echo "[env.sh] PROJ_ROOT=$PROJ_ROOT"
echo "[env.sh] $PROJ_ROOT/scripts added to PATH"
