FROM beakerx/beakerx:1.3.0

COPY . .

USER root

# Version of FFX to Download
ENV FFX_VERSION 1.0.0-beta

# Download Force Field X
ENV FFX_TAR ffx-$FFX_VERSION-bin.tar.gz
RUN wget https://ffx.biochem.uiowa.edu/$FFX_TAR

# Unpack Force Field X
RUN tar xzf $FFX_TAR
RUN mv ffx-$FFX_VERSION ffx

# Set up the user environment
RUN echo ${NB_USER} ${NB_UID} ${HOME}
ARG NB_USER=beakerx
ENV HOME /home/${NB_USER}
ENV SHELL /bin/bash

COPY . $HOME
RUN mkdir $HOME/.jupyter
# COPY $HOME/beakerx.json $HOME/.jupyter/.
# RUN chown -R $NB_UID $HOME

RUN echo $PATH

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
