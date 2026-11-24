# Sharing Homebrew Across Multiple macOS Users

A walkthrough for setting up one dedicated Homebrew account that owns the install, with other users running `brew` through `sudo`. All names below are examples; substitute your own.

| Role | Example name |
|---|---|
| Dedicated Homebrew owner (standard user) | `brewadmin` |
| Your regular admin account | `adminuser` |
| Other users who need `brew` | `alice`, `bob` |
| Group allowed to use brew | `brewusers` |

Assumes Apple Silicon, where Homebrew lives in `/opt/homebrew`.

## How it works

- `brewadmin` owns `/opt/homebrew` and is the only account that ever writes to it.
- Members of the `brewusers` group run `brew` as `brewadmin` via `sudo -u`.
- A sudoers rule allows exactly one command (`/opt/homebrew/bin/brew`) and nothing broader.

This keeps permissions clean. Several users writing to the same Homebrew tree can break each other's installs, and Git may complain about "dubious ownership" in a shared-write setup.

## Step 1: Remove admin rights from the Homebrew owner

Do this from your regular admin account.

1. Log in to your regular administrator account.
2. Open **System Settings → Users & Groups**.
3. Select `brewadmin`.
4. Turn off **Allow this user to administer this computer**.
5. Authenticate if macOS asks.

**Before you do this, make sure your regular account is still an administrator.** You need an admin account to edit sudoers later.

Do not change the ownership or permissions of `/opt/homebrew`. Leave it owned by `brewadmin`.

## Step 2: Verify Homebrew still works

Log in as `brewadmin` and run:

```bash
brew --version
brew doctor
```

Expected: a version number and `Your system is ready to brew.`

**Caveat:** with `brewadmin` as a standard user, formulae work, but some casks (anything needing `sudo` or system-level install locations) will fail. If that happens, temporarily re-enable admin for `brewadmin`, install the cask, then turn admin back off.

## Step 3: Confirm your admin account is still an admin

From the regular admin account:

```bash
groups | tr ' ' '\n' | grep -x admin
```

It should print `admin`. If it prints nothing, stop and re-enable admin before continuing.

## Step 4: Create the group and add users

Replace `alice` and `bob` with real usernames. List existing local users with:

```bash
dscl . list /Users | grep -v '^_'
```

Then:

```bash
sudo dseditgroup -o create brewusers
sudo dseditgroup -o edit -a alice -t user brewusers
sudo dseditgroup -o edit -a bob -t user brewusers
dseditgroup -o read brewusers
```

The last command should list your users under `GroupMembership`.

Notes:
- `Record was not found.` means the username you passed doesn't exist. Check the spelling.
- `Create called on existing record - do you want to overwrite` means the group already exists. Answering `y` is safe if the group is empty.

### Renaming the group later

```bash
sudo dscl . -change /Groups/brewusers RecordName brewusers newname
```

If that errors, delete and recreate it:

```bash
sudo dseditgroup -o delete brewusers
sudo dseditgroup -o create newname
```

then re-add the members. **Update the sudoers rule in Step 5 to use the new name**, otherwise it matches nothing.

## Step 5: Add the sudoers rule

The safest method is to write the file directly and then validate it:

```bash
sudo sh -c 'echo "%brewusers ALL=(brewadmin) NOPASSWD: /opt/homebrew/bin/brew" > /etc/sudoers.d/homebrew'
sudo chown root:wheel /etc/sudoers.d/homebrew
sudo chmod 440 /etc/sudoers.d/homebrew
sudo visudo -cf /etc/sudoers.d/homebrew
```

You want `parsed OK`.

### If you prefer the editor

```bash
sudo visudo -f /etc/sudoers.d/homebrew
```

In `vi`, press `i` to insert, type only the rule line, press `Esc`, then type `:wq`.

### Common mistake: pasting the command into the file

If you see an error like this:

```
/etc/sudoers.d/homebrew:1:13: syntax error
sudo visudo -f /etc/sudoers.d/homebrew
            ^~
What now?
```

the file contains the command text instead of the rule. At the `What now?` prompt:

- Type `x` and press Enter to exit **without saving**.
- Do **not** choose `Q`, which saves the broken file anyway.
- Rewrite the file using the direct-write commands above.

A sudoers syntax error can break `sudo` entirely, so confirm `sudo -v` still works from your admin account afterward.

## Step 6: Verify the sudoers setup

```bash
ls -l /etc/sudoers.d/
sudo cat /etc/sudoers.d/homebrew
sudo grep includedir /etc/sudoers
sudo -l -U alice
```

Expected:

- File permissions `-r--r-----`, owned by `root wheel`, containing only the single `%brewusers ...` line.
- No stray `homebrew.tmp` file. (If one exists, sudo ignores it, but you can remove it with `sudo rm /etc/sudoers.d/homebrew.tmp`.)
- An `#includedir /private/etc/sudoers.d` line. Despite the `#`, this is a directive, not a comment.
- Under `User alice may run the following commands`: `(brewadmin) NOPASSWD: /opt/homebrew/bin/brew`

## Step 7: Configure each user's shell

Log in as each user (or use `su - alice`) and run:

```bash
cat >> ~/.zshrc <<'EOF'
export PATH="/opt/homebrew/bin:$PATH"
alias brew='sudo -H -u brewadmin /opt/homebrew/bin/brew'
EOF
```

- The `PATH` line lets users run installed tools (like `wget` or `jq`) directly.
- The alias routes `brew` itself through `brewadmin`.

Open a new Terminal window afterward. Group membership is read at login, so a user who was added to the group while logged in should log out and back in.

## Step 8: Test as a standard user

Test as a **non-admin** user. An admin can already run anything via sudo, so a pass there doesn't prove the rule works.

```bash
cd ~
brew --version
brew install hello
hello
brew uninstall hello
```

Success looks like: the bottle downloads and pours into `/opt/homebrew/Cellar`, `hello` prints `Hello, world!`, the uninstall succeeds, and no password is ever requested.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Password prompt, or "not in the sudoers file" | User isn't in the group, or hasn't logged in since being added | Check `dseditgroup -o read brewusers`; log out and back in |
| `command not found: brew` | `~/.zshrc` not loaded | Run `source ~/.zshrc` or open a new window |
| Permission or working-directory errors from brew | Running from a directory `brewadmin` can't access | `cd ~` first |
| Rule has no effect after renaming the group | Sudoers still references the old group name | Update `/etc/sudoers.d/homebrew` |
| A cask fails with a privilege error | `brewadmin` is no longer an admin | Temporarily re-promote `brewadmin`, install, demote again |

## Adding a user later

From an admin account:

```bash
sudo dseditgroup -o edit -a NEWUSER -t user brewusers
```

Then give that user the `~/.zshrc` lines from Step 7.

## Final state

- `/opt/homebrew` is owned by `brewadmin`, a standard (non-admin) user.
- Members of `brewusers` run `brew` through `sudo -u brewadmin`, with no password.
- The sudoers rule permits only `/opt/homebrew/bin/brew`, as `brewadmin`.
