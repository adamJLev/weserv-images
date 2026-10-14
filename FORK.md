# Fork notes

This repository is a custom fork of [weserv/images](https://github.com/weserv/images),
maintained by Transient Labs at
[Transient-Labs/weserv-images](https://github.com/Transient-Labs/weserv-images).

The upstream project is the image cache and resize service behind
[images.weserv.nl](https://images.weserv.nl), built as an nginx module on top
of libvips. See [README.md](README.md) and [INSTALL.md](INSTALL.md) for
upstream documentation.

## Branches

| Branch        | Purpose                                                         |
| ------------- | --------------------------------------------------------------- |
| `5.x`         | Our working branch: upstream `5.x` plus our custom changes.     |
| `upstream/*`  | Read-only remote-tracking branches from `weserv/images`.        |

Upstream's active development branch is also `5.x`, so our `5.x` tracks it
directly.

## Custom changes

Keep this list up to date whenever a fork-specific change lands, so it's clear
what differs from upstream and what to watch for during merges.

- _None yet. The fork currently matches upstream `5.x`._

## Remotes setup

After cloning, add the upstream remote once:

```bash
git remote add upstream https://github.com/weserv/images.git
git fetch upstream
```

Verify with `git remote -v`. You should see:

```
origin    https://github.com/Transient-Labs/weserv-images.git
upstream  https://github.com/weserv/images.git
```

## Pulling in upstream changes

We **merge** upstream into our branch instead of rebasing. `5.x` is shared
and pushed, so rewriting its history would break other clones.

1. Start from an up-to-date, clean working branch:

   ```bash
   git checkout 5.x
   git pull origin 5.x
   git status            # should be clean
   ```

2. Fetch upstream and review what's new:

   ```bash
   git fetch upstream
   git log --oneline 5.x..upstream/5.x      # commits we don't have yet
   git diff 5.x...upstream/5.x --stat       # files they touch
   ```

   Read the upstream [CHANGELOG.md](CHANGELOG.md) and release notes for
   anything that affects our custom changes.

3. Merge on a separate branch so the update can be reviewed and tested:

   ```bash
   git checkout -b sync-upstream-$(date +%Y-%m-%d)
   git merge upstream/5.x
   ```

4. Resolve conflicts, if any. Conflicts will usually be in files we've
   customized (see [Custom changes](#custom-changes)). Keep upstream's fix
   and reapply our change on top, rather than discarding either side. Then:

   ```bash
   git add <resolved files>
   git commit             # completes the merge
   ```

5. Build and run the tests (see [INSTALL.md](INSTALL.md) and the `test/`
   directory) to confirm everything still works.

6. Push the branch and open a PR into `5.x` on
   `Transient-Labs/weserv-images`:

   ```bash
   git push -u origin sync-upstream-$(date +%Y-%m-%d)
   ```

   Make sure the PR targets **our** repo, not `weserv/images`. GitHub
   defaults the base repository of a fork's PR to upstream.

### Syncing to a specific upstream release

To take a tagged release instead of the tip of `5.x`:

```bash
git fetch upstream --tags
git merge v5.1.1          # replace with the desired tag
```

### If upstream starts a new major branch

Upstream cuts a new branch per major version (`3.x`, `4.x`, `5.x`, ...).
When a `6.x` appears, don't merge it into `5.x` blindly. Create a new
`6.x` branch from `upstream/6.x`, port our custom changes onto it, and test
it before switching deployments over.

## Contributing back

If a change isn't specific to us (a bug fix, for example), consider
opening a PR against [weserv/images](https://github.com/weserv/images) as
well. The fewer custom changes we carry, the easier upstream syncs are.
