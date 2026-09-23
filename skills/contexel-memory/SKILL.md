---
name: contexel-memory
description: Use when the user says "remember", "save this", or "note this for later", or asks what the team knows, decided, or uses about something. Saves what the user asks to keep (decisions, standards, lessons) to Contexel, along with your own memory, and retrieves from Contexel before answering about the team's work. Contexel is the team's shared memory for AI.
---

# Contexel — shared team memory

Contexel is this team's shared memory for AI: it returns only the context
relevant to a task, with sources, and keeps what the user asks to remember so
their other AI apps and teammates can find it. It works alongside your own memory.

## Two rules

- **RETRIEVE FIRST**: before answering about this team's or user's projects,
  decisions, standards, conventions, or people, call `get_context { task }` (or
  `prime { task }` for a compact briefing) at the start of the task; your
  training won't include what they saved. (No need for general questions
  unrelated to their work.) e.g.
  `get_context { task: "encrypt the uploads bucket" }`.

- **REMEMBER into Contexel**: when the user says "remember", "note this", "save
  this", or "from now on", save it with `observe` (a quick note) or `propose` (a
  lasting entry in the team's memory) right away, without asking, along with
  your own memory. Save only what the user asked to keep. `distill` folds saved
  notes into lasting entries.

## Relaying an answer

Answer the user from a result's readable text, not its structured fields. Every
tool returns both: the text is written for a person, the fields are there for you
to parse. Paraphrasing the fields hands the user the engine's own vocabulary —
raw counts, index freshness, embedder names — instead of an answer, and it is how
a private workspace ends up described to its owner as a hash worth deleting.

## When you merely learn something durable

If, in the course of work, you learn a durable decision, standard, or lesson that
the user did not explicitly ask you to save, OFFER at the end of the task to save
it: ask first, never write silently. Depending on your access, a save lands
directly or goes to a teammate for approval — the tool's response says which;
nothing lands silently. One source of truth, not a dual-write into your own local
memory.

## Picking a workspace (realm)

You don't have to pick a workspace. Omit it and Contexel chooses one, then names
the workspace it used in the result — always relay that, so the user can see where
their memory went and say if it belongs elsewhere.

When you DO know which one fits, name it: read the connection's reachable
workspaces from `status` (or the server's instructions) and pick the one whose
purpose matches. Route TEAM knowledge (shared standards, decisions, and lessons)
to a shared or team workspace. Never assume the realm set — this list is a
connect-time snapshot and `status` is the live authority; a workspace that
`status` does not list is not reachable on this connection, so do not retry it.

When you are unsure, prefer omitting the workspace over guessing one. Contexel
errs toward the user's own private space rather than a shared one, and says so;
if several workspaces could take the save and none is clearly theirs, it asks
instead of guessing. Guessing a SHARED workspace yourself is the one mistake with
no undo.

## Other tools when you need them

- `explain { task, id }` — why a specific memory was (or wasn't) returned.
- `cite { id }` — the exact quotable spans of one memory (or one section of it),
  with a stable locator, so you attribute precisely instead of paraphrasing.
- `delta { since }` / `digest { since }` — what team knowledge changed since a
  git ref (the catch-up after time away).
- `resolve_entity` / `expand` — look up a person, system, or project and explore
  how things connect.
- `help` — topics: overview, retrieve, add, connect, troubleshoot.
