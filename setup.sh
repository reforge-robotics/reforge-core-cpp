#!/usr/bin/env sh
set -eu

BASE_URL="${REFORGE_APT_BASE_URL:-https://reforge-robotics.github.io/reforge-core-cpp}"
SUITE="${REFORGE_APT_SUITE:-stable}"
COMPONENT="${REFORGE_APT_COMPONENT:-main}"
KEYRING="/usr/share/keyrings/reforge-archive-keyring.gpg"
SOURCE_LIST="/etc/apt/sources.list.d/reforge.list"
SUPPORTED_OS_ID="ubuntu"
SUPPORTED_VERSION_IDS="20.04 22.04 24.04"
SUPPORTED_CODENAMES="focal jammy noble"
SUPPORTED_DESCRIPTION="Ubuntu 20.04 (focal), 22.04 (jammy), or 24.04 (noble)"
SUPPORTED_ARCHITECTURES="amd64 arm64"

if [ "$(id -u)" -ne 0 ]; then
    echo "setup.sh must run as root." >&2
    exit 1
fi

if [ ! -r /etc/os-release ]; then
    echo "setup.sh requires ${SUPPORTED_DESCRIPTION}; /etc/os-release is missing." >&2
    exit 1
fi

. /etc/os-release
OS_ID="${ID:-}"
OS_VERSION_ID="${VERSION_ID:-}"
OS_CODENAME="${VERSION_CODENAME:-}"
OS_PRETTY_NAME="${PRETTY_NAME:-unknown Linux distribution}"

if [ "${OS_ID}" != "${SUPPORTED_OS_ID}" ]; then
    echo "Reforge APT setup currently supports only ${SUPPORTED_DESCRIPTION}. Detected: ${OS_PRETTY_NAME}." >&2
    exit 1
fi

VERSION_SUPPORTED=0
for SUPPORTED_VERSION_ID in ${SUPPORTED_VERSION_IDS}; do
    if [ "${OS_VERSION_ID}" = "${SUPPORTED_VERSION_ID}" ]; then
        VERSION_SUPPORTED=1
        break
    fi
done
if [ "${VERSION_SUPPORTED}" != "1" ]; then
    echo "Reforge APT setup currently supports only ${SUPPORTED_DESCRIPTION}. Detected: ${OS_PRETTY_NAME}." >&2
    exit 1
fi

if [ -n "${OS_CODENAME}" ]; then
    CODENAME_SUPPORTED=0
    for SUPPORTED_CODENAME in ${SUPPORTED_CODENAMES}; do
        if [ "${OS_CODENAME}" = "${SUPPORTED_CODENAME}" ]; then
            CODENAME_SUPPORTED=1
            break
        fi
    done
    if [ "${CODENAME_SUPPORTED}" != "1" ]; then
        echo "Reforge APT setup currently supports only ${SUPPORTED_DESCRIPTION}. Detected codename: ${OS_CODENAME}." >&2
        exit 1
    fi
fi

ARCHITECTURE="$(dpkg --print-architecture)"
ARCHITECTURE_SUPPORTED=0
for SUPPORTED_ARCHITECTURE in ${SUPPORTED_ARCHITECTURES}; do
    if [ "${ARCHITECTURE}" = "${SUPPORTED_ARCHITECTURE}" ]; then
        ARCHITECTURE_SUPPORTED=1
        break
    fi
done
if [ "${ARCHITECTURE_SUPPORTED}" != "1" ]; then
    echo "Reforge APT setup currently supports only architecture(s): ${SUPPORTED_ARCHITECTURES}. Detected: ${ARCHITECTURE}." >&2
    exit 1
fi

install -d -m 0755 /usr/share/keyrings /etc/apt/sources.list.d

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${BASE_URL}/reforge-archive-keyring.gpg" -o "${KEYRING}"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "${KEYRING}" "${BASE_URL}/reforge-archive-keyring.gpg"
else
    echo "setup.sh requires curl or wget to fetch the Reforge keyring." >&2
    exit 1
fi

chmod 0644 "${KEYRING}"
printf 'deb [arch=%s signed-by=%s] %s %s %s\n' \
    "${ARCHITECTURE}" "${KEYRING}" "${BASE_URL}" "${SUITE}" \
    "${COMPONENT}" > "${SOURCE_LIST}"

echo "Configured Reforge APT repository: ${BASE_URL} ${SUITE} ${COMPONENT}"
echo "Next commands:"
echo "  sudo apt update"
if [ "${ARCHITECTURE}" = "arm64" ]; then
    echo "  sudo apt install reforge-core-joint-tracker"
    echo "Note: arm64 support currently applies to reforge-core-joint-tracker only."
else
    echo "  sudo apt install reforge-core-joint-tracker"
    echo "  sudo apt install reforge-core-shaper"
    echo "  sudo apt install reforge-core"
fi
