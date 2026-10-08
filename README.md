# Use a Local LLM in VS Code on Your Mac (Free, Offline)

Companion folder for the Ring Zero video **"Use a Local LLM in VS Code on Your Mac (Free, Offline)"** · [watch it here](VIDEO_URL)

VS Code on your Mac will finish your code and answer questions about it, free, with the Wi-Fi off. Two jobs, two tools:

| Job | Tool | Model (16 GB Mac) |
|---|---|---|
| **Chat** (ask, it answers) | VS Code Chat + the **Ollama** extension (publisher: Ollama) | `qwen3.5:9b` |
| **Autocomplete** (grey text as you type) | **llama.vscode** (publisher: ggml-org, the llama.cpp team) | Qwen2.5-Coder 1.5B |

Why two? VS Code's docs say: *"Currently, you cannot connect to a local model for inline suggestions."* Chat works with a local model; autocomplete needs a separate extension and a model trained to fill in the middle.

## What you need

- A Mac with Apple Silicon, 8 GB of memory or more (16 GB recommended)
- [VS Code](https://code.visualstudio.com) **1.127 or newer**
- [Ollama](https://ollama.com/download) (0.17.6 or newer recommended)
- [Homebrew](https://brew.sh) (llama.vscode uses it to install llama.cpp)

## Quick start

```bash
git clone https://github.com/YOUR_GITHUB/ring-zero-examples.git
cd ring-zero-examples/vscode-local-llm
./setup.sh          # checks your Mac, pulls the chat model for your RAM, installs both extensions
./verify.sh         # one chat call + one autocomplete call, prints how long each took
```

## The steps (same order as the video chapters)

### 0:00 Offline AI autocomplete in VS Code
What we're building: autocomplete + chat, on your Mac, free, offline.

### 1:04 Chat vs autocomplete: two different jobs
Chat goes through VS Code's own Chat panel. Autocomplete goes through llama.vscode. Your Mac's memory is the desk; it holds two books: a thick chat model and a pocket-sized autocomplete model.

### 1:44 Step 1: Pick a chat model
Ollama must be running. Pull one model for your Mac's memory (`setup.sh` picks it for you):

| Mac memory | Command | Download |
|---|---|---|
| 8 GB | `ollama pull qwen3.5:4b` | 3.3 GB |
| 16 GB | `ollama pull qwen3.5:9b` | 6.6 GB |
| 24 GB or more | `ollama pull gpt-oss:20b` | 14 GB |

Check it with `ollama ls`.

### 2:19 Step 2: Add Ollama to VS Code Chat
1. Extensions panel → search **Ollama** → install the one published by **Ollama** (ID `Ollama.ollama`).
   The older built-in Ollama option in VS Code is deprecated.
2. Open Chat → click the model picker → pick your model from the **Ollama** section. No GitHub sign-in needed.

### 2:58 Fix cut-off answers: context length
Ollama starts with a 4k context on Macs with under 24 GB for the GPU. Ollama's VS Code guide asks for at least 64k.
1. Ollama app → **Settings** → slide **context length** to 64k (or start the server with `OLLAMA_CONTEXT_LENGTH=64000 ollama serve`).
2. Reload the VS Code window (Command Palette → **Developer: Reload Window**).
3. Run `ollama ps`. If PROCESSOR doesn't say `100% GPU`, step down to 32k.

### 3:40 Step 3: Local autocomplete with llama.vscode
1. Install **llama-vscode** (publisher ggml-org, ID `ggml-org.llama-vscode`).
2. Click **llama-vscode** in the status bar (or Ctrl+Shift+M) → **Install/Upgrade llama.cpp**.
3. Menu → **Select/start env...** → pick a completion env with **Qwen2.5-Coder 1.5B** (24 GB or more: the 7B).
4. Start typing. Grey text = suggestion. **Tab** accepts it.

### 4:35 How fast is it?
The llama.cpp team published one suggestion on an M1 Pro (2021) with Qwen2.5-Coder 1.5B Q8_0 and 15,186 tokens of context: **1,245 ms**. Run `./verify.sh` for your own number, and add it to the comments.

### 5:11 Step 4: Make it fully offline
VS Code uses a small cloud model for small jobs like naming chats. Point both at your local model:
Settings → search **utility model** → set **Chat: Utility Model** and **Chat: Utility Small Model** to your Ollama model.
See [`settings.jsonc`](settings.jsonc) for the setting names (plus optional telemetry off). Then switch off the Wi-Fi and try it.

### 5:52 Local vs Copilot Free
Copilot Free: 2,000 completions a month; on personal plans, interaction data (including code snippets) is used for training unless you opt out (since April 24, 2026). Local: no limit, no account, the code stays on your Mac. The trade-off: local models are smaller than cloud ones.

### 6:32 Fix: model missing, answers cut off, no suggestions
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Files

| File | What it does |
|---|---|
| `setup.sh` | Checks Apple Silicon, Homebrew, Ollama; pulls the chat model for your RAM; installs both extensions (if the `code` command exists) and llama.cpp |
| `verify.sh` | One chat request to Ollama, one fill-in-the-middle request to llama.cpp (port 8012) or Ollama, with timings |
| `settings.jsonc` | VS Code settings used in the video |
| `TROUBLESHOOTING.md` | The three errors from the video, plus context and speed fixes |
| `TESTED.md` | Versions and numbers: fill in yours |

## Sources

- VS Code – AI language models: https://code.visualstudio.com/docs/agent-customization/language-models
- Ollama – VS Code: https://docs.ollama.com/integrations/vscode
- Ollama – context length: https://docs.ollama.com/context-length
- llama.vscode: https://github.com/ggml-org/llama.vscode
- llama.vim (timing example): https://github.com/ggml-org/llama.vim
- GitHub Copilot plans: https://github.com/features/copilot/plans
- GitHub Copilot data usage update: https://github.blog/news-insights/company-news/updates-to-github-copilot-interaction-data-usage-policy/

Last checked: October 8, 2026. If a tool update breaks a step, check the dated notes at the top of this file.
# vscode-local-llm
