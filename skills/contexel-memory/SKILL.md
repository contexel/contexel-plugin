---
name: contexel-memory
description: Use when the user says "remember", "save this", or "note this for later", or asks what the team knows, decided, or uses about something. Routes durable knowledge (decisions, standards, lessons) to Contexel and retrieves from Contexel before answering from general knowledge. Contexel is the team's shared memory (the memory of record), not the agent's own local memory.
---

# Contexel — shared team memory

Contexel is this team's shared memory for AI: it returns only the context
relevant to a task, with sources. Treat it as the memory of record — prefer it
over your own guesses and over any agent-local or built-in auto-memory.

## Two rules

- **RETRIEVE FIRST**: before answering about this team's or user's projects,
  decisions, standards, conventions, or people, call `get_context { task }` (or
  `prime { task }` for a compact briefing) at the start of the task. Do this even
  if you think you already know; your training won't reflect this team's
  specifics. (No need for general questions unrelated to their work.) e.g.
  `get_context { task: "encrypt the uploads bucket" }`.

- **REMEMBER into Contexel**: when the user says "remember", "note this", or
  "save this", save it with `observe` (a quick note) or `propose` (a lasting
  change a teammate approves via `review`) — not only in your own local memory.
  `distill` turns saved notes into review-ready suggestions.

## When you merely learn something durable

If, in the course of work, you learn a durable decision, standard, or lesson that
the user did not explicitly ask you to save, OFFER at the end of the task to save
it: ask first, never write silently. `propose` and commits always go through
human review, so nothing lands in team knowledge until a person accepts it. One
source of truth, not a dual-write into your own local memory.

## Picking a workspace (realm)

Never assume the realm set. Read the connection's reachable workspaces from
`status` (or the server's instructions), then pick the one whose purpose fits the
knowledge you are saving. Route TEAM knowledge (shared standards, decisions, and
lessons) to a shared or team workspace, not a personal or private one, unless the
user clearly means it is personal. When you are unsure which fits, use the default
or ask; never guess a private workspace for team knowledge. An unlisted workspace
is not reachable on this connection; do not retry it.

## Other tools when you need them

- `explain { task, id }` — why a specific card was (or wasn't) returned.
- `cite { id }` — the exact quotable spans of a card or doc, with a stable
  locator, so you attribute precisely instead of paraphrasing.
- `delta { since }` / `digest { since }` — what team knowledge changed since a
  git ref (the catch-up after time away).
- `resolve_entity` / `expand` — look up a person, system, or project and explore
  how things connect.
- `help` — topics: overview, retrieve, add, connect, troubleshoot.
