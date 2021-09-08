FROM ubuntu:focal

RUN apt-get update \
    && apt-get install wget --yes \
    && apt-get install software-properties-common --yes \
    && apt-get install curl --yes

############### install Git
RUN apt-get install git --yes \
    && apt-get install git-lfs --yes
############### install Git

############### install LyX
# instructions from https://wiki.lyx.org/LyX/LyXOnUbuntu
RUN add-apt-repository ppa:lyx-devel/release --yes \
    && apt-get update \
    && apt-get install lyx --yes
############### install LyX

############### install Conda
# instructions from https://stackoverflow.com/questions/64090326/bash-script-to-install-conda-leads-to-conda-command-not-found-unless-i-run-b
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda.sh
RUN ["/bin/bash", "conda.sh", "-b", "-p"]
RUN rm -f conda.sh \
    && /root/miniconda3/bin/conda init bash
############### install Conda

COPY setup/conda_env.yaml conda_env.yaml
# https://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work
RUN /root/miniconda3/bin/conda env create -f conda_env.yaml

############### setup Stata
ENV VERSION 17
ENV INSTALL_DIR statainstall
ENV PROG_DIR stata${VERSION}

COPY docker/Stata${VERSION}Linux64.tar /root/stata.tar
RUN cd /root \
    && mkdir ${INSTALL_DIR} \
    && tar -xvf stata.tar -C ${INSTALL_DIR} \
    && mkdir /usr/local/${PROG_DIR}

RUN cd /usr/local/${PROG_DIR} \
    && yes | ./../../../root/${INSTALL_DIR}/install

RUN apt-get update \
    && apt-get install --yes expect \
    && apt-get install --yes libncurses5 \
    && apt-get install --yes python \
    && apt-get install --yes pip

COPY docker/script.exp /usr/local/${PROG_DIR}/script.exp
COPY docker/config_docker.yaml /usr/local/${PROG_DIR}/config_docker.yaml
COPY docker/setup.py /usr/local/${PROG_DIR}/setup.py
RUN cd /usr/local/${PROG_DIR} \
    && pip install pyyaml \
    && python3 setup.py

RUN cd /usr/local/${PROG_DIR} \
    && ./script.exp

RUN echo export PATH="/usr/local/stata${VERSION}:$PATH" >> ~/.bashrc
############### setup Stata

############### prepare container mount location
ARG PROJECT_DIR
RUN mkdir /tmp/$PROJECT_DIR
WORKDIR /tmp/$PROJECT_DIR
############### prepare container mount location

# https://stackoverflow.com/questions/61915607/commandnotfounderror-your-shell-has-not-been-properly-configured-to-use-conda
SHELL ["/bin/bash", "-c"]

ENTRYPOINT git submodule init \
    && git submodule update \
    && source /root/miniconda3/etc/profile.d/conda.sh \
    && conda activate $(conda env list | awk 'NR==4 {print $1}') \
    && Rscript setup/setup_r.r \
    && bash