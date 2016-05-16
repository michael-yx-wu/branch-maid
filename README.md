# branch maid

Cleans up your dusty Git branches.

## Motivation

This tool is particularly useful for people using Github's commit squashing
feature. See [here](https://github.com/blog/2141-squash-your-commits) for more
information. If you merge pull requests with a merge commit, you could do
something like `git branch --merged develop` and get a list of branches that
merged into the `develop` branch because the commits in your pull request get
merged in wholesale. If you prefer to use the commit squashing feature (e.g. for
cleaner Git history), there's no way for Git to natively detect whether one of
your branches has been merged because Github will actually squash all of the
commits in your pull request and merge them into the base branch via a new
commit. Different projects will have different settings for merging feature
requests. Instead of trying to remember which projects use merge commits and
which ones squash commits, you can just use `branch maid` to clean up branches
that are associated with closed pull requests.

## Getting Started

0.  Go to `Settings > Personal access tokens` and create a Github API token with
    sufficient permissions to access the repositories with which you plan on using
    `branch maid`.
0.  Clone the repository and optionally add `branch-maid.rb` to your `PATH`.

## Usage

Run `branch-maid.rb` in the directory of a git repository to clean up your
merged branches. See below for options.

```
Usage: branch-maid.rb [options]

Required:
    -t, --token TOKEN                Github API token

Optional:
    -g, --github-api URL             Default is https://api.github.com
    -n, --dry-run
    -v, --verbose
```
