dotfiles-loader
===

dotfiles are how you personalize your system. This is a generalized loader for dotfiles that implements a topic basic
approach (as opposed to a monolithic zshrc), as first described in
[holman/dotfiles](https://github.com/holman/dotfiles).

Other than the original dotfiles repo, dotfiles-loader does not include any user specific dotfiles, only the code to
load dotfiles from a different repo, following the structure/conventions from holman/dotfiles.  
This way code for loading and actual user specific config can be separated.
No need to fork a repo full of config you don't need. Just create a new `dotfile` repo from scratch.
Mine is [schnatterer/dotfiles](https://github.com/schnatterer/dotfiles), for example.

Dotfile-loader also simplifies the process (in my opinion) compared to holman/dotfiles:  
There is no `dot`, no `install`, just one `bootstrap` script that needs to be called.

It also provides some [additional features](#additional-features) like debugging, profiling and simple benchmarking
and compatibility with [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 🎉.

## Contents 

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Try it](#try-it)
- [Install](#install)
- [Additional features](#additional-features)
- [Structure for dotfile repos](#structure-for-dotfile-repos)
  - [topical](#topical)
  - [components](#components)
- [Development](#development)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Try it

You can play around with the loader, no strings attached, using docker.

```shell
docker run --rm -it ghcr.io/schnatterer/dotfiles-loader

# Skip interactive mode, e.g. using my dotfiles repo as an example
docker run --rm -it \
  -e dotfiles_repo=https://github.com/schnatterer/dotfiles \
  -v $(pwd)/git/gitconfig.local.example:/home/dev/.dotfiles-loader/git/gitconfig.local \
  ghcr.io/schnatterer/dotfiles-loader \
  -c 'echo O | .dotfiles-loader/script/bootstrap && zsh'
```

## Install

Prerequisites: `bash`, `zsh`, `git`. And a dotfile repo, preferably your own.

```shell
git clone https://github.com/schnatterer/dotfiles-loader .dotfiles-loader

# This script will interactively lead you through the setup, where you enter the url to your actual 
# dotfile repo.
# The dotfile repo is cloned to ~/.dotfiles. Then symlinks are created making sure the dotfiles
# are initialized on the next shell start.
# Everything is configured and tweaked within `~/.dotfiles`.
~/.dotfiles-loader/script/bootstrap

# Alternative: Try out my dotfiles repo:
dotfiles_repo=https://github.com/schnatterer/dotfiles ~/.dotfiles-loader/script/bootstrap
```

BTW - once installed you can call `bootstrap` again any time. It should be idempotent, just running all `install.sh`s 
from your dotfiles repo again.

## Additional features 

* Compatibility with [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 🎉  
  See [my dotfiles](https://github.com/schnatterer/dotfiles/tree/b013a3/oh-my-zsh) for an example
* Special env vars to improve your dotfiles.
    * `DEBUG` debug output - helps to better understand what happens during startup.
    * `BENCH` - prints loading times of each source file.  
      This helps to quickly identify potentials for speeding up your loading times.
    * `PROFILE` - prints every command with timestamp to a file (path is printed).  
      If you need even more insight in loading times this is for you.  
      See [Kevin Burkes post](https://kevin.burke.dev/kevin/profiling-zsh-startup-time/) on how to process the result and
      find the culprits that slow down your shell startup.
    * `TRACE` - prints every command during startup to stdout (`set -x`)

Use them like so, for example

```shell
BENCH=1 zsh
```

## Structure for dotfile repos

For you're own dotfiles repo, adhere to the following structure or conventions

### topical

Everything's built around topic areas. If you're adding a new area to your forked dotfiles — say, "Java" — you can
simply add a `java` directory and put files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get symlinked without extension into `$HOME`
when you run `script/bootstrap`.

### components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded
  automatically, its extension is `.sh`, not `.zsh`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into your `$HOME`. This is so you can keep all of
  those versioned in your dotfiles but still keep those autoloaded files in your home directory. These get symlinked in
  when you run `script/bootstrap`.
- env vars are also loaded from `~/.localrc` (if present).  
  If you want to define them without committing them the dotfiles repo create the file an export env vars there.
- **git/gitconfig**: Contains you're gitconfig. Note: This is a difference to the "original" holman/dotfiles.
- Please note that `gitconfig.symlink` and `zshrc.symlink` are ignored, as they are needed by dotfiles-loader.

## Development

```shell
# Mount your local .dotfiles-loader, helpful for development
docker run --rm -it -v $(pwd):/home/dev/.dotfiles-loader ghcr.io/schnatterer/dotfiles-loader
# Mounting your local dotfiles will speed up the start
docker run --rm -it -v $(pwd):/home/dev/.dotfiles-loader -v $HOME/.dotfiles:/home/dev/.dotfiles \
  ghcr.io/schnatterer/dotfiles-loader
# Run non-interactively, speeding up even more:
docker run --rm -it -v $(pwd):/home/dev/.dotfiles-loader -v $HOME/.dotfiles:/home/dev/.dotfiles \
  ghcr.io/schnatterer/dotfiles-loader -c 'echo O | .dotfiles-loader/script/bootstrap && zsh'

# Print some debug statements to better understand order of loading
docker run --rm -it -e DEBUG ghcr.io/schnatterer/dotfiles-loader
# Print every command (`set -x`)
docker run --rm -it -e TRACE ghcr.io/schnatterer/dotfiles-loader
```