#!/bin/sh
# Contexel PostToolUse hook (Claude Code plugin), matched on Write, Edit and MultiEdit.
#
# The safety net: when the agent saves something to its BUILT-IN memory (Claude Code's
# auto-memory lives in `~/.claude/projects/<project>/memory/`, indexed by MEMORY.md), ask it
# to save the same fact to Contexel too, alongside its own copy. Without this, a note saved
# only locally never reaches the user's other AI apps or their team.
#
# Fires for that default folder, and for any MEMORY.md (so a memory kept elsewhere, through a
# custom CLAUDE_CONFIG_DIR or autoMemoryDirectory, is still caught when its index is updated).
# A project's own `src/memory/` code is NOT memory. Silent for every other file write.
# Dependency-free POSIX sh: the file path is read from the hook's stdin JSON with a plain
# pattern match. No network, no secrets, nothing written.

input=$(cat)

path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n 1 | sed 's/.*:[[:space:]]*"//; s/"$//')

case "$path" in
  */.claude/projects/*/memory/* | */MEMORY.md | MEMORY.md)
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"You saved that to your own memory, which only this app on this machine can see. If Contexel is connected, save the same fact there too with its `remember` tool (search your tools for \"contexel remember\" if needed), so the user'"'"'s other AI apps and their team have it. If this changes a memory already saved there, find it with `get_context` or `search`, then fix it with `correct` using its id."}}'
    ;;
esac
exit 0
