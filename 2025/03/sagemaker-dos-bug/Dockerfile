FROM public.ecr.aws/sagemaker/sagemaker-distribution:2.2.0-cpu AS base

RUN sudo apt update\
 && sudo apt install -y dos2unix\
 && sudo apt clean -y all\
 && sudo rm -rf /var/cache

CMD ["bash", "-c", "jupyter-lab --ServerApp.ip=0.0.0.0 --ServerApp.port=8888 --ServerApp.allow_origin='*' --ServerApp.token='' --ServerApp.base_url=/ --log-level=0"]

FROM base AS install-leaflet
#ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN source _activate_current_env.sh\
 && micromamba install -y jupyter_leaflet ipyleaflet

FROM install-leaflet AS uninstall-leaflet
RUN source _activate_current_env.sh\
 &&micromamba remove -y jupyter_leaflet ipyleaflet

FROM base AS uninstall-collab
RUN source _activate_current_env.sh\
 &&micromamba remove -y jupyter-collaboration
