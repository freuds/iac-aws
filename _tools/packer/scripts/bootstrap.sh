#!/usr/bin/env bash
set -e -o pipefail

SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

# OS Detection
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
fi

# https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu
case "$NAME" in
    "Ubuntu")
        # Install Python3 et ces dépendances (Ubuntu)
        export DEBIAN_FRONTEND=noninteractive
        export TZ=Etc/UTC
        ${SUDO} apt-get -qq update --yes
        ${SUDO} apt-get -qq install --yes python3-pip cloud-init curl software-properties-common
        ${SUDO} add-apt-repository --yes --update ppa:ansible/ansible
        ${SUDO} apt install ansible
        ;;
    "Debian GNU/Linux")
        # Install Python3 et ces dépendances (Debian)
        export DEBIAN_FRONTEND=noninteractive
        ${SUDO} apt-get -qq update --yes
        ${SUDO} apt-get -qq install --yes python3-pip cloud-init

        if [[ "$VERSION_ID" == "11" ]]; then
          UBUNTU_CODENAME=jammy
          wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | ${SUDO} gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
          ${SUDO} echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | ${SUDO} tee /etc/apt/sources.list.d/ansible.list
          ${SUDO} apt update && ${SUDO} apt install ansible
        elif [[ "$VERSION_ID" == "12" ]]; then
            ${SUDO} apt-get -qq install --yes ansible-core
        fi

        ;;
    "Red Hat Enterprise Linux")
        # Install Python3 et ces dépendances (RHEL8/RHEL9)
        ${SUDO} yum -y update && ${SUDO} yum -y upgrade
        if [[ "$VERSION" == *"9."* ]]; then
            ${SUDO} yum -y install python3 python3-pip python3-cryptography python3-gssapi
            #subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms && dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

        elif [[ "$VERSION" == *"8."* ]]; then
            ${SUDO} yum -y install python39 python39-pip python3-cryptography python3-gssapi
            # subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms && dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        fi
        ;;
    "Amazon Linux")
        # Install Python3 et ces dépendances (AmazonLinux2023)
        ${SUDO} yum -y update && ${SUDO} yum -y upgrade
        if [[ "$VERSION" == "2023" ]]; then
            ${SUDO} yum -y install python3 python3-pip python3-cryptography python3-gssapi python3-boto3 python3-certifi ansible-core
        fi
        if [[ "$VERSION" == "2" ]]; then
            ${SUDO} yum -y install python3 python3-pip python3-cryptography python3-gssapi python3-boto3 python3-certifi ansible-core
        fi
        ;;
    *)
        echo "Unsupported OS: $NAME"
        exit 1
        ;;
esac

# Print Ansible versions
ansible --version

exit 0
