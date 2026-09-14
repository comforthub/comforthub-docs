# CLAUDE.md

How to work in this docs repo. Read it before editing anything.

## Who this is for

- The owner and the developers who run the business's projects. Not a public audience.
- The real reader is the owner in three months, or a developer who has never seen the project. Write for them.
- Write in plain language. If a technical term is needed, explain it the first time it appears, and add it to `reference/glossary.mdx`.
- Do not describe internals of the code. Describe what a process does, how to operate it, and what to do when it breaks.

## About this project

- This is a documentation site built on [Mintlify](https://mintlify.com).
- Pages are MDX files with YAML front matter. The menu is `docs.json`. Reusable bits live in `snippets/`. Blank pages to copy live in `templates/` (never published).
- Use the Mintlify MCP server, `https://mcp.mintlify.com`, to edit content and settings via MCP, and the Mintlify docs MCP server, `https://www.mintlify.com/docs/mcp`, to look up how Mintlify works. Never guess at Mintlify features.
  - Register once: `claude mcp add --transport http mintlify https://mcp.mintlify.com`
  - CLI once: `npm i -g mint`. Use `mint dev` (preview), `mint validate`, `mint broken-links`.

## How the handbook is shaped

Three tabs, three questions:

| Tab | Question it answers | Folder |
|---|---|---|
| Handbook | "How does this part of the business work, and how do I do the task?" | `handbook/` |
| Systems | "What does this one tool own and talk to?" | `systems/` |
| Reference | "What does this word, status, email, job or check mean?" | `reference/` |

The Handbook runs in business order, one chapter per process. Each chapter opens with one explanation page, then short how-to pages. Do not add a fourth tab or reorder the chapters without the owner.

## Page kinds

Every page declares `kind:` in its front matter and is exactly one of these. Never mix them on one page.

| kind | Job | Title shape | Required sections |
|---|---|---|---|
| `explanation` | how something works and why | "How booking works" (never "How to") | `## Related` |
| `how-to` | do one task | starts with a verb: "Book a work order" | `## Before you start`, `## How you know it worked`, `## Related` |
| `reference` | facts to look up, in tables | a plain noun: "Statuses" | `## Related` |
| `hub` | a landing page of cards | | none |

Copy the matching file from `templates/` to start.

A topic that is real but not written yet gets a stub, so the gap shows in the menu instead of being forgotten. A stub is front matter with `stub: true` and `tag: "Stub"`, then the `NotWrittenYet` warning from `snippets/not-written-yet.mdx`, and nothing else. It is listed in `docs.json` like any page. The check skips a stub's required sections and fails a stub that carries any other content: the moment you write it, drop `stub: true`. A stub is never a place for notes; a note belongs in the ticket.

## Linking

- Every page except a hub ends with `## Related`: at least one link, ideally three, to the neighbouring pages in the other two tabs (the chapter's explanation page, the system pages it touches, the reference tables it leans on).
- A process page carries the systems line near the top: `import { Touches } from "/snippets/touches.mdx";` then `<Touches systems="zoho-crm, supabase-backend" />`. The values are the page slugs under `systems/`, so a wrong one shows up as a broken link.
- Link to a repo, never paste its code. The repo list is `reference/repos-and-links.mdx`.

## Names: the human-name rule

Say what people say. *customer*, not the Zoho module. *work order*, not the table. The check fails any page that contains a code-shaped word: `Names_Like_This`, `schema.table`, or `snake_case`. The one exception is `reference/names.mdx`, which is flagged `raw-names: allowed` and maps every human name to its Zoho and Supabase name. If a new human name is needed, add it there first and use it everywhere else.

Words we use: customer, account, lead, property, equipment (or asset), product, stock material, supplier, purchase order, stocking order, work order, line item, appointment, territory, technician, phone agent, invoice, payment, subscription, checklist, checklist template, timesheet, time off, pay calendar, quote, stock list, task, note, the app, the pay page, the engine (Supabase), the monitor, a check, a condition, a spell, urgent, for review.

## What belongs here

These rules come from Diátaxis, the Google and Microsoft style guides, and the Write the Docs principles, cut down to what matters here.

1. **True now.** Describe how the system behaves today. Never "currently", "now", "new", "soon", "will", "planned", "not yet", "eventually", "as of", "for now". If something does not exist, it is not on a page.
2. **Not a notebook.** No TODOs, backlogs, gap lists, dated observations, test evidence, counts from a run, record ids, ticket or pull-request ids, "as seen on", "how this was checked". Those live in the ticket tracker, the PR and git history. A test that passed changes a page's wording; it never adds a line saying that it passed.
3. **Checked against the code.** A timing, threshold, name, trigger or status is written only after finding the code, config row, cron entry or vendor setting that makes it true. Existing prose is not evidence. The proof goes in the commit message, never on the page.
4. **One home per fact.** Each durable fact lives on exactly one page; other pages link to it.
5. **Worth keeping.** Delete what has no lasting value. "It was already there" is not a reason.

## How it reads

6. **Plain first.** Everyday words, short sentences, one idea each. Get to the point in the first sentence. Read it aloud; if you would not say it, rewrite it.
7. **Same word for the same thing.** The word list above and `reference/names.mdx` are the vocabulary. No synonyms.
8. **Reader's question first.** Every page answers one question a person has. Lead with the answer. Organize around the task or the concept, never around the code's layout.
9. **One kind per page.** Explanation says how and why. How-to gives steps. Reference gives tables. A how-to does not explain; a reference does not instruct; an explanation does not list steps.
10. **"You", present tense, active voice.** "Click **Save**", not "the Save button should be clicked". A table beats a paragraph of facts. Sentence case for headings; add real names to `scripts/proper-nouns.txt`. Task headings start with a verb; concept headings are noun phrases. Bold for things you click or see on screen. Code formatting only for file names, commands and paths. No filler and no machine words; the check fails on `scripts/banned-phrases.txt`.

## A page is done only when

- **Verified.** Every factual claim was matched to the current code, production configuration, or the vendor console.
- **Clean.** No TODO, planned work, gap, dated observation, ticket or PR id, count from a run, record id, or working note is on it. The check catches the mechanical forms; the rest is on you.
- **Stands alone.** A developer new to the project can follow it without asking the author.
- **Placed once.** Its facts are on the page that owns them and not repeated elsewhere; other pages link.
- **Concise and useful.** Nothing a reader would skip. Consistent terms. The reader can act on it or understand something from it, not merely find it true.

## Rules and gates

`scripts/check.sh` is the gate. Run it before every commit, or wire it once with `git config core.hooksPath scripts/githooks`. It fails when:

1. A page has no `title`, `description`, or valid `kind`.
2. A page exists but is not in `docs.json`, or `docs.json` lists a page that does not exist.
3. Template text from the starter kit is still present.
4. Anything that looks like a key, token, or password is in the docs.
5. A page is missing the sections its kind requires, or has no `## Related` link. A stub is exempt, and fails if it carries anything but the stub warning.
6. A code-shaped name appears outside `reference/names.mdx`.
7. A banned phrase appears.
8. A heading is not sentence case.
9. A page carries notebook content: a TODO, a ticket or PR id, a date, a clock time, a record id, a "seen on / tested on / unverified" note, or a test-report heading.
10. `mint validate` or `mint broken-links` reports a problem.

A rule the script cannot check is still a rule: one kind per page, plain language, no secrets, no customer data.

## Content boundaries

- Never put keys, tokens, passwords, or customer data in a page. Point to where they live instead.
- Do not paste code from the project repos. Link to the repo and describe what it does.
- Do not document what does not exist. A stub marks a real topic that is owed a page; it is not a page for something that does not exist, and never says "coming soon".
