#!/usr/bin/env bash
# setup.sh — local chat + autocomplete for VS Code on an Apple Silicon Mac.
#   ./setup.sh             check everything, pull the chat model for your RAM, install the extensions
#   ./setup.sh --no-brew   skip installing llama.cpp with Homebrew (llama.vscode can do it from its menu)
set -euo pipefail

OLLAMA_URL="${OLLAMA_HOST:-http://127.0.0.1:11434}"
NO_BREW=0; [[ "${1:-}" == "--no-brew" ]] && NO_BREW=1
ok()   { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn() { printf "  \033[33m!\033[0m %s\n" "$1"; }
die()  { printf "  \033[31m✗\033[0m %s\n" "$1"; exit 1; }

echo "1/5  Your Mac"
[[ "$(uname -s)" == "Darwin" ]] || die "This setup is for macOS."
[[ "$(uname -m)" == "arm64" ]] || die "This setup needs an Apple Silicon Mac (M1 or newer)."
RAM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
ok "Apple Silicon, ${RAM_GB} GB memory"

if   (( RAM_GB < 12 )); then CHAT_MODEL="qwen3.5:4b";  SIZE="3.3 GB"; FIM="Qwen2.5-Coder 1.5B"
elif (( RAM_GB < 24 )); then CHAT_MODEL="qwen3.5:9b";  SIZE="6.6 GB"; FIM="Qwen2.5-Coder 1.5B"
else                         CHAT_MODEL="gpt-oss:20b"; SIZE="14 GB";  FIM="Qwen2.5-Coder 7B"
fi
CHAT_MODEL="${CHAT_MODEL_OVERRIDE:-$CHAT_MODEL}"

echo "2/5  Homebrew"
if command -v brew >/dev/null 2>&1; then ok "Homebrew found"
else warn "Homebrew not found. Install it from https://brew.sh (llama.vscode uses it to install llama.cpp)."; NO_BREW=1; fi

echo "3/5  Ollama"
command -v ollama >/dev/null 2>&1 || die "Ollama not found. Install it from https://ollama.com/download and open it once."
if curl -fsS "$OLLAMA_URL/api/version" >/dev/null 2>&1; then
  ok "Ollama is running ($(curl -fsS "$OLLAMA_URL/api/version" | sed -E 's/.*"version": *"([^"]+)".*/\1/'))"
else
  die "Ollama is installed but not running. Open the Ollama app (or run: ollama serve) and try again."
fi

echo "4/5  Chat model for ${RAM_GB} GB: ${CHAT_MODEL} (${SIZE})"
if ollama list | awk 'NR>1 {print $1}' | grep -qx "$CHAT_MODEL"; then ok "$CHAT_MODEL already pulled"
else ollama pull "$CHAT_MODEL" && ok "pulled $CHAT_MODEL"; fi

echo "5/5  VS Code extensions + llama.cpp"
if command -v code >/dev/null 2>&1; then
  code --install-extension Ollama.ollama >/dev/null && ok "Ollama extension (Ollama.ollama)"
  code --install-extension ggml-org.llama-vscode >/dev/null && ok "llama.vscode (ggml-org.llama-vscode)"
else
  warn "The 'code' command isn't on your PATH. In VS Code: Command Palette → 'Shell Command: Install code command in PATH',"
  warn "or install these two from the Extensions panel: Ollama (publisher Ollama) and llama-vscode (publisher ggml-org)."
fi
if (( NO_BREW == 0 )); then
  if command -v llama-server >/dev/null 2>&1; then ok "llama.cpp already installed"
  else brew install llama.cpp && ok "installed llama.cpp"; fi
fi

cat <<NEXT

Next steps (README.md has every step):
  1. VS Code Chat → model picker → Ollama section → ${CHAT_MODEL}
  2. Ollama app → Settings → context length 64k → reload the VS Code window
     (then run 'ollama ps': if PROCESSOR isn't 100% GPU, use 32k)
  3. Status bar → llama-vscode → Select/start env... → completion with ${FIM}
  4. Settings → 'utility model' → set both utility models to ${CHAT_MODEL}
  5. ./verify.sh
NEXT
