FROM alpine:3.14.0
ARG UID=1000
ARG GID=1000

# Install binaries needed by dotfiles
# Note that bash is needed for executing bootstrap script
RUN apk add --no-cache \
      bash \
      zsh \
      git \
      curl

RUN addgroup -S dev --gid=$GID && adduser --uid $UID -S dev -G dev -s /bin/zsh
USER dev

# TODO remove -> could be done as a part of a test
# And it could be done by install.sh in actual dotfiles repo
# Clone but not install oh-my-zsh (this should be done by dotfiles)
RUN git clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
# Avoid zsh wizard on container start
RUN touch ~/.zshrc 

WORKDIR /home/dev
# TODO do in bootstrap file
RUN git clone  https://github.com/schnatterer/dotfiles ~/.dotfiles
COPY --chown=dev . .dotfiles-loader
# Avoid interactive mode
RUN touch /home/dev/.dotfiles-loader/git/gitconfig.local

# O = overwrite all existing config
ENTRYPOINT ["zsh", "-c" , "echo Running dotfiles bootstrap script && echo O | .dotfiles-loader/script/bootstrap && echo Starting zsh && zsh"]
