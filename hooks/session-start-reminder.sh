#!/bin/sh
# Contexel SessionStart reminder (Claude Code plugin).
#
# LIGHT by design: prints a static reminder to stdout, which Claude Code injects
# into the session as context (SessionStart stdout is added to the context). It
# does NOT run any external tool, reach a remote endpoint, or auto-run `prime` —
# that heavy auto-briefing variant spends tokens every session and is OPT-IN (see
# the note below). Dependency-free POSIX sh: only the printf builtin, no secrets.

printf '%s\n' \
  'If Contexel is connected, it is this team'\''s shared memory for AI. It keeps what the user' \
  'asks to remember so their other AI apps and teammates can find it, alongside your own memory.' \
  '' \
  '- RETRIEVE FIRST: before answering about this team'\''s or user'\''s projects, decisions,' \
  '  standards, conventions, or people, call `get_context { task }` (or `prime { task }`' \
  '  for a compact briefing); your training won'\''t include what they saved.' \
  '- REMEMBER into Contexel: when the user says "remember", "note this", "save this", or' \
  '  "from now on", save it with `observe` (a quick note) or `propose` (a lasting entry in' \
  '  the team'\''s memory) right away, without asking, along with your own memory.' \
  '  Save only what the user asked to keep. When you merely learn a durable' \
  '  decision, standard, or lesson while working, OFFER at the end of the task to save it:' \
  '  ask first, never write silently. Depending on your access, a save lands directly or' \
  '  goes to a teammate for approval — the tool'\''s response says which.' \
  '- You don'\''t have to pick a workspace: omit it and Contexel chooses one, then names' \
  '  the workspace it used in the result — relay that, and save again with `realm` named' \
  '  if it is not the one the user meant.' \
  '- Answer the user from a result'\''s readable text, not its structured fields.' \
  '  Every tool returns both; the fields are there for you to parse, not to quote.' \
  '' \
  'Run `status` to see which workspaces this connection can reach before naming a realm.'

# OPT-IN heavy variant (OFF by default): a stronger nudge that spends tokens every
# session. The plan keeps the auto-briefing opt-in. To enable it, append a line here
# telling the agent to call `prime { task }` immediately at session start, e.g.:
#   printf '%s\n' 'At the start of this session, call `prime { task: "resume my work" }` now.'
# Leave it commented for the default light reminder above.
