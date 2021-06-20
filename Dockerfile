FROM alpine:3.14.0
ARG UID=1000
ARG GID=1000

# Install binaries needed by dotfiles
# Note that bash is needed for executing bootstrap script
RUN apk add --no-cache \
      bash \
      zsh \
      tmux \
      git \
      curl

RUN addgroup -S dev --gid=$GID &&  adduser --uid $UID -S dev -G dev -s /bin/zsh
USER dev

# Clone but not install oh-my-zsh (this should be done by dotfiles)
RUN git clone https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
# Avoid zsh wizard on container start
RUN touch ~/.zshrc 

WORKDIR /home/dev
COPY --chown=dev . .dotfiles

# O = overwrite all existing config
ENTRYPOINT ["zsh", "-c" , "echo Running dotfiles bootstrap script && echo O | .dotfiles/script/bootstrap && echo Starting zsh && zsh"]
