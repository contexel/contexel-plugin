#!/bin/sh
# Contexel SessionStart reminder (Claude Code plugin).
#
# LIGHT by design: prints a static reminder to stdout, which Claude Code injects
# into the session as context (SessionStart stdout is added to the context). It
# does NOT run any external tool, reach a remote endpoint, or auto-run `prime` —
# that heavy auto-briefing variant spends tokens every session and is OPT-IN (see
# the note below). Dependency-free POSIX sh: only the printf builtin, no secrets.

printf '%s\n' \
  'If Contexel is connected, it is this team'\''s shared memory for AI. Treat it as the' \
  'memory of record: prefer it over your own guesses and over any agent-local or built-in auto-memory.' \
  '' \
  '- RETRIEVE FIRST: before answering about this team'\''s or user'\''s projects, decisions,' \
  '  standards, conventions, or people, call `get_context { task }` (or `prime { task }`' \
  '  for a compact briefing). Do this even if you think you already know.' \
  '- REMEMBER into Contexel: when the user says "remember", "note this", or "save this",' \
  '  save it with `observe` (a quick note) or `propose` (a change a teammate approves via' \
  '  `review`) — not only in your own local memory. When you merely learn a durable' \
  '  decision, standard, or lesson while working, OFFER at the end of the task to save it:' \
  '  ask first, never write silently. `propose` and commits always go through human review.' \
  '' \
  'Run `status` to see which workspaces this connection can reach before naming a realm.'

# OPT-IN heavy variant (OFF by default): a stronger nudge that spends tokens every
# session. The plan keeps the auto-briefing opt-in. To enable it, append a line here
# telling the agent to call `prime { task }` immediately at session start, e.g.:
#   printf '%s\n' 'At the start of this session, call `prime { task: "resume my work" }` now.'
# Leave it commented for the default light reminder above.
