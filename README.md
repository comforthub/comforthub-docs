# Docs

The documentation site for the projects that run the business. Built on [Mintlify](https://mintlify.com). Pages are `.mdx` files, the menu is `docs.json`, and the rules for writing here are in `CLAUDE.md`.

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
