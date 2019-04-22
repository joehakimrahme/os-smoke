# Print the commands being run so that we can see the command that triggers
# an error.  It is also useful for following along as the install occurs.
set -o xtrace

# Some sanity safeguards
unset GREP_OPTIONS
umask 022

TOP_DIR=$(cd "$(dirname "$0")" && pwd)

# source options from local.conf if it exists and set default values
# if any is missing.
if [ -f "$TOP_DIR"/local.conf ]; then

    # shellcheck disable=SC1091
    # shellcheck source=local.conf
    . "$TOP_DIR"/local.conf
fi

SMK_RCFILE=${SMK_RCFILE:-openrc}
SMK_IMG_NAME=${SMK_IMG_NAME:-cirros}
SMK_PROVIDER_NETWORK=${SMK_PROVIDER_NETWORK:-public}
SMK_PRIVATE_NETWORK=${SMK_PRIVATE_NETWORK:-private}
SMK_DEVSTACK_NETWORK=${SMK_DEVSTACK_NETWORK:-devstack}
SMK_PRIVATE_SUBNET=${SMK_PRIVATE_SUBNET:-private-subnet}
SMK_DEVSTACK_SUBNET=${SMK_DEVSTACK_SUBNET:-devstack-subnet}
SMK_ROUTER_NAME=${SMK_ROUTER_NAME:-testrouter}
SMK_INSTANCE_NAME=${SMK_INSTANCE_NAME:-devstack}


if [ ! -f "$SMK_RCFILE" ]; then
    echo "missing RC file. Set the variable SMK_RCFILE in the environment"
    exit
fi

# shellcheck disable=SC1090
. "$SMK_RCFILE"
