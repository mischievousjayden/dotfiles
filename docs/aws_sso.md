# AWS SSO profiles without keys in your shell

Two scripts in `bin/` (on `PATH` via `zshrc`/`bashrc`):

| Command | Does |
| --- | --- |
| `aws-sso-profiles` | creates `~/.aws/config` profiles for the SSO accounts/roles you can access, and (optionally) a shell file with one alias per profile |
| `aws-sso <profile>` | makes sure the SSO session behind `<profile>` works, logging in only when needed, and prints when it expires |

Switching accounts exports **only `AWS_PROFILE`**. Access keys are never
printed, never written by these scripts, and never put in the environment —
the AWS CLI/SDKs resolve them per call from their own caches. So anything you
start from that shell (including AI coding agents) does not inherit keys.

Requires `aws` CLI v2 and `jq`.

## First-time setup

1. **Register the SSO session** (values come from your org's AWS access portal):

   ```sh
   aws configure sso-session
   #   SSO session name:         <session>        e.g. mycorp
   #   SSO start URL:            https://<portal>.awsapps.com/start
   #   SSO region:               <sso-region>     region of the portal, e.g. us-east-1
   #   SSO registration scopes:  sso:account:access
   ```

2. **Optional machine-local defaults** — put these in a file that is *not* in
   this repo (e.g. `~/.custom_zshrc/<name>`):

   ```sh
   export AWS_SSO_SESSION=<session>
   export AWS_SSO_PREFIX=<prefix>               # profile names: <prefix>-<account>-<role>
   export AWS_SSO_PROFILE_REGION=<region>       # region written into new profiles
   export AWS_SSO_ALIAS_FILE=~/.custom_zshrc/aws-sso-aliases
   ```

   Without `AWS_SSO_ALIAS_FILE` (or `-A`) no alias file is written. If you put
   it somewhere `zshrc` does not source automatically, add
   `[ -f <file> ] && source <file>` to your rc.

3. **Create profiles and aliases**:

   ```sh
   aws-sso-profiles -n                       # dry run: see the menu, empty input cancels
   aws-sso-profiles                          # pick from the menu, e.g. "1 3 5-7" or "all"
   aws-sso-profiles -a -r AdministratorAccess   # every account, one role, no prompt
   exec zsh                                  # load the new aliases
   ```

   Existing profiles are skipped unless you pass `-f`. The alias file is rebuilt
   from every SSO profile in the config on each run, so it always matches.

## Daily use

```sh
aws-credentials-<profile>      # = aws_use <profile>: log in if needed, export AWS_PROFILE
aws sts get-caller-identity
aws-sso <profile>              # just check status / expiry
aws-sso -f <profile>           # force a fresh login
```

Example status line (stderr; stdout stays empty):

```
mycorp-dev-admin: role creds until 14:15 (in 1h00m), SSO token until 13:15 (in 0h59m), auto-refreshes
```

`auto-refreshes` means a refresh token is cached, so the CLI renews the access
token silently; the browser only opens when the SSO session itself ends.

## Options and defaults

Each value is taken from the flag, else the env var, else the fallback.
Nothing site-specific is built in.

| `aws-sso-profiles` | Flag | Env var | Fallback |
| --- | --- | --- | --- |
| sso-session | `-s` | `AWS_SSO_SESSION` | the only `[sso-session]` in the config (error if several) |
| profile prefix | `-p` (`''` = none) | `AWS_SSO_PREFIX` | the session name |
| profile region | `-g` | `AWS_SSO_PROFILE_REGION` | `[default]` region, else the `sso_region` |
| alias file | `-A` | `AWS_SSO_ALIAS_FILE` | none — not written |
| role filter | `-r` | | all roles |
| output format | `-o` | | `json` |

Other flags: `-a` all accounts, `-n` dry run, `-f` overwrite existing profiles.
Accounts can also be given as arguments (name, slug or 12-digit id).

Override one profile's region afterwards with
`aws configure set region <region> --profile <profile>`.

## Where credentials live

These scripts store nothing. The AWS CLI keeps its own caches, all mode `600`:

| Path | Holds | Lifetime |
| --- | --- | --- |
| `~/.aws/sso/cache/<sha1>.json` | SSO access + refresh token | access ~1h, refreshed until the SSO session ends |
| `~/.aws/sso/cache/<sha1>.json` | OIDC client registration (no token) | ~90 days |
| `~/.aws/cli/cache/<hash>.json` | role temporary keys (CLI only; SDKs keep them in memory) | the permission set's session duration |

Any process running as your user can still read these files — this setup
stops *accidental* exposure (env vars, terminal output, world-readable files),
it is not a security boundary.

## When a tool really needs raw keys

```sh
# print them (your own terminal only — not through an agent)
aws configure export-credentials --format env

# hand them to one command only; they vanish when it exits
( eval "$(aws configure export-credentials --format env)"; some-tool ... )

# docker: via env-file, nothing written to disk
docker run --rm --env-file <(aws configure export-credentials --format env-no-export) <image> ...

# docker: or mount ~/.aws (read-write: the token cache gets refreshed)
docker run --rm -v ~/.aws:/root/.aws -e AWS_PROFILE <image> ...
```

Uses `AWS_PROFILE`; pass `--profile <profile>` for another one. Most tools
(Terraform, boto3, EKS auth for kubectl) understand SSO profiles directly, so
`AWS_PROFILE` alone is usually enough.

## What belongs where

| In this repo (public) | Machine-local, never committed |
| --- | --- |
| `bin/aws-sso`, `bin/aws-sso-profiles` | `AWS_SSO_*` env vars (org-specific) |
| this doc | the generated alias file (holds an absolute path; regenerate per machine) |
| | `~/.aws/config`, `~/.aws/credentials` |

## Starting over

```sh
B=~/aws-reset-backup-$(date +%Y%m%d-%H%M); mkdir -p "$B"
cp ~/.aws/config "$B"/                       # keep the backup OUTSIDE ~/.custom_zshrc
aws sso logout                               # revoke tokens; run before editing the config
rm -rf ~/.aws/sso/cache ~/.aws/cli/cache
# drop [sso-session ...] blocks and generated profiles (here: names starting <prefix>-)
awk -v p="<prefix>-" '/^\[/{skip = ($0 ~ /^\[sso-session / || index($0, "[profile " p) == 1)} !skip' \
  "$B"/config > ~/.aws/config
rm -f "$AWS_SSO_ALIAS_FILE"
exec zsh
```

Then follow [First-time setup](#first-time-setup). To roll back:
`cp "$B"/config ~/.aws/config`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `no profile '<x>' in ~/.aws/config` | run `aws-sso-profiles`, or check the name with `aws configure list-profiles` |
| `several sso-sessions, pick one` | pass `-s` or set `AWS_SSO_SESSION` |
| `aws-credentials-*: command not found` | alias file not written (`-A` / `AWS_SSO_ALIAS_FILE`) or not sourced; `exec zsh` |
| `aws_use: no such file or directory: .../aws-sso` | the repo moved; re-run `aws-sso-profiles` to regenerate the alias file |
| `warning: no account matched '<name>'` | the portal's account name slugs differently; use the 12-digit id or the menu |
| account missing from the menu | no permission set is assigned to you for it in IAM Identity Center |
