# CLAUDE.md

How to work in this docs repo. Read it before editing anything.

## Who this is for

- The owner and the developers who run the business's projects. Not a public audience.
- The real reader is the owner in three months, who has forgotten half of this. Write for that person.
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
| Reference | "What does this word, status, email, job or alert mean?" | `reference/` |

The Handbook runs in business order, one chapter per process, matching the milestones of the Linear project *Walk the whole business*. Each chapter opens with one explanation page, then short how-to pages. Do not add a fourth tab or reorder the chapters without the owner.

## Page kinds

Every page declares `kind:` in its front matter and is exactly one of these. Never mix them on one page.

| kind | Job | Title shape | Required sections |
|---|---|---|---|
| `explanation` | how something works and why | "How booking works" (never "How to") | `## Related` |
| `how-to` | do one task | starts with a verb: "Book a work order" | `## Before you start`, `## How you know it worked`, `## Related` |
| `reference` | facts to look up, in tables | a plain noun: "Statuses" | `## Related` |
| `hub` | a landing page of cards | | none |

Copy the matching file from `templates/` to start. A page that is not finished keeps `tag: "TODO"` in its front matter; that shows a badge in the menu and tells the check to skip the section rules. Delete the tag when the page is real.

## Linking

- Every page except a hub ends with `## Related`: at least one link, ideally three, to the neighbouring pages in the other two tabs (the chapter's explanation page, the system pages it touches, the reference tables it leans on).
- A process page carries the systems line near the top: `import { Touches } from "/snippets/touches.mdx";` then `<Touches systems="zoho-crm, supabase-backend" />`. The values are the page slugs under `systems/`, so a wrong one shows up as a broken link.
- Link to a Linear issue with `<Linear issue="COM-12" />` from `/snippets/linear.mdx`.
- Link to a repo, never paste its code. The repo list is `reference/repos-and-links.mdx`.

## Names: the human-name rule

Say what people say. *customer*, not the Zoho module. *work order*, not the table. The check fails any page that contains a code-shaped word: `Names_Like_This`, `schema.table`, or `snake_case`. The one exception is `reference/names.mdx`, which is flagged `raw-names: allowed` and maps every human name to its Zoho and Supabase name. If a new human name is needed, add it there first and use it everywhere else.

Words we use: customer, account, lead, property, equipment (or asset), product, stock material, supplier, purchase order, stocking order, work order, line item, appointment, territory, technician, phone agent, invoice, payment, subscription, checklist, checklist template, timesheet, time off, pay calendar, quote, stock list, task, note, the app, the pay page, the engine (Supabase).

## Writing rules

These come from the Google and Microsoft style guides and from Diátaxis, cut down to what matters here.

- Get to the point in the first sentence. The rest of the page supports it.
- Write like you talk. Read it aloud; if you would not say it, rewrite it.
- "You", present tense, active voice. "Click **Save**", not "the Save button should be clicked".
- One idea per sentence. Short paragraphs. A table beats a paragraph of facts.
- Sentence case for headings. The check enforces this; add real names to `scripts/proper-nouns.txt`.
- Task headings start with a verb ("Book a work order"); concept headings are noun phrases ("The billing decision").
- Bold for things you click or see on screen: **Complete**, **Actions**.
- Code formatting only for file names, commands and paths.
- No filler and no machine words. The check fails on the list in `scripts/banned-phrases.txt`; add to it when you catch a new one.
- Say what is known and what is not. "Unverified" is a fine word.
- A page written for a test that passed says what was observed, not what the code intends.

## When a page gets written

A handbook page is part of the definition of done for its Linear test. The deep test plan (`~/Downloads/Documents/business-flow-test-plan.md`, section "When to update the handbook") lists which pages belong to which milestone. When an issue passes, write or update its page, commit, and only then move the issue to Done with a one-line comment naming the page. Docs and Linear move together in one sitting. A page nobody has tested against stays tagged TODO.

## Rules and gates

`scripts/check.sh` is the gate. Run it before every commit, or wire it once with `git config core.hooksPath scripts/githooks`. It fails when:

1. A page has no `title`, `description`, or valid `kind`.
2. A page exists but is not in `docs.json`, or `docs.json` lists a page that does not exist.
3. Template text from the starter kit is still present.
4. Anything that looks like a key, token, or password is in the docs.
5. A finished page is missing the sections its kind requires, or has no `## Related` link.
6. A code-shaped name appears outside `reference/names.mdx`.
7. A banned phrase appears.
8. A heading is not sentence case.
9. `mint validate` or `mint broken-links` reports a problem.

A rule the script cannot check is still a rule: one kind per page, plain language, no secrets, no customer data.

## Content boundaries

- Never put keys, tokens, passwords, or customer data in a page. Point to where they live instead.
- Do not paste code from the project repos. Link to the repo and describe what it does.
- Do not document what does not exist yet as if it did. A gap is a gap; say so and link the Linear issue.
