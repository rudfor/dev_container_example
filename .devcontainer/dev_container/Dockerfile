# please change this :)
FROM rudolffortes/example 

ARG USERNAME=vscode
# Adapt to your local UID and GID if running on a Linux host (not necessary on Windows host)
ARG USER_UID=1000
ARG USER_GID=$USER_UID

USER root

ENV COMPANY=company

# only provide root access within the local devcontainer for the 
# developers PC Do not put this in the main Dockerfile
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
 && chmod 0440 /etc/sudoers.d/$USERNAME

# Check if the group GID already exists
RUN if ! getent group $USER_GID > /dev/null; then \
        groupadd -g $USER_GID ${COMPANY}; \
    fi
# Add the USERNAME user
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN mkdir -p /home/$USERNAME/.vscode-server/extensions \
        /home/$USERNAME/.vscode-server-insiders/extensions \
     && chown -R $USER_UID:$USER_GID \
        /home/$USERNAME/.vscode-server \
        /home/$USERNAME/.vscode-server-insiders

ENV SHELL /bin/bash

USER $USER_UID:$USER_GID