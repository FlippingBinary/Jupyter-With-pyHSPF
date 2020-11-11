# Jupyter-With-pyHSPF
This Docker project provides a working Jupyter Lab server with pyHSPF pre-installed. 

## Quick start
The quickest way to get started is to run directly from the Docker hub build. You need to share a folder between host and container to hold the notebooks, so the following command expects a folder in the current directory of the host named "notebooks"

`docker run -dp 8888:8888 -v ./notebooks:/opt/notebooks --rm flippingbinary/jupyter-with-pyhspf`

Default password is 'jupyter'

## Alternate password
If the container might be exposed, you need to change the password. One way to do that is with the `JUPYTER_PASSWORD` environment variable like this:

`docker run -dp 8888:8888 -v ./notebooks:/opt/notebooks -e JUPYTER_PASSWORD='NEWPASSWORD' --rm flippingbinary/jupyter-with-pyhspf`
