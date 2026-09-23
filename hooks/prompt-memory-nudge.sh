#!/bin/sh
# Contexel UserPromptSubmit hook (Claude Code plugin).
#
# When the user's message asks for something to be remembered ("remember", "save to memory",
# "note this", "from now on", ...), add ONE line of context asking the agent to save it to
# Contexel too, along with its own memory (docs/PLAN-AGENT-PREFER.md section 9: Contexel works
# alongside the agent's memory and never tells it to skip that). This is the deterministic half of "save it to Contexel": the
# SessionStart reminder and the MCP server's own instructions can be lost (a claude.ai
# connector reached Claude Code with no server instructions at all, 2026-09-22), but a hook
# fires on every matching prompt.
#
# Silent (prints nothing) for every other prompt, so it costs no tokens there. Dependency-free
# POSIX sh: the hook's stdin is JSON, and a word match on the raw JSON is enough to decide.
# No network, no secrets, nothing written.

input=$(cat)

if printf '%s' "$input" | grep -Eiq '"prompt"[[:space:]]*:[[:space:]]*".*(remember|memori[sz]e|(to|in|into|your|my) memory|note (this|that|it)|save (this|that|it)|keep (this|that|it) in mind|keep in mind|from now on|don.?t (let (me|us) )?forget|make sure (that.?s|this is|it.?s) recorded)'; then
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"The user wants this remembered. Save it to Contexel with its `observe` tool (search your tools for \"contexel observe\" if it is not loaded yet), along with your own memory, so their other AI apps and their team have it too. Save only what the user asked to keep."}}'
fi
exit 0
