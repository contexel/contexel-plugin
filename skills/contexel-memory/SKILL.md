---
name: contexel-memory
description: Use when the user says "remember", "save this", or "note this for later", says a saved memory is wrong, or asks what the team knows, decided, or uses about something. Saves what the user asks to keep (decisions, standards, lessons) to Contexel, along with your own memory, fixes a wrong memory there, and retrieves from Contexel before answering about the team's work. Contexel is the team's shared memory for AI.
---

# Contexel: shared team memory

Contexel is this team's shared memory for AI: it returns only the context
relevant to a task, with sources, and keeps what the user asks to remember so
their other AI apps and teammates can find it. It works alongside your own memory.

## Two rules

- **RETRIEVE FIRST**: before answering about this team's or user's projects,
  decisions, standards, conventions, or people, call `get_context { task }` at
  the start of the task; your training won't include what they saved. (No need
  for general questions unrelated to their work.) e.g.
  `get_context { task: "encrypt the uploads bucket" }`.

- **REMEMBER into Contexel**: when the user says "remember", "note this", "save
  this", or "from now on", save it with `remember` right away (no lookup first),
  without asking, along with your own memory. Save only what the user asked to keep.

## Fixing a memory that is wrong

When the user says a saved memory is wrong or out of date, find it with
`get_context` or `search`, then fix it with `correct` using its id. Pass that `id`, a short `reason`, and the new text as `replace_with`. To retire
a memory that no longer holds, leave out `replace_with` and pass the memory's
id. Pass the `realm` the result named, if it named one.

Depending on your access, a save or fix lands at once or is queued for
approval; the response says which, and names the workspace.

## Relaying an answer

Tell the user what you found in plain words, never field names. Some
apps show you a result's readable text and some show only its structured fields.
Either way, reciting the fields hands the user the engine's own vocabulary (raw
counts, index freshness, embedder names) instead of an answer, and it is how a
private workspace ends up described to its owner as a hash worth deleting.

## When you merely learn something durable

If, in the course of work, you learn a durable decision, standard, or lesson that
the user did not explicitly ask you to save, OFFER at the end of the task to save
it: ask first, never write silently.

## Picking a workspace (realm)

You don't have to pick a workspace. Omit it and Contexel chooses one, then names
the workspace it used in the result. Always relay that, so the user can see where
their memory went and say if it belongs elsewhere.

When you DO know which one fits, name it: read the connection's reachable
workspaces from `status` (or the server's instructions) and pick the one whose
purpose matches. Route TEAM knowledge (shared standards, decisions, and lessons)
to a shared or team workspace. Never assume the realm set: this list is a
connect-time snapshot and `status` is the live authority. A workspace that
`status` does not list is not reachable on this connection, so do not retry it.

When you are unsure, prefer omitting the workspace over guessing one. Contexel
errs toward the user's own private space rather than a shared one, and says so;
if several workspaces could take the save and none is clearly theirs, it asks
instead of guessing. Guessing a SHARED workspace yourself is the one mistake with
no undo.

## Other tools

- `status`: which workspaces this connection can reach, what is saved in each,
  and whether it is up to date.
- `search` / `fetch`: find memories by keyword, then read one in full.

These are the everyday tools every connection gets. The full set (briefings,
history, review and curation) needs `?tools=all` added to the Contexel MCP URL,
or `CONTEXEL_TOOLS=all` for a local stdio server. If the user needs one of those,
tell them; you cannot switch it yourself.
