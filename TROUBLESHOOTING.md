# Troubleshooting

## 1. My model is missing in agent mode
- Agent mode only lists models that support **tool calling**: *"For a model to be available when using agents in chat, it must support tool calling."* Use a tools model from the README table (`qwen3.5:9b`, `qwen3.5:4b`, `gpt-oss:20b`).
- If the picker shows only **Auto**, the folder is untrusted: *"In an untrusted workspace in Restricted Mode, the chat model picker only shows Auto."* Trust the workspace.
- Still missing? Command Palette → **Ollama: Refresh Models**, or **Ollama: Diagnose Models** and check the Ollama output channel. Confirm `ollama list` shows the model.

## 2. Answers stop halfway (or forget the start of the file)
The context window (the model's notepad) is too small. Ollama defaults to **4k** on Macs with under 24 GB for the GPU; Ollama's VS Code guide asks for **at least 64k**.
- Ollama app → Settings → context length → 64k, then reload the VS Code window, then resend the prompt.
- Or: `OLLAMA_CONTEXT_LENGTH=64000 ollama serve`
- Run `ollama ps`. If PROCESSOR is not `100% GPU`, the bigger notepad pushed part of the model off the GPU: use 32k, or a smaller model.
- Note: VS Code may show a model's maximum context even when Ollama allocates less.

## 3. No grey text (no suggestions)
- Status bar → **llama-vscode** → **Select/start env...** and pick a completion env. The completion server listens on port 8012; `./verify.sh` checks it.
- First time? Menu → **Install/Upgrade llama.cpp** (needs Homebrew), then select the env again. The model downloads on first start.
- Accept: **Tab** · first line only: **Shift+Tab** · next word: **Ctrl+→** · reject: **Esc**.

## Suggestions are slow
- Use the 1.5B completion model (the 7B is for 24 GB or more).
- Check both books fit on the desk: `ollama ps` should show `100% GPU` for the chat model while llama.vscode is running.
- Ollama keeps a model loaded for 5 minutes after use; the first request after that is slower while it loads.
