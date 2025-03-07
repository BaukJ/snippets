FROM python:3 AS base

RUN apt update\
 && apt install -y dos2unix\
 && apt clean -y all\
 && rm -rf /var/cache

RUN pip install --no-cache-dir jupyterlab jupyter-collaboration

COPY example.py /example-unix.py

RUN cp /example-unix.py /example-dos.py\
 && dos2unix /example-unix.py\
 && unix2dos /example-dos.py

CMD ["bash", "-c", "jupyter-lab --ServerApp.ip=0.0.0.0 --ServerApp.port=8888 --ServerApp.allow_origin='*' --ServerApp.token='' --ServerApp.base_url=/ --log-level=0 --allow-root"]

FROM base AS install-leaflet
RUN pip install --no-cache-dir jupyter_leaflet ipyleaflet

FROM install-leaflet AS uninstall-leaflet
RUN pip uninstall -y --no-cache-dir jupyter_leaflet ipyleaflet

FROM base AS uninstall-collab
RUN pip uninstall -y --no-cache-dir jupyter-collaboration
