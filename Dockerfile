# Created by Jon Musselwhite, JMusselwhite@wvstateu.edu

# If you want persistent storage, you'll need to mount a directory to /opt/notebooks
# You can mount a folder named "notebooks" in the present directory with the Windows command below:
#  docker run -dp 8888:8888 --rm --mount src="$(pwd)/notebooks",target=/opt/notebooks,type=bind flippingbinary/jupyter-with-pyhspf

# If you want to use a better password, pass the JUPYTER_PASSWORD environment variable in your run command.
#  docker run -e JUPYTER_PASSWORD="aW3s0mePa$$word" -dp 8888:8888 --rm --mount src="$(pwd)/notebooks",target=/opt/notebooks,type=bind flippingbinary/jupyter-with-pyhspf

# If you want to keep the container around to run automatically or something, remove the "--rm" argument.

FROM ubuntu:bionic

LABEL author="Jon Musselwhite <jmusselwhite@wvstateu.edu>"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV TZ="America/New_York"
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    p7zip-full libgdal-dev libgdal20 libproj12 proj-bin libproj-dev proj-data build-essential gfortran unzip \
    && apt-get clean \
    && apt-get autoclean

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

RUN conda update --all \
    && conda install -c conda-forge gdal jupyterlab lxml matplotlib numpy pillow pyshp scipy pyproj eccodes pygrib -y --quiet \
    && mkdir /opt/notebooks \
    && conda clean --all

RUN /opt/conda/bin/python -m pip install python-cmr

RUN wget --quiet https://github.com/djlampert/PyHSPF/archive/master.zip -O ~/pyhspf.zip \
    && unzip -d ~/ ~/pyhspf.zip \
    && rm ~/pyhspf.zip \
    && cd ~/PyHSPF-master/src \
    && rm setup.cfg \
    && /opt/conda/bin/python setup.py build \
    && /opt/conda/bin/python setup.py install \
    && rm -R ~/PyHSPF-master

RUN useradd --create-home --home-dir /home/jupyter --shell /bin/bash jupyter \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc\
    && echo "conda activate base" >> ~/.bashrc \
    && su -c "conda init bash" - jupyter

USER jupyter

WORKDIR /home/jupyter

COPY startup.sh /home/jupyter/startup.sh

EXPOSE 8888

CMD /bin/bash /home/jupyter/startup.sh
