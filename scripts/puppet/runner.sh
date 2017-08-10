#!/bin/bash

IS_YUM=$(which yum &>/dev/null && echo yes)
IS_APT=$(which apt-get &>/dev/null && echo yes)

ctx_node_properties() {
    PROP=$(ctx --json-output ${CTX_SIDE} node properties "$1" 2>/dev/null | jq -c -r -M '.')

    if [ -z "${PROP}" ]; then
        MAIN_KEY=${1%%\.*}
        JSON_KEY=${1#*\.}

        if [ "${MAIN_KEY}" = "${JSON_KEY}" ]; then
            JSON_KEY=''
        fi

        JSON_VAL=$(eval $(echo echo \$"${MAIN_KEY}"))
        PROP=$(echo "${JSON_VAL}" | jq -c -r -M ".${JSON_KEY}" 2>/dev/null)

        if [ "${PROP}" = 'null' ]; then
            PROP=''
        fi
    fi

    echo "${PROP}"
}

# install jq
function install_jq() {
    if ! jq --version &>/dev/null; then
        if [ -n "${IS_YUM}" ]; then
            sudo -n yum -yq install jq
        elif [ -n "${IS_APT}" ]; then
            sudo -n apt-get -y install jq >/dev/null
        fi
    fi
}

# install agent
function install_pc1_agent() {
    if ! [ -x /opt/puppetlabs/bin/puppet ]; then
        ctx logger info 'Puppet: installing Puppet Agent'
        PC_REPO=$(ctx_node_properties 'puppet_config.repo')
        if [ "x${PC_REPO}" != 'x' ]; then
            if [ -n "${IS_YUM}" ]; then
                sudo -n rpm -i "${PC_REPO}"
            elif [ -n "${IS_APT}" ]; then
                local PC_REPO_PKG=$(mktemp)
                wget -O "${PC_REPO_PKG}" "${PC_REPO}"
                sudo -n dpkg -i ${PC_REPO_PKG}
                sudo -n apt-get -qq update
                unlink ${PC_REPO_PKG}
            fi
        else
            ctx logger warning 'Puppet: missing repository package'
        fi

        PC_PACKAGE=$(ctx_node_properties 'puppet_config.package')
        if [ "x${PC_PACKAGE}" != 'x' ]; then
            if [ -n "${IS_YUM}" ]; then
                sudo -n yum -y -q install "${PC_PACKAGE}"
            elif [ -n "${IS_APT}" ]; then
                sudo -n apt-get -y install "${PC_PACKAGE}" >/dev/null
            fi
        else
            ctx logger error 'Puppet: missing Puppet package name'
        fi
        ctx logger info 'Puppet: installing Puppet Agent ... done'
    fi

    if ! [ -x /opt/puppetlabs/puppet/bin/r10k ]; then
        ctx logger info 'Puppet: installing r10k'
        sudo -n /opt/puppetlabs/puppet/bin/gem install --quiet r10k
        ctx logger info 'Puppet: installing r10k ... done'
    fi
}

# get recipes and modules
function puppet_recipes() {
    if ! [ -d "${1}" ]; then
        # download and extract manifests
        mkdir -p "${1}"
        PC_DOWNLOAD=$(ctx_node_properties 'puppet_config.download')
        MANIFESTS_FILE=$(ctx download-resource ${PC_DOWNLOAD})
        ctx logger info 'Puppet: extracting recipes'
        tar -xf ${MANIFESTS_FILE} -C ${1}
        ctx logger info 'Puppet: extracting recipes ... done'

        # install modules
        cd ${1}
        PUPPETFILE="${1}/Puppetfile"
        ctx logger info 'Puppet: installing modules '
        test -f ${PUPPETFILE} && \
            sudo /opt/puppetlabs/puppet/bin/r10k puppetfile install ${PUPPETFILE}
        ctx logger info 'Puppet: installing modules ... done'
    fi
}

# generate hiera configuration
function puppet_hiera() {
    cat >>"${1}/hiera.yaml" <<EOF
---
version: 5

defaults:
  datadir: "${1}"
  data_hash: json_data

hierarchy:
  - name: Common
    path: "common.json"
EOF

    HIERA_DATA=$(ctx_node_properties 'puppet_config.hiera' 2>/dev/null)
    if [ "x${HIERA_DATA}" != 'x' ]; then
        echo "${HIERA_DATA}" >"${1}/common.json"
    fi
}

# generate external facts
function puppet_facts() {
    export FACTER_CLOUDIFY_CTX_TYPE=${CTX_TYPE}
    export FACTER_CLOUDIFY_CTX_OPERATION_NAME=${CTX_OPERATION_NAME}
    export FACTER_CLOUDIFY_CTX_SIDE=${CTX_SIDE}
    export FACTER_CLOUDIFY_CTX_INSTANCE_ID=${CTX_INSTANCE_ID}
    export FACTER_CLOUDIFY_CTX_INSTANCE_HOST_IP=${CTX_INSTANCE_HOST_IP}
    export FACTER_CLOUDIFY_CTX_NODE_ID=${CTX_NODE_ID}
    export FACTER_CLOUDIFY_CTX_NODE_NAME=${CTX_NODE_NAME}
    export FACTER_CLOUDIFY_CTX_BLUEPRINT_ID=${CTX_BLUEPRINT_ID}
    export FACTER_CLOUDIFY_CTX_WORKFLOW_ID=${CTX_WORKFLOW_ID}
    export FACTER_CLOUDIFY_CTX_EXECUTION_ID=${CTX_EXEC_ID}

    if [ -n "${CTX_REMOTE_SIDE}" ]; then
        export FACTER_CLOUDIFY_CTX_REMOTE_INSTANCE_ID=${CTX_REMOTE_INSTANCE_ID}
        export FACTER_CLOUDIFY_CTX_REMOTE_INSTANCE_HOST_IP=${CTX_REMOTE_INSTANCE_HOST_IP}
    fi

    FACTSD="${1}/cloudify_facts_modules/facts.d/"
    mkdir -p ${FACTSD}
    echo "${CTX_INSTANCE_RUNTIME_PROPS}" >"${FACTSD}/runtime_properties.json"
    echo "${CTX_NODE_PROPS}" >"${FACTSD}/node_properties.json"
}


#############################

CTX_SIDE="${relationship_side:-$1}"

# install Puppet on very first run
install_jq
install_pc1_agent

CTX_TYPE=$(ctx type)
CTX_OPERATION_NAME=$(ctx operation name | rev | cut -d. -f1 | rev)
MANIFEST="${manifest:-$(ctx_node_properties "puppet_config.manifests.${CTX_OPERATION_NAME}" 2>/dev/null)}"
if [ "x${MANIFEST}" = 'x' ]; then
    ctx logger info 'Skipping lifecycle operation, no Puppet manifest'
    exit
fi


# context variables
CTX_TYPE=$(ctx type)
CTX_INSTANCE_ID=$(ctx ${CTX_SIDE} instance id)
CTX_INSTANCE_RUNTIME_PROPS=$(ctx --json-output ${CTX_SIDE} instance runtime_properties)
CTX_INSTANCE_HOST_IP=$(ctx ${CTX_SIDE} instance host_ip)

# relationship remote side metadata
if [ -n "${CTX_SIDE}" ]; then
    if [ "${CTX_SIDE}" == 'source' ]; then
        CTX_REMOTE_SIDE='target'
    else
        CTX_REMOTE_SIDE='source'
    fi

    CTX_REMOTE_INSTANCE_ID=$(ctx ${CTX_REMOTE_SIDE} instance id)
    #CTX_REMOTE_INSTANCE_RUNTIME_PROPS=$(ctx --json-output ${CTX_REMOTE_SIDE} instance runtime_properties)
    CTX_REMOTE_INSTANCE_HOST_IP=$(ctx ${CTX_REMOTE_SIDE} instance host_ip)
fi

CTX_NODE_ID=$(ctx ${CTX_SIDE} node id)
CTX_NODE_NAME=$(ctx ${CTX_SIDE} node name)
CTX_NODE_PROPS=$(ctx --json-output ${CTX_SIDE} node properties)
CTX_BLUEPRINT_ID=$(ctx blueprint id)
CTX_DEPLOYMENT_ID=$(ctx deployment id)
CTX_WORKFLOW_ID=$(ctx workflow_id)
CTX_EXEC_ID=$(ctx execution_id)
CTX_CAPS=$(ctx --json-output capabilities get_all)

MANIFESTS="/tmp/cloudify-ctx/puppet/${CTX_EXEC_ID}"
puppet_recipes "${MANIFESTS}"
HIERA_DIR=$(mktemp -d "${MANIFESTS}/hiera.XXXXXX")
puppet_hiera "${HIERA_DIR}"
FACTS_DIR=$(mktemp -d "${MANIFESTS}/facts.XXXXXX")
puppet_facts "${FACTS_DIR}"

cd ${MANIFESTS}

# run Puppet
ctx logger info "Puppet: running manifest ${MANIFEST}"

#PUPPET_OUT=$(LANG=C LC_ALL=C sudo -En /opt/puppetlabs/bin/puppet apply \
#    --hiera_config="${HIERA_DIR}/hiera.yaml" \
#    --modulepath="${MANIFESTS}/modules:${MANIFESTS}/site:${FACTS_DIR}" \
##    ${MANIFEST} 2>&1)


sudo -En /opt/puppetlabs/bin/puppet apply \
    --hiera_config="${HIERA_DIR}/hiera.yaml" \
    --modulepath="${MANIFESTS}/modules:${MANIFESTS}/site:${FACTS_DIR}" \
    --verbose ${MANIFEST}

PUPPET_RTN=$?

#ctx logger info "Puppet: ${PUPPET_OUT}"
ctx logger info 'Puppet: done'

# https://docs.puppet.com/puppet/latest/man/apply.html
# 0: The run succeeded with no changes or failures; the system was already in the desired state.
# 1: The run failed.
# 2: The run succeeded, and some resources were changed.
# 4: The run succeeded, and some resources failed.
# 6: The run succeeded, and included both changes and failures.
if [ ${PUPPET_RTN} -eq 1 ] || [ ${PUPPET_RTN} -eq 4 ] || [ ${PUPPET_RTN} -eq 6 ]; then
    exit ${PUPPET_RTN}
else
    exit 0
fi