# dredge

Where do you keep your ChatGPT prompts? Your movie watchlist? The SSH key for that one server? Your AWS keys? That email you always copy-paste?

Probably 6 different places. Dredge is one place.

---

Dredge is a personal encrypted knowledge base for the terminal. Store anything — secrets, files, notes, prompts, lists — search it instantly, access it from any machine.

Not a password manager. Not a notes app. Both, and more.

```bash
dredge search movies
dredge search aws
dredge search "system prompt"
```

## What people store in dredge

- API keys and credentials
- SSH keys and configs (live-synced to `~/.ssh/`)
- AI prompts
- Dotfiles and config files
- Passwords
- Email templates
- Book and movie lists
- Scripts and snippets
- Anything you find yourself looking for twice

## How it works

Everything is encrypted with AES-256-GCM and stored in a private git repository. One password per terminal session. Search from anywhere in under a second.

```bash
# Add anything
dredge add "OpenAI Key" -c "sk-..." -t keys api
dredge add "Watchlist" -c "Dune 2, Oppenheimer..." -t lists
dredge add "Master Architect Prompt" --import prompt.md -t ai prompts

# Search
dredge search prompt          # finds it
dredge search watch           # finds your watchlist
dredge search aws key         # finds the right key

# Link system files — live encrypted sync
dredge link xKP ~/.ssh/config
dredge link abc ~/.gitconfig

# New machine setup
git clone git@github.com:you/vault.git ~/.local/share/dredge
# done — everything is there
```

## The link command

The most powerful feature. Link any stored item to a system path:

```bash
dredge link <id> ~/.ssh/config
```

This creates a symlink at `~/.ssh/config` pointing to a plain-text copy that dredge manages. Edit it directly or via `dredge edit` — changes sync both ways. The encrypted version stays in git. On a new machine, one link command restores it.

No more "where's my SSH config" or manually copying dotfiles between machines.

## Security

- Argon2id key derivation + AES-256-GCM encryption
- Password prompted once per terminal session, cached in `/tmp`
- Nothing decrypted to disk (except intentionally linked files)
- Private git repo — you own the storage
- No cloud service, no account, no telemetry

## Install

```bash
git clone https://github.com/DeprecatedLuar/dredge
cd dredge
go build -o dredge ./cmd/dredge
mv dredge /usr/local/bin/
```

Requires Go 1.21+. For git sync, requires [gh CLI](https://cli.github.com/) authenticated.

## Quick start

```bash
# Initialize vault with a GitHub repo
dredge init yourusername/vault

# Add your first item
dredge add "My first secret" -c "super secret value" -t test

# Search for it
dredge search secret

# Push to git
dredge push
```

## Commands

```
add / a / new / +      Add an item (opens editor if no -c flag)
search / s             Search items
list / ls              List all items
view / v               View an item
edit / e               Edit an item
rm                     Remove (goes to trash)
undo                   Restore last removed item
link / ln              Link item to system path
unlink                 Remove link
mv / rename            Rename item ID
export                 Export file item to filesystem
push / pull / sync     Git sync
status                 Show pending changes
passwd                 Change vault password
```

---

Your context travels with you. Encrypted.
