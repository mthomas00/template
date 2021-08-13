FROM ubuntu

RUN 

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

ARG ROOT_NAME=project

COPY . /$ROOT_NAME
WORKDIR /$ROOT_NAME

RUN git submodule init && \
    git submodule update

RUN Rscript setup/setup_r.r

# https://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work
RUN /root/miniconda3/bin/conda env create -f setup/conda_env.yaml
RUN rm paper_slides/output/slides.pdf paper_slides/output/text.pdf

# https://stackoverflow.com/questions/61915607/commandnotfounderror-your-shell-has-not-been-properly-configured-to-use-conda
SHELL ["/bin/bash", "-c"]
WORKDIR /$ROOT_NAME
RUN source /root/miniconda3/etc/profile.d/conda.sh \
    && conda activate $(cat setup/conda_env.yaml | head -1 | awk '{print $2}') \
    && python3 run_all.py
