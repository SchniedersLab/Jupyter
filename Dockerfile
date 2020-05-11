FROM openjdk:11.0.7

# Version of FFX to Download
ENV FFX_VERSION 1.0.0-beta

# Use GraalVM for JavaScript and Python
# FROM findepi/graalvm:20.0.0-java11-polyglot

RUN apt-get update
RUN apt-get install -y python3-pip

# add requirements.txt, written this way to gracefully ignore a missing file
COPY . .
RUN ([ -f requirements.txt ] \
    && pip3 install --no-cache-dir -r requirements.txt) \
        || pip3 install --no-cache-dir jupyter jupyterlab

USER root

RUN git clone git@github.com:twosigma/beakerx.git
RUN cd beakerx
RUN conda env create -n beakerx -f configuration.yml
RUN source activate beakerx
RUN (cd beakerx; pip install -e . --verbose)
RUN beakerx install
RUN beakerx_databrowser install
RUN cd / 

# Download Force Field X
ENV FFX_TAR ffx-$FFX_VERSION-bin.tar.gz
RUN wget https://ffx.biochem.uiowa.edu/$FFX_TAR

# Unpack Force Field X
RUN tar xzf $FFX_TAR
RUN mv ffx-$FFX_VERSION ffx

# Set FFX_HOME and the CLASSPATH
ENV FFX_HOME /ffx
ENV FFX_BIN $FFX_HOME/bin
ENV CLASSPATH $FFX_BIN/ffx-all-$FFX_VERSION.jar

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
RUN chown -R $NB_UID $HOME

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
