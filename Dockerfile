FROM alpine:latest

ENV PACKER_VERSION=1.5.1
ENV PACKER_SHA256SUM=3305ede8886bc3fd83ec0640fb87418cc2a702b2cb1567b48c8cb9315e80047d

ENV ANSIBLE_VERSION=2.9.1
ENV ANSIBLE_LINT_VERSION=4.1.0

RUN apk add --update git bash wget openssl

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip

RUN apk --update --no-cache add \
        ca-certificates \
        openssh-client \
        python3\
        rsync \
        sshpass

RUN apk --update add --virtual \
        .build-deps \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
 && pip3 install --upgrade \
        pip \
        cffi \
        pywinrm \
        jmespath \
        openshift \
        kubernetes-validate \
        urllib3==1.24.2 \
 && pip3 install \
        ansible==${ANSIBLE_VERSION} \
        ansible-lint==${ANSIBLE_LINT_VERSION} \
 && apk del \
        .build-deps \
 && rm -rf /var/cache/apk/*

RUN mkdir -p /etc/ansible \
 && echo 'localhost' > /etc/ansible/hosts \
 && echo -e """\
\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config


ENTRYPOINT ["/bin/packer"]
