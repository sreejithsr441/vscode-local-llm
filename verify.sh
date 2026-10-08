#!/usr/bin/env bash
# verify.sh — prove both books work: one chat call (Ollama) and one fill-in-the-middle call (llama.cpp or Ollama).
#   ./verify.sh                      auto-detects your chat model and the llama.vscode completion server (port 8012)
#   CHAT_MODEL=qwen3.5:9b ./verify.sh
# Works with the Wi-Fi off: everything goes to 127.0.0.1.
set -uo pipefail
OLLAMA_URL="${OLLAMA_HOST:-http://127.0.0.1:11434}"
FIM_URL="${FIM_URL:-http://127.0.0.1:8012}"
FIM_OLLAMA_MODEL="${FIM_OLLAMA_MODEL:-qwen2.5-coder:1.5b}"
command -v python3 >/dev/null 2>&1 || { echo "python3 is needed to read the replies (xcode-select --install)"; exit 1; }

PREFIX='def area(w, h):
    """Area of a rectangle."""
'
SUFFIX='

print(area(3, 4))
'

echo "== Chat (Ollama at $OLLAMA_URL)"
if ! curl -fsS "$OLLAMA_URL/api/version" >/dev/null 2>&1; then echo "  Ollama isn't running. Open the Ollama app."; exit 1; fi
CHAT_MODEL="${CHAT_MODEL:-$(curl -fsS "$OLLAMA_URL/api/tags" | python3 -c '
import json,sys
names=[m["name"] for m in json.load(sys.stdin).get("models",[])]
pref=[n for n in names if n.startswith(("qwen3.5","gpt-oss"))]
print((pref or names or [""])[0])')}"
[[ -n "$CHAT_MODEL" ]] || { echo "  No models pulled yet. Run ./setup.sh first."; exit 1; }
echo "  model: $CHAT_MODEL"
BODY=$(python3 -c 'import json,sys; print(json.dumps({"model":sys.argv[1],"stream":False,
 "messages":[{"role":"user","content":"In one sentence: what does this function do?\n\n"+sys.argv[2]+"    return w * h\n"}]}))' "$CHAT_MODEL" "$PREFIX")
curl -fsS -m 300 "$OLLAMA_URL/api/chat" -d "$BODY" | python3 -c '
import json,sys
r=json.load(sys.stdin)
print("  answer:", r.get("message",{}).get("content","").strip()[:300])
ev, ed, tot = r.get("eval_count", 0), r.get("eval_duration", 0) / 1e9, r.get("total_duration", 0) / 1e6
print("  total %s ms" % format(round(tot), ","), ("· %.1f tokens/s" % (ev / ed)) if ed else "")
' || echo "  chat request failed"

echo
echo "== Autocomplete (fill in the middle)"
if curl -fsS "$FIM_URL/health" >/dev/null 2>&1; then
  echo "  llama.cpp server at $FIM_URL (started by llama.vscode)"
  BODY=$(python3 -c 'import json,sys; print(json.dumps({"input_prefix":sys.argv[1],"input_suffix":sys.argv[2],"n_predict":32}))' "$PREFIX" "$SUFFIX")
  curl -fsS -m 120 -w '\n%{time_total}' "$FIM_URL/infill" -d "$BODY" | python3 -c '
import json,sys
raw=sys.stdin.read().rsplit("\n",1); r=json.loads(raw[0]); wall=float(raw[1])*1000
print("  suggestion:", repr(r.get("content","")))
t=r.get("timings") or {}
if t: print("  prompt %.0f ms · predict %.0f ms (%s tokens)" % (t.get("prompt_ms", 0), t.get("predicted_ms", 0), t.get("predicted_n", 0)))
print("  round trip %s ms" % format(round(wall), ","))
' || echo "  infill request failed"
elif curl -fsS "$OLLAMA_URL/api/tags" | grep -q "\"$FIM_OLLAMA_MODEL\""; then
  echo "  llama.vscode server not running; using Ollama's $FIM_OLLAMA_MODEL with suffix (fill in the middle)"
  BODY=$(python3 -c 'import json,sys; print(json.dumps({"model":sys.argv[1],"prompt":sys.argv[2],"suffix":sys.argv[3],"stream":False,
   "options":{"num_predict":32,"temperature":0}}))' "$FIM_OLLAMA_MODEL" "$PREFIX" "$SUFFIX")
  curl -fsS -m 120 "$OLLAMA_URL/api/generate" -d "$BODY" | python3 -c '
import json,sys
r=json.load(sys.stdin)
print("  suggestion:", repr(r.get("response","")))
print("  total %s ms (includes loading the model on the first run)" % format(round(r.get("total_duration", 0) / 1e6), ","))
' || echo "  request failed"
else
  echo "  No completion server found. In VS Code: status bar → llama-vscode → Select/start env... (it listens on port 8012),"
  echo "  or: ollama pull $FIM_OLLAMA_MODEL  and run this again."
fi
echo
echo "Add your numbers to TESTED.md, and share them in the comments!"
