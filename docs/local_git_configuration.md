# Local Git Configuration (Work & Personal)

This guide explains how to **cleanly separate Git identities and SSH keys** for work and personal projects on the same machine.
It prevents common mistakes like committing with the wrong email or pushing to GitHub using the wrong account.

---

## Goals

* Use **different Git names/emails per project**
* Use **separate SSH keys** for work and personal GitHub accounts
* Make the setup **automatic** based on repository location
* Avoid manual switching or environment variables

---

## 1. Per‑project Git identity using `.gitconfig`

Git supports conditional includes, allowing different config files to be loaded depending on the repository path.

### 1.1 Edit your global `~/.gitconfig`

Add the following:

```ini
[includeIf "gitdir:~/work/projects/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/projects/"]
    path = ~/.gitconfig-personal
```

> 💡 **Important**
>
> * The paths **must end with a trailing slash (`/`)**
> * Repositories must live under these directories for the rule to apply

---

### 1.2 Create the included config files

#### `~/.gitconfig-work`

```ini
[user]
    name = Work Name
    email = work@example.com
```

#### `~/.gitconfig-personal`

```ini
[user]
    name = Personal Name
    email = personal@example.com
```

Git will now automatically use the correct identity based on the repository location.

---

### 1.3 Verify Git identity

Inside a repository, run:

```bash
git config user.name
git config user.email
```

This should reflect the correct identity for that project.

---

## 2. SSH keys per GitHub account

Using separate SSH keys ensures GitHub authentication matches the intended account.

---

### 2.1 Generate SSH keys

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal
```

(Optional but recommended) Add passphrases for better security.

---

### 2.2 Update `~/.ssh/config`

```ssh
# Work GitHub
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# Personal GitHub
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

This creates **logical host aliases** that map to different SSH keys.

---

### 2.3 Add SSH keys to GitHub

Copy each public key and add it to the corresponding GitHub account:

```bash
cat ~/.ssh/id_ed25519_work.pub
cat ~/.ssh/id_ed25519_personal.pub
```

GitHub → **Settings → SSH and GPG keys**

---

## 3. Use the correct remote URL

Clone repositories using the matching host alias.

### Work repository

```bash
git clone git@github-work:org/repo.git
```

### Personal repository

```bash
git clone git@github-personal:username/repo.git
```

---

## 4. Validate SSH configuration

Test authentication explicitly:

```bash
ssh -T git@github-work
ssh -T git@github-personal
```

Expected output:

> Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.

---

## 5. Common pitfalls

* ❌ Missing trailing slash in `gitdir:` paths
* ❌ Cloning with `git@github.com:...` instead of the alias
* ❌ Repository not located under the configured directory
* ❌ Forgetting to add SSH keys to GitHub

---

## 6. Summary

| Concern              | Solution                 |
| -------------------- | ------------------------ |
| Wrong commit email   | Conditional `.gitconfig` |
| Wrong GitHub account | SSH host aliases         |
| Manual switching     | Automatic by directory   |

This setup scales cleanly for additional identities (freelance, open‑source, etc.) by adding more `includeIf` rules and SSH hosts.

---

✅ Once configured, everything works automatically — no more accidental cross‑account commits.

