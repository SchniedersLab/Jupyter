FROM openjdk:11.0.7

# Use GraalVM for JavaScript and Python
# FROM findepi/graalvm:20.0.0-java11-polyglot

RUN apt-get update
RUN apt-get install -y python3-pip

COPY . .

# Install Node and NPM
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
RUN export NVM_DIR="$HOME/.nvm"
RUN ls -ltr /root/.nvm
RUN /root/.nvm/nvm-exec install node
RUN /root/.nvm/nvm-exec use node

# Install jupyter, jupyterlab, beakerx and jupyter lab extensions
RUN pip3 install --no-cache-dir jupyter jupyterlab beakerx
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install beakerx-jupyterlab

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
ENV NB_USER ffx
ENV SHELL /bin/bash
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER

COPY . $HOME
RUN mkdir $HOME/.jupyter
COPY $HOME/beakerx.json .jupyter/.
RUN chown -R $NB_UID $HOME

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

