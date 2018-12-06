# Docker file for nhl-game-prediction
# Aditya Sharma, Shayne Andrews (Dec 06, 2018)

# Usage:
#   To build the docker image: docker build --tag nhl-game-predictor:0.1 .
#		To create the report:
#		To get a clean start:

# Use rocker/tidyverse as the base image
FROM rocker/tidyverse

# Install the cowsay package
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  && install2.r --error \
    --deps TRUE \
    cowsay

# Install R packages
RUN Rscript -e "install.packages('rmarkdown')"
RUN Rscript -e "install.packages('knitr')"
RUN Rscript -e "install.packages('zoo')"
RUN Rscript -e "install.packages('here')"
RUN Rscript -e "install.packages('tidyverse')"
RUN Rscript -e "install.packages('gridExtra')"

# Install python 3
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

# Get python package dependencies
RUN apt-get install -y python3-tk

# Install python packages
RUN pip3 install numpy
RUN pip3 install pandas
RUN pip3 install scikit-learn
RUN pip3 install argparse
RUN apt-get install -y graphviz && pip install graphviz
RUN apt-get update && \
    pip3 install matplotlib && \
    rm -rf /var/lib/apt/lists/*
