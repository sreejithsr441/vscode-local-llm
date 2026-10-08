# Tested

Fill this in from your own run (`./verify.sh`). Pin versions so viewers know what worked.

| | Value |
|---|---|
| Mac / chip | |
| Memory | |
| macOS | |
| VS Code | |
| Ollama | |
| Ollama extension | |
| llama.vscode | |
| llama.cpp (`llama-server --version`) | |
| Chat model | qwen3.5:9b |
| Completion model | Qwen2.5-Coder 1.5B (Q8_0) |
| Context length | |
| `ollama ps` PROCESSOR | |
| Chat speed (tokens/s, verify.sh) | |
| Autocomplete round trip (ms, verify.sh, median of 3) | |
| Wi-Fi off: chat / autocomplete / chat titles | / / |
| Date | |

## Published reference used in the video
llama.vim README (ggml-org): M1 Pro (2021), Qwen2.5-Coder 1.5B Q8_0, context 15,186 / 32,768 tokens,
260 new prompt tokens, 24 generated, **1,245 ms** for one suggestion.
