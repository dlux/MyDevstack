#!/bin/bash
# ================================================================
# Script installs: devstack
# Assume Ubuntu Bionic
# Assume proxy was setup outside this script
# Devstack configuration:: MariaDB, RabbitMQ,
#     stable/rocky branch, and reset default passwords to secrete9
# See help to display all the options.
# ================================================================

# Uncomment the following line to debug
 set -o xtrace

#=================================================
# GLOBAL VARIABLES DEFINITION
#=================================================
# release branch
_branch='stable/rocky'

# openstack component password
_password='secrete9'

# Additional configurations
_added_lines=''

# Proxy to use for the installation
_proxy=''

# ============= Processes devstack installation options ======================
function PrintHelp {
    echo " "
    echo "Script installs devstack - different configurations available."
    echo " "
    echo "Usage:"
    echo "    ./$(basename "$0") [--basic|--branch <branch>|--ceph|--heat|\
--ironic|--password <pwd>|--swift|--help]"
    echo " "
    echo "     --basic        Installs devstack with minimal configuration."
    echo "     --branch       Use given branch e.g stable/rocky"
    echo "     --ceph         Configure devstack with ceph cluster."
    echo "     --heat         Add heat project."
    echo "     --ironic       Add ironic and ironic inspector projects."
    echo "     --password     Use given password for devstack DBs,Queue, etc."
    echo "     --swift        Add swift project."
    echo " "
    echo "     --help         Prints current help text. "
    echo " "
    exit 1
}

function PrintError {
    echo "***************************" >&2
    echo "* Error: $1" >&2
    echo "  See ./$(basename "$0") --help" >&2
    echo "***************************" >&2
    exit 1
}

# If no parameter passed print help
if [ -z "${1}" ]; then
   PrintHelp
fi

while [[ ${1} ]]; do
  case "${1}" in
    --basic)
      # minimal installation hence no extra stuff
      shift
      ;;
    --branch)
      # Installs devstack from an specific branch
      if [[ -z "${2}" || "${2}" == --* ]]; then
        PrintError "Missing branch name."
      else
        _branch="${2}"
      fi
      shift
      ;;
    --ceph)
      read -r -d '' lines << EOM
#
# CEPH
#  -------
enable_plugin plugin-ceph https://github.com/openstack/devstack-plugin-ceph
ENABLE_CEPH_RGW=True
EOM
      _added_lines="$_added_lines"$'\n'"$lines"
      ;;
    --heat)
      read -r -d '' lines << EOM
#
# HEAT
#
enable_service h-eng
enable_service h-api
enable_service h-api-cfn
enable_service h-api-cw
EOM
      _added_lines="$_added_lines"$'\n'"$lines"
      ;;
    --ironic)
      read -r -d '' lines << EOM
#
# Ironic
#
enable_plugin ironic https://git.openstack.org/openstack/ironic
enable_plugin ironic-ui https://github.com/openstack/ironic-ui
EOM
      _added_lines="$_added_lines"$'\n'"$lines"
      ;;
    --password)
      # Use specific password for common objetcs
      if [[ -z "${2}" || "${2}" == --* ]]; then
        PrintError "Missing password."
      else
        _password="${2}"
      fi
      shift
      ;;
    --swift)
      read -r -d '' lines << EOM
#
# SWIFT
#  -------
enable_service s-proxy s-object s-container s-account
EOM
      _added_lines="$_added_lines"$'\n'"$lines"
      ;;
    --help|-h)
      PrintHelp
      ;;
    *)
      PrintError "Invalid Argument: $1."
  esac
  shift
done

# ======= START INSTALLATION =================================================
# Ensure script is run as NON-ROOT
sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo su - stack

# Install software pre-requisites
sudo apt-get -y update
sudo apt-get -y install git

# Configure git to use https instead of ssh
git config --global url."https://".insteadOf git://

# Clone devstack project with correct branch
git clone https://git.openstack.org/openstack-dev/devstack -b $_branch
pushd devstack

# Create local.conf file
# Pre-set the passwords to prevent interactive prompts
read -r -d '' password_lines << EOM
[[local|localrc]]
ADMIN_PASSWORD="${_password}"
DATABASE_PASSWORD="${_password}"
RABBIT_PASSWORD="${_password}"
SERVICE_PASSWORD="${_password}"
HOST_IP=$(ip route get 8.8.8.8 | awk -Fsrc '{ print $2 }' | awk '{ print $1 }')
EOM
echo "$password_lines" > ./local.conf

# Additional Configuration
if [[ ! -z "$_added_lines" ]]; then
    echo "$_added_lines" >> ./local.conf
fi

# Run Devstack
./stack.sh

