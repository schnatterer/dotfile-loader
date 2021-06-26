FROM alpine:3.14.0
ARG UID=1000
ARG GID=1000

# Install binaries needed by dotfiles
# Note that bash is needed for executing bootstrap script
RUN apk add --no-cache \
      bash \
      zsh \
      git

RUN addgroup -S dev --gid=$GID && adduser --uid $UID -S dev -G dev -s /bin/zsh
USER dev

# Avoid zsh wizard on container start
RUN touch ~/.zshrc 

WORKDIR /home/dev

COPY --chown=dev . .dotfiles-loader

ENTRYPOINT ["zsh"]
CMD ["-c" , "echo Running dotfiles bootstrap script && .dotfiles-loader/script/bootstrap && echo Starting zsh && zsh"]
