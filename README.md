> This is NOT a password manager. NOT a notes app. And definetely NOT a deep-sea benthic abberant specimen taxonomic provenance registry. But it does the first two better than either. Just kidding (not really).

<div align="center">
<img src="other/assets/dredge-doge-vs-cheems-banner.webp" alt="dredge-doge-vs-cheems"/>

<div align="center">

[Install](#install) • [Quick Start](#quick-start) • [Features](#the-cool-features-youve-never-seen-before) • [The Link Command](#the-link-command) • [Commands](#all-commands) • [How It Works](#how-it-works) • [Security](#security) • [Why](#why)

</div>

</div>

<div align="center">

Search, don't organize. **_Notes, configs, keys, secrets_** — five seconds from your terminal.

</div>

<div align="center">
  <a href="https://github.com/DeprecatedLuar/dredge/stargazers">
    <img src="https://img.shields.io/github/stars/DeprecatedLuar/dredge?style=for-the-badge&logo=github&color=1f6feb&logoColor=white&labelColor=black"/>
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/DeprecatedLuar/dredge?style=for-the-badge&color=green&labelColor=black"/>
  </a>
  <a href="https://github.com/DeprecatedLuar/dredge/releases">
    <img src="https://img.shields.io/github/v/release/DeprecatedLuar/dredge?style=for-the-badge&color=orange&labelColor=black"/>
  </a>
</div>


---

> *"Do not bother me with common clutter."* — The Fishmonger

<div align="center">
<!-- demo gif -->
<img src="other/assets/demo.gif" alt="dredge demo" width="800"/>
</div>

```bash
go install github.com/DeprecatedLuar/dredge/cmd/dredge@latest
```

<div align="right">

[other install options ↓](#install)

</div>

---

<h2><img height="44" src="other/assets/fish/dredge-blackmouth.webp"/> The cool features you've never seen before</h2>

- **Encrypted storage** — Clone the repo and get absolute cryptic gibberish. Useless without your password. (AES-256-GCM + Argon2id)
- **Instant search** — fuzzy, typo-tolerant. Type what you remember, not what you saved.
- **Store anything** — notes, scripts, dotfiles, images, zip archives. If it's a file, it goes in.
- **Live file linking** — symlink any item to a system path. Edit directly or through dredge — changes sync both ways.
- **Git-backed** — private repo you own. `git clone` it anywhere and you have everything.
- **Session password** — one prompt per terminal session. After that, it stays out of your way.
- **Trash + undo** — deleted items go to trash. So `dredge undo` brings them back.

---

<h2><img height="32" src="other/assets/fish/dredge-squid-firefly.webp"/> What to store in dredge?</h2>

Dredge doesn't judge. API keys shown only once, SSH configs, AI prompts, passwords, scripts you keep rewriting, email templates you always retype, dotfiles, zip archives, movie lists, anything you've Googled more than once.

Even a _legal_ copy of Chainsaw Man chapter 2 in Japanese.

---

<h2><img height="32" src="other/assets/fish/dredge-crab.webp"/> Install</h2>

**If you have Go:**

```bash
go install github.com/DeprecatedLuar/dredge/cmd/dredge@latest
```

Make sure `$GOPATH/bin` (usually `~/go/bin`) is in your `PATH`.

<details>
<summary>No Go? Use the install script</summary>

<br>

Downloads a pre-built binary — no Go required. The script delegates to [the-satellite](https://github.com/DeprecatedLuar/the-satellite), a reusable installer library I use across projects for OS/arch detection and binary downloads.

```bash
curl -sSL https://raw.githubusercontent.com/DeprecatedLuar/dredge/main/install.sh | bash
```

</details>

<details>
<summary>Build from source</summary>

<br>

```bash
git clone https://github.com/DeprecatedLuar/dredge
cd dredge
go build -o dredge ./cmd/dredge
mv dredge ~/.local/bin/
```

</details>


---

<h2><img height="32" src="other/assets/fish/dredge-perch.webp"/> Quick start</h2>

```bash
# Initialize with an existing git remote
dredge init yourusername/vault   # GitHub shorthand
# or: dredge init git@gitlab.com:you/vault.git

# Add your first item
dredge add "OpenAI Key" -c "sk-..." -t keys api #opens the editor without -c flag

# Search for it
dredge search openai

# Push to git
dredge push
```

<details>
<summary>Usage</summary>

<br>

```bash
# Add anything
dredge add My SSH Config -t ssh dotfiles --import ~/.ssh/config
dredge add "Master Architect Prompt" --import prompt.md -t ai prompts
dredge add "Watchlist" -c "Dune 2, Oppenheimer..." -t lists
dredge add "project-backup" --import project.tar.gz   # binary files too :D

# Search — just type whatever you remember
dredge search prompt
dredge search aws key
dredge search ssh

# View, edit, remove
dredge view <id>
dredge edit <id>
dredge rm <id>
dredge undo          # brought it back

# Search results are numbered — just type the number to view
dredge search ssh    # shows: 1. [xKP] SSH Config  2. [mNq] SSH Key
dredge 1             # views it directly

# Git sync
dredge push
dredge pull
dredge sync          # pull + push
```
</details>

---

<h2><img height="32" src="other/assets/fish/dredge-octopus-glowing.webp"/> How it works</h2>

> *"I can't imagine what's down there in the deep."* — The Lighthouse Keeper

Okay so to summarize:

I settled on using two main crypto technologies Argon2id and of course AES-256 more specifically the GCM variant. 

Argon2id because it is THE reccomendation from RFC 9106 and the 2015 PHC winner. That's it
The GCM variant of AES because it makes all encrypted data impossible to tamper with due to fingerprinting. That's it too

For now I'm storing everything as encrypted files in `~/.local/share/dredge/`. That directory is also a git repository (at leat for now). So `dredge push` commits and pushes everything for backup stuff. Each item is a standalone encrypted blob with a random 3-character ID. I decided that no filenames should be exposed so even if someone can see your stuff they have no idea what thy are looking at.

### The encryption pipeline

```
Your password
  + 16-byte random salt  ← the salt is stored in .dredge-key
  → Argon2id (64 MB memory · 4 threads · 1 iteration)
  → 32-byte master key (salt + password = the real key)

Master key + item content (TOML: title, tags, content)
  → AES-256-GCM with a fresh random 12-byte nonce per operation
  → [12B nonce][ciphertext + 16B auth tag]
  → written to disk as items/xKP  (random ID, no extension)
```

So your entire vault shares the same derived key (this means if you lose your key you lose your data, please don't lose your key). Every item uses the same key, each with its own random nonce. If you encrypt the same content twice produces completely different ciphertext basically.

### What lives where

```
~/.local/share/dredge/          ← the vault (git repo)
├── .git/
├── .gitignore                  ← excludes .spawned/ and links.json
├── .dredge-key                 ← salt + encrypted verification string  
├── items/
│   ├── xKP                     ← encrypted item                       
│   ├── mNq                     ← encrypted item                
│   └── ...
├── .spawned/                   ← plaintext copies of linked items   
└── links.json                  ← symlink manifest
```

So all your encrypted files and `.dredge-key` are stored on the git repo, all the plain text files (the one you decided to make readable by the system) will never be tracked. so do whatever you want wit it. 

### Session model

After your first command in a terminal, the derived 32-byte key is cached at `$XDG_RUNTIME_DIR/dredge/$PPID/.key` (root access only)

All the following dredge commands in the SAME terminal use the cached key. Which means you won't be password prompted anymore. Each terminal gets its own isolated directory based on the parent PID. So the key is evaporated from disk once the teminal dies.

<details>
<summary>Deeper technical details</summary>

<br>

**Key derivation — Argon2id:** RFC 9106 recommended parameters (64 MB memory, 4 threads, 1 iteration). The salt in `.dredge-key` is not supposed to be a secret it just ensures brute-forcing your password is _very_ expensive even with the file. Your password is what keeps you safe so you know what to do.

**Cipher — AES-256-GCM:** Basically fingerprints every encryption. You get both confidentiality and integrity. Tampering ciphertext won't decrypt to garbage, decryption will fail and scream for help.

**Password verification:** `.dredge-key` contains the string `dredge-vault-v1` encrypted with your master key. On each new session, dredge decrypts this to verify if the password is correct. So if you dont get `dredge-vault-v1` out of it the password is wrong, so it fails in ~100ms rather than discovering a wrong password mid-operation.

**What's cached:** The session file stores the derived 32-byte key (password + salt), not the password itself (I'm not that stupid). So even if someone reads `.key` during an active session, they cannot recover your password from it.

</details>

---

<h2><img height="56" src="other/assets/fish/dredge-shark-whaler.webp"/> Security</h2>

> *"Better to come back with a small catch than to not come back at all."* — The Fishmonger

### Threat model (I made this section with AI but its right)

**Someone clones your private git repo:**
They get encrypted blobs and `.dredge-key`. The salt is not secret — its purpose is to make precomputation attacks impractical. Without your password, the items are opaque binary data. Argon2id makes offline brute-force expensive. Use a strong password.

**Someone has access to your running session:**
The derived key lives in `$XDG_RUNTIME_DIR/dredge/$PPID/.key` for the duration of that terminal session. Each terminal gets its own isolated directory — close the terminal, the key is gone. That path is user-scoped (mode 700) and RAM-backed. An attacker with read access to your session directory can decrypt your vault. Treat it like any sensitive credential in your home directory. If someone has root on your machine, your dredge key is the least of your concerns.

**Someone has physical access to your offline machine:**
Items on disk are encrypted. The session key is in RAM-backed storage and does not survive a reboot. Linked items (`.spawned/`) are plaintext on disk — see below.

### Where plaintext exists

| Location | When | Lifetime |
|----------|------|---------|
| RAM only | Every view, search, or edit | Freed when command exits |
| `$XDG_RUNTIME_DIR/dredge/$PPID/edit-*.txt` | During `dredge edit` only | Deleted after editor closes |
| `~/.local/share/dredge/.spawned/<id>` | After `dredge link` | Until you run `dredge unlink` |

The spawned file is the only persistent plaintext on disk, and it only exists because you explicitly linked an item to a system path. Everything else is in-memory only.

### Caveats

- **`--password` flag:** Passing your password inline exposes it in shell history and `ps` output. Avoid it in shared environments.
- **Linked items:** A linked item's plaintext lives at the symlink target (e.g. `~/.ssh/config`). It is not git-tracked, but it is on disk in plaintext.

<div align="center">
<img src="other/assets/fish/dredge-eel.webp" width="700"/>
</div>

<h2><img height="32" src="other/assets/fish/dredge-squid.webp"/> The link command</h2>

Link any stored item to a path on your filesystem:

```bash
dredge link <id> ~/.ssh/config
```

Creates a symlink at `~/.ssh/config` pointing to a plain-text copy dredge manages. Edit the file directly or through `dredge edit` — changes sync back to the encrypted store automatically.

On a new machine:

```bash
git clone git@github.com:you/vault.git ~/.local/share/dredge
dredge link <id> ~/.ssh/config
# done — same SSH config, same keys, every machine
```

This is the reason I built dredge. My SSH config is identical on every machine, encrypted in git, and I never think about it.

---

<h2><img height="32" src="other/assets/fish/dredge-mackerel.webp"/> All commands</h2>

<div align="left">

| Command | Description | Example |
|:--------|:------------|:--------|
| `add` / `a` / `new` / `+` | Add an item (opens editor if no -c flag) | `dredge add "OpenAI Key" -c "sk-..." -t keys` |
| `search` / `s` | Search items | `dredge search aws key` |
| `list` / `ls` | List all items | `dredge ls` |
| `view` / `v` | View an item | `dredge view xKP` or `dredge 1` |
| `edit` / `e` | Edit an item | `dredge edit xKP` |
| `rm` | Remove (goes to trash) | `dredge rm 1 2 3` |
| `undo` | Restore last removed item | `dredge undo` |
| `link` / `ln` | Link item to a system path | `dredge link xKP ~/.ssh/config` |
| `unlink` | Remove a link | `dredge unlink xKP` |
| `mv` / `rename` | Rename item ID | `dredge mv xKP abc` |
| `export` | Export a file item to disk | `dredge export xKP ./output/` |
| `init` | Initialize git repository | `dredge init owner/repo` |
| `push` / `pull` / `sync` | Git sync | `dredge sync` |
| `status` | Show pending changes | `dredge status` |
| `passwd` | Change vault password | `dredge passwd` |
| `update` | Update to latest version | `dredge update` |

</div>

### Git sync

Git sync uses plain `git` and works with any remote (GitHub/GitLab/Gitea/etc).

`dredge init` accepts an optional git remote. If you omit it, dredge initializes a local-only git repo (no remote).

Accepted remote formats:

```bash
# GitHub shorthand (expanded to https://github.com/<owner>/<repo>.git)
dredge init owner/repo

# HTTPS
dredge init https://github.com/owner/repo.git
dredge init https://gitlab.com/group/repo.git

# SSH (scp-like)
dredge init git@github.com:owner/repo.git
dredge init git@gitlab.com:group/repo.git

# SSH URL
dredge init ssh://git@github.com/owner/repo.git

# Local path remote (advanced)
dredge init /srv/git/dredge-vault.git
```

- Dredge does not create remote repositories for you.
- If `origin` is not configured, `dredge push`/`pull`/`sync` will error with guidance.
- If you already have a git remote set, `dredge init` will not overwrite it.

---

<h2><img height="32" src="other/assets/fish/dredge-jellyfish-aurora.webp"/> Why</h2>

> *"I am a collector — of many things; art and artifacts, treasures and truths... and curios that occupy the periphery of desire."* — The Collector

The mental overhead of saving something and not knowing where to find it when you need it.

I got tired of having important things scattered everywhere — password manager for passwords, note app for notes, a separate dotfiles repo, a `notes.txt` on the desktop. Every tool does one thing and you end up managing the tools instead of the information.

I wanted something that just works. No organization to maintain, no fragmentation. Dump it in, find it when you need it, done.

[jrnl](https://jrnl.sh) pointed me in the right direction but wasn't very QoL leaning — it literally had no item separation and a search that matched *everything*. Dredge is what I actually wanted. (so yeah, pretty much a personal tool)

<div align="center">
<img src="other/assets/fish/dredge-eel-sprouting.webp" width="600"/>
</div>

---

<h2><img height="32" src="other/assets/fish/dredge-squid-radiant.webp"/> Contributors</h2>

Big thanks to you guys who contributed to dredge:

<table>
<tr>
  <td align="center">
    <a href="https://github.com/timcondit"><img src="https://github.com/timcondit.png" width="48" /><br/>timcondit</a>
  </td>
  <td align="center">
    <a href="https://github.com/wlad031"><img src="https://github.com/wlad031.png" width="48" /><br/>wlad031</a>
  </td>
</tr>
</table>
