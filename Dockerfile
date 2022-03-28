ARG BUILDER_IMAGE_URL=${BUILDER_IMAGE_URL:-alpine}
ARG BUILDER_IMAGE_TAG=${BUILDER_IMAGE_TAG:-latest}
ARG SERVICE_IMAGE_URL=${SERVICE_IMAGE_URL:-ubuntu}
ARG SERVICE_IMAGE_TAG=${SERVICE_IMAGE_TAG:-18.04}

#
# Key create Container
#
# /etc/ssh/ssh_host_rsa_key
# /etc/ssh/ssh_host_rsa_key.pub
FROM ${BUILDER_IMAGE_URL}:${BUILDER_IMAGE_TAG} AS ssh
RUN apk add --no-cache openssh openrc
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

#
# Ansible Container
#
FROM ${SERVICE_IMAGE_URL}:${SERVICE_IMAGE_TAG} AS ansible
RUN apt-get update && \
    apt-get install -y software-properties-common openssh-server vim && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible

COPY --from=ssh /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/id_rsa

ENTRYPOINT ["/bin/bash"]

#
# Node Container
#
FROM ${SERVICE_IMAGE_URL}:${SERVICE_IMAGE_TAG} AS node
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

COPY --from=ssh /etc/ssh/ssh_host_rsa_key.pub /root/.ssh/authorized_keys
RUN chmod 0600 /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]