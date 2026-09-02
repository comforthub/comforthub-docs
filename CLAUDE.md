# CLAUDE.md

How to work in this docs repo. Read it before editing anything.

## Who this is for

- The owner and the developers who run the business's projects. Not a public audience.
- Write in plain language. If a technical term is needed, explain it the first time it appears.
- Every page is one of three kinds and never a mix: **how-to** (do one task), **reference** (look up a fact), **explanation** (why it works this way).
- Do not describe internals of the code. Describe what a project does, how to operate it, and what to do when it breaks.

## About this project

- This is a documentation site built on [Mintlify](https://mintlify.com)
- Pages are MDX files with YAML frontmatter
- Configuration lives in `docs.json`
- Use the Mintlify MCP server, `https://mcp.mintlify.com`, to edit content and settings via MCP
- Use the Mintlify docs MCP server, `https://www.mintlify.com/docs/mcp`, to query information about using Mintlify via MCP
- Work through either the MCP server or the `mint` CLI, never by guessing. MCP for content and settings; CLI for `mint dev` (preview), `mint validate`, and `mint broken-links`.
  - Register the MCP server once: `claude mcp add --transport http mintlify https://mcp.mintlify.com`
  - Install the CLI once: `npm i -g mint`

## Rules and gates

`scripts/check.sh` is the gate. Run it before every commit, or wire it once with `git config core.hooksPath scripts/githooks`. It also runs on every push in GitHub. It fails when:

1. A page has no `title` or `description`.
2. A page exists but is not in `docs.json`, or `docs.json` lists a page that does not exist.
3. Template text from the starter kit is still present.
4. Anything that looks like a key, token, or password is in the docs.
5. `mint validate` or `mint broken-links` reports a problem.

A rule the script cannot check is still a rule: plain language, one kind of page per file, no secrets, no customer data.

## Terminology

{/* Add product-specific terms and preferred usage */}
{/* Example: Use "workspace" not "project", "member" not "user" */}

## Style preferences

{/* Add any project-specific style rules below */}

- Use active voice and second person ("you")
- Keep sentences concise — one idea per sentence
- Use sentence case for headings
- Bold for UI elements: Click **Settings**
- Code formatting for file names, commands, paths, and code references

## Content boundaries

{/* Define what should and shouldn't be documented */}
{/* Example: Don't document internal admin features */}

- Never put keys, tokens, passwords, or customer data in a page. Point to where they live instead.
- Do not paste code from the project repos. Link to the repo and describe what it does.
