# branch-maid

Cleans up your dusty Git branches. Utility that deletes branches that have PRs that have been
merged. Useful for repositories that have squash-and-merge enabled since this prevents `git` from
detecting if the branch has been merged.

## Installing

- Clone the repository and put `branch-maid` on your `PATH`:

  ```
  git clone git@github.com:michael-yx-wu/branch-maid.git
  ln -s "$PWD/branch-maid/branch-maid" /usr/local/bin/branch-maid
  ```

- Install [`gh`](https://cli.github.com)

  On macOS:

  ```
  brew install gh
  gh auth login
  ```

- Set `GH_TOKEN` and `GH_ENTERPRISE_TOKEN` (if necessary)
