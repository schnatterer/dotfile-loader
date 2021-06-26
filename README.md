# dotfiles-loader

dotfiles are how you personalize your system. This is a generalized loader for dotfiles that implements a topic basic
approach (as opposed to a monolithic zshrc), as first described in 
[holman/dotfiles](https://github.com/holman/dotfiles).

Other than the original dotfiles repo, dotfiles-loader does not include any user specific dotfiles, only the code to
load dotfiles from a different repo, following the structure/conventions from holman/dotfiles.  
This way code for loading and actual user specific config can be separated.
No need to fork a repo full of config you don't need. Just create a new `dotfile` repo from scratch.
Mine is [schnatterer/dotfiles](https://github.com/schnatterer/dotfiles), for example.

In addition it is compatible with [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 🎉.
Dotfile-loader also simplifies the process (in my opinion) compared to holman/dotfiles:
There is no `dot`, no `install`, just one `bootstrap` script that needs to be called.

## Try it

You can play around with the loader, no strings attached, using docker.

```shell
docker build -t dotfiles
# Run interactive bootstrap
docker run --rm -it dotfiles

# Skip interactive mode, e.g. using my dotfiles repo as an example
docker run --rm -it \
  -e dotfiles_repo=https://github.com/schnatterer/dotfiles \
  -v $(pwd)/git/gitconfig.local.example:/home/dev/.dotfiles-loader/git/gitconfig.local \
  dotfiles \
  -c 'echo O | .dotfiles-loader/script/bootstrap && zsh'
```

## Install

Prerequisites: `bash`, `zsh`, `git`. And a dotfile repo, preferably your own.

```shell
git clone https://github.com/schnatterer/dotfiles-loader .dotfiles-loader

# This script will interactively lead you through the setup, where you enter your url to your actual dotfile repo
# It will clone your dotfile repo to ~/.dotfiles, creates symlinks, making sure they are initialized on the next shell start
# Everything is configured and tweaked within `~/.dotfiles`.
~/.dotfiles-loader/script/bootstrap

# Alternative: Try out my dotfiles repo:
dotfiles_repo=https://github.com/schnatterer/dotfiles ~/.dotfiles-loader/script/bootstrap
```

BTW - once installed you can call `bootstrap` again any time. It should be idempotent, just running all `install.sh`s 
from your dotfiles repo again.

## Structure / conventions for dotfile repos

For you're own dotfiles repo, adhere to the following principals

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
docker run --rm -it -v $(pwd):/home/dev/.dotfiles-loader dotfiles
# Mounting your local dotfiles will speed up the start
docker run --rm -it -v $(pwd):/home/dev/.dotfiles-loader -v $HOME/.dotfiles:/home/dev/.dotfiles dotfiles
# Run non-interactively, speeding up even more:
docker run --rm -it -v $(pwd):/home/dev/.dotfiles-loader -v $HOME/.dotfiles:/home/dev/.dotfiles dotfiles -c 'echo O | .dotfiles-loader/script/bootstrap && zsh'


# Print some debug statements to better understand order of loading
docker run --rm -it -e DEBUG dotfiles
# Print every command (`set -x`)
docker run --rm -it -e TRACE dotfiles
```