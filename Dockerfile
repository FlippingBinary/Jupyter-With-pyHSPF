# Created by Jon Musselwhite, JMusselwhite@wvstateu.edu

# If you want persistent storage, you'll need to mount a directory to /opt/notebooks
# You can mount a folder named "notebooks" in the present directory with the Windows command below:
#  docker run -dp 8888:8888 --mount src="$(pwd)/notebooks",target=/opt/notebooks,type=bind flippingbinary/jupyter-with-pyhspf

# If you want to change the default password, you'll need to rebuild it locally.
# Copy this Dockerfile to a directory, cd into, change "JUPYTER_PASSWORD", then run:
#  docker build -t local-jupyter .
# After that, you will run "local-jupyter" (or whatever you named it) instead of flippingbinary/jupyter-with-pyhspf

FROM ubuntu:bionic

LABEL author="Jon Musselwhite <jmusselwhite@wvstateu.edu>"

# Change the password if you are exposing this server
ARG JUPYTER_PASSWORD="jupyter"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV TZ="America/New_York"
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    p7zip-full libgdal-dev libgdal20 libproj12 proj-bin libproj-dev proj-data build-essential gfortran unzip

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc\
    && echo "conda activate base" >> ~/.bashrc \
    && conda init bash

RUN conda update --all \
    && conda install -c conda-forge gdal jupyterlab lxml matplotlib numpy pillow pyshp scipy pyproj eccodes pygrib -y --quiet \
    && mkdir /opt/notebooks

RUN /opt/conda/bin/python -m pip install python-cmr

RUN wget --quiet https://github.com/djlampert/PyHSPF/archive/master.zip -O ~/pyhspf.zip \
    && unzip -d ~/ ~/pyhspf.zip \
    && rm ~/pyhspf.zip

RUN cd ~/PyHSPF-master/src \
    && rm setup.cfg \
    && /opt/conda/bin/python setup.py build \
    && /opt/conda/bin/python setup.py install

RUN useradd --create-home --home-dir /home/jupyter --shell /bin/bash jupyter

USER jupyter

WORKDIR /home/jupyter

RUN mkdir ~/.jupyter \
    && echo "{\n  \"NotebookApp\": {\n    \"password\": \""`/opt/conda/bin/python -c "from notebook.auth import passwd;print(passwd('$JUPYTER_PASSWORD'))"`"\"\n  }\n}" \
    > ~/.jupyter/jupyter_notebook_config.json \
    && chmod 0600 ~/.jupyter/jupyter_notebook_config.json

CMD /opt/conda/bin/jupyter lab --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser
