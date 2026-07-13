# Contexel plugin for Claude Code

A small, generic Claude Code plugin that makes your agent **prefer Contexel** —
your team's shared memory for AI. It bundles:

- **The MCP connection** (`.mcp.json`) to the hosted Contexel server
  (`https://contexel.ai/mcp`), so installing the plugin also wires the
  connection — no separate `claude mcp add`. OAuth is negotiated by the
  transport the first time you run `/mcp` (browser sign-in); no key is stored.
- **A skill** (`contexel-memory`) that Claude auto-invokes when you say
  "remember / save this / note this", or ask what the team knows, decided, or
  uses about something. It codifies the two Contexel habits: RETRIEVE FIRST
  (`get_context` / `prime` before answering from general knowledge) and REMEMBER
  into Contexel (`observe` / `propose`), treating Contexel as the memory of
  record rather than the agent's own local memory.
- **A light SessionStart hook** that prints a one-time reminder into the session
  so the agent starts each session knowing to retrieve first and save durable
  facts to Contexel. It is static text only — it does not call the Contexel CLI,
  hit the network, or auto-run `prime` (that heavier variant spends tokens every
  session and stays opt-in; see `hooks/session-start-reminder.sh`).

## How it fits with the other setup steps

Installing this plugin bundles **Step 1** (the MCP connection, via `.mcp.json`)
together with the skill and hook, so for hosted Contexel it is the one-step path.
It still pairs with:

- **Step 2 — the per-project rules file.** Paste your workspace's rules artifact
  (from the Contexel console "Connect your agent" panel, `GET /v1/connect/rules`)
  into your project's `CLAUDE.md`. Agents follow project rules more reliably than
  server hints, and this is where your workspace's **realm list** comes from.

The plugin is **generic and tenant-agnostic**: it ships no realm names and no
secrets. The bundled MCP URL is the shared hosted endpoint
(`https://contexel.ai/mcp`) — the same for every team, because OAuth selects your
workspace at sign-in — so the same plugin works for everyone, and your realm list
still comes from the Step 2 rules file. (Self-hosting a Contexel server at a
different URL? Use `claude mcp add` with your URL instead of the bundled connection.)

## Install

### As a plugin (recommended)

From within Claude Code, add the marketplace (this repo), then install it:

```
/plugin marketplace add contexel/contexel-plugin
/plugin install contexel@contexel-plugin
```

Or point Claude Code straight at a local checkout to try it without installing:

```
claude --plugin-dir /path/to/contexel-plugin
```

After installing, run `/reload-plugins` (or restart) to load the skill and hook.
The skill is invocable as `/contexel:contexel-memory`, and Claude will also load
it automatically when your request matches its description.

### By copying into `~/.claude` (no marketplace)

Copy the skill into your user config:

```
mkdir -p ~/.claude/skills
cp -r clients/claude-code/skills/contexel-memory ~/.claude/skills/
```

That copy installs the **skill only**. The SessionStart reminder is a hook, and
hooks are configured separately, so to get it without the plugin install:

```
mkdir -p ~/.claude/contexel
cp clients/claude-code/hooks/session-start-reminder.sh ~/.claude/contexel/
chmod +x ~/.claude/contexel/session-start-reminder.sh
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
│       └── SKILL.md                # the auto-invoked skill (the two mandates)
├── hooks/
│   ├── hooks.json                  # SessionStart hook config
│   └── session-start-reminder.sh   # the light, dependency-free reminder
└── README.md
```

The skill body and the hook reminder are kept in lockstep with Contexel's server
`instructions` (the two mandates and "memory of record" framing) so all three say
the same thing.
