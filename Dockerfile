FROM ubuntu

RUN apt-get update \
    && apt-get install wget --yes \
    && apt-get install software-properties-common --yes \
    && apt-get install curl --yes

############### install Git
RUN apt-get install git --yes \
    && apt-get install git-lfs --yes
############### install Git

############### install R
# instructions from https://cran.r-project.org/bin/linux/ubuntu/
RUN apt-get install --no-install-recommends software-properties-common dirmngr \
    && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    && apt-get install --no-install-recommends --yes r-base
############### install R

############### install LyX
# instructions from https://wiki.lyx.org/LyX/LyXOnUbuntu
RUN add-apt-repository ppa:lyx-devel/release --yes && \
    apt-get install lyx --yes
############### install LyX

############### install Conda
# instructions from https://stackoverflow.com/questions/64090326/bash-script-to-install-conda-leads-to-conda-command-not-found-unless-i-run-b
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda.sh
RUN ["/bin/bash", "conda.sh", "-b", "-p"]
RUN rm -f conda.sh \
    && /root/miniconda3/bin/conda init bash
############### install Conda

COPY setup/conda_env.yaml conda_env.yaml
# # https://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work
RUN /root/miniconda3/bin/conda env create -f conda_env.yaml

# # https://stackoverflow.com/questions/61915607/commandnotfounderror-your-shell-has-not-been-properly-configured-to-use-conda
SHELL ["/bin/bash", "-c"]

ARG PROJECT_DIR
RUN mkdir /tmp/$PROJECT_DIR
WORKDIR /tmp/$PROJECT_DIR

CMD git submodule init \
    && git submodule update \
    && Rscript setup/setup_r.r \
    && source /root/miniconda3/etc/profile.d/conda.sh \
    && conda activate $(cat setup/conda_env.yaml | head -1 | awk '{print $2}') \
    && python3 run_all.py