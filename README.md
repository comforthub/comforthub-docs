# Comfort Hub handbook

The handbook for how the business runs and the systems that run it. Built on [Mintlify](https://mintlify.com). Pages are `.mdx` files, the menu is `docs.json`, blank pages to copy are in `templates/`, and the rules for writing here are in `CLAUDE.md`. A page tagged TODO in the menu is not written yet; it names the Linear test that unlocks it.

## Preview locally

```bash
npm i -g mint
mint dev
```

Open `http://localhost:3000`.

## Check before you commit

```bash
bash scripts/check.sh
```

Wire it to every commit, once per clone:

```bash
git config core.hooksPath scripts/githooks
```

## Publish

Push to `main`. The site deploys on its own.
