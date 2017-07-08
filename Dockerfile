FROM registry.access.redhat.com/rhel7/rhel:latest
MAINTAINER Guillaume Dumas <guillaume.dumas@ansible.com>
RUN yum clean all && \
    yum -y install epel-release && \
    yum -y install PyYAML python-jinja2 python-httplib2 python-keyczar python-paramiko python-setuptools git python-pip
RUN mkdir /etc/ansible/
RUN echo -e '[local]\nlocalhost\n' > /etc/ansible/hosts
RUN mkdir /opt/ansible/
RUN git clone http://github.com/ansible/ansible.git /usr/share/lib/ansible/ansible
WORKDIR /usr/share/lib/ansible/ansible
RUN git submodule update --init
ENV PATH /usr/share/lib/ansible/ansible/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV PYTHONPATH /usr/share/lib/ansible/ansible/lib
ENV ANSIBLE_LIBRARY /usr/share/lib/ansible/ansible/library

WORKDIR /
RUN mkdir -p ansible
COPY site.yml /ansible/site.yml
COPY defaults /ansible/defaults
COPY tasks /ansible/tasks
COPY vars /ansible/vars

ARG PLATFORM

RUN ansible-playbook -i localhost, \
-e "platform=${PLATFORM} skip_tools=true" /ansible/site.yml \
&& rm -rf /ansible \
&& yum clean-all \
&& rm -rf /var/cache/yum/*

