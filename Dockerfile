FROM tensorflow/tensorflow:2.2.0rc2-gpu-py3-jupyter

ENV DEBIAN_FRONTEND noninteractive

ENV HOME /root
ENV NB_PREFIX /
ENV PATH $HOME/.local/bin:$PATH

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    apt-transport-https \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    git \
    gnupg \
    graphviz \
    locales \
    lsb-release \
    openssh-client \
    python3-dev \
    python3-pip \
    python3-setuptools \
    unzip \
    vim \
    wget \
    zip

# Install Nodejs for jupyterlab-manager
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    nodejs

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install AWS CLI
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip" && \
    unzip /tmp/awscli-bundle.zip && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm -rf ./awscli-bundle

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install azure-cli

# Install Google Cloud SDK
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk kubectl

# Clean APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Tini - used as entrypoint for container
RUN cd /tmp && \
    wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini && \
    echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Install base python3 packages
RUN pip3 --no-cache-dir install \
    azure==4.0.0 \
    google-api-python-client \
    google-cloud \
    h5py \
    ipywidgets \
    jupyter-console \
    jupyterlab \
    keras \
    kubeflow-fairing \
    kubernetes==10.0.1 \
    matplotlib \
    pandas \
    pandas-gbq \
    python-dateutil==2.8.0 \
    sklearn \
    tensor2tensor \
    widgetsnbextension \
    xgboost

# Configure container startup
EXPOSE 8888
ENTRYPOINT ["tini", "--"]
CMD ["sh","-c", "jupyter notebook --notebook-dir=/root --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
