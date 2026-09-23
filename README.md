# Contexel plugin for Claude Code

A small, generic Claude Code plugin that gives your agent Contexel, your team's
shared memory for AI, alongside its own memory. It bundles:

- **The MCP connection** (`.mcp.json`) to the hosted Contexel server
  (`https://contexel.ai/mcp`), so installing the plugin also wires the
  connection; no separate `claude mcp add`. OAuth is negotiated by the
  transport the first time you run `/mcp` (browser sign-in). The plugin itself
  contains no API key: any OAuth token is held by Claude Code, not the plugin.
- **A skill** (`contexel-memory`) that Claude auto-invokes when you say
  "remember / save this / note this", say a saved memory is wrong, or ask what
  the team knows, decided, or uses about something. It codifies the Contexel
  habits: RETRIEVE FIRST (`get_context` before answering about the team's work),
  REMEMBER into Contexel (`remember`, along with the agent's own memory), and fix
  or retire a wrong memory with `correct`.
- **A light SessionStart hook** that prints a short reminder into the session
  so the agent starts each session knowing to retrieve first and save durable
  facts to Contexel. It is static text only: it does not call the Contexel CLI,
  reach the network, or run a lookup on its own (that heavier variant spends
  tokens every session and stays opt-in; see `hooks/session-start-reminder.sh`).
- **Two memory hooks** that make a "remember this" reach Contexel too, alongside
  the agent's own built-in memory (never in place of it):
  - `prompt-memory-nudge.sh` (UserPromptSubmit): when your message asks for
    something to be remembered ("remember", "save to memory", "note this",
    "from now on", ...), it adds one line asking the agent to save it with
    Contexel's `remember` tool as well, or to fix the saved memory with
    `correct` if it changes one. Silent for every other message.
  - `local-memory-catch.sh` (PostToolUse on Write, Edit and MultiEdit): when the
    agent saves to its built-in memory folder, it asks the agent to save the same
    fact to Contexel too, so it doesn't stay on one machine.

  Both are local shell scripts: no network, no secrets, nothing written. Measured
  with Contexel's call-through eval under realistic conditions (no server
  instructions reaching the agent, a lived-in built-in memory), saves reaching
  Contexel went from 0 of 6 without the plugin to 6 of 6 with these hooks.

## Which tools your agent gets

A Contexel connection gets the everyday tools by default: `get_context`,
`remember`, `correct`, `status`, `search` and `fetch` (plus `observe`, the older
name for `remember`). The skill and hooks name only these, so they work on
every connection. Whether a save or a fix lands at once or is queued for
approval depends on your access in that workspace; the response says which.

For every tool (briefings, history, review and curation), use the copy-based
setup below (the skill and hooks without the bundled connection) and connect with
`claude mcp add --transport http contexel "https://contexel.ai/mcp?tools=all"`.
The bundled connection cannot be repointed, so installing the plugin as well would
give you two Contexel servers. On a local stdio server, set `CONTEXEL_TOOLS=all`
in its environment instead.

## How it fits with the other setup steps

Installing this plugin bundles **Step 1** (the MCP connection, via `.mcp.json`)
together with the skill and hooks, so for hosted Contexel it is the one-step path.
It still pairs with:

- **Step 2: the per-project rules file.** Paste your workspace's rules
  (from the Contexel console's "Connect your agent" panel, `GET /v1/connect/rules`)
  into your project's `CLAUDE.md`. Agents follow project rules more reliably than
  server hints, and this is where your workspace list comes from.

The plugin is **generic and tenant-agnostic**: it ships no workspace names and no
secrets. The bundled MCP URL is the shared hosted endpoint
(`https://contexel.ai/mcp`), the same for every team, because OAuth selects your
workspace at sign-in. So the same plugin works for everyone, and your workspace
list still comes from the Step 2 rules file.

> **Self-hosting Contexel at a different URL?** This marketplace install is for the
> **hosted** service: its bundled `.mcp.json` points at `https://contexel.ai/mcp`
> and installing it would connect you there. Do **not** install it via the
> marketplace; running `claude mcp add` alongside it only *adds* a second server, it
> does not repoint the bundled one, so your queries could still reach the hosted
> service. Instead, connect your own server with `claude mcp add --transport http
> contexel <YOUR_MCP_URL>` and add the skill and hooks via the copy-based setup below.

## Install

> This plugin is distributed as the standalone public repo
> **[github.com/contexel/contexel-plugin](https://github.com/contexel/contexel-plugin)**,
> with these files at the **repo root** (so `.claude-plugin/marketplace.json` is the
> marketplace root). The commands below target that published repo. (Inside the Contexel
> monorepo the same files live under `clients/claude-code/` as the canonical source.)

### As a plugin (recommended)

From within Claude Code, add the marketplace repo, then install it:

```text
/plugin marketplace add contexel/contexel-plugin
/plugin install contexel@contexel-plugin
```

Or point Claude Code straight at a local checkout of that repo to try it without installing:

```shell
claude --plugin-dir /path/to/contexel-plugin
```

After installing, run `/reload-plugins` (or restart) to load the skill and hooks.
The skill is invocable as `/contexel:contexel-memory`, and Claude will also load
it automatically when your request matches its description.

### By copying into `~/.claude` (no marketplace)

From a checkout of this repo, copy the skill into your user config:

```
mkdir -p ~/.claude/skills
cp -r skills/contexel-memory ~/.claude/skills/
```

That copy installs the **skill only**. The reminder and the memory hooks are
hooks, and hooks are configured separately, so to get them without the plugin install:

```
mkdir -p ~/.claude/contexel
cp hooks/*.sh ~/.claude/contexel/
chmod +x ~/.claude/contexel/*.sh
```

Then add this to your `~/.claude/settings.json` (use the ABSOLUTE path you copied
to, since `${CLAUDE_PLUGIN_ROOT}` is only set for installed plugins):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "\"$HOME\"/.claude/contexel/session-start-reminder.sh" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "\"$HOME\"/.claude/contexel/prompt-memory-nudge.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "\"$HOME\"/.claude/contexel/local-memory-catch.sh" }
        ]
      }
    ]
  }
}
```

## Layout

```
.
├── .claude-plugin/
│   ├── plugin.json                 # plugin manifest (name, version, author)
│   └── marketplace.json            # marketplace entry (for /plugin marketplace add)
├── .mcp.json                       # bundled MCP server (the Contexel connection)
├── skills/
│   └── contexel-memory/
│       └── SKILL.md                # the auto-invoked skill (the two rules, and fixes)
├── hooks/
│   ├── hooks.json                  # SessionStart, UserPromptSubmit, PostToolUse config
│   ├── session-start-reminder.sh   # the light, dependency-free reminder
│   ├── prompt-memory-nudge.sh      # "remember this" prompts: save it to Contexel
│   └── local-memory-catch.sh       # a save to built-in memory: copy it to Contexel
└── README.md
```

The skill body and the hook reminder are kept in lockstep with Contexel's server
`instructions` and the rules file (the two rules, `remember` and `correct`, and the
"alongside your own memory" framing), so they all say the same thing. A test in the
Contexel repo (`src/cli/claude-code-plugin.test.ts`) fails if they drift.
