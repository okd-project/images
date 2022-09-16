#!/bin/bash

function show_help() {
  echo "Usage: $0 -n <package name> -d <repository dir> -s <spec file absolute path>
    [-r <relative rpm build dir>] [-a <space-separated list of target architectures>]
  "
}

function must_exists() {
  if [ -n "${!1+x}" ]; then
    return
  fi
  # The var with name $1 has no value assigned
  echo "The env var $1 is not defined. Build aborted." >&2
  show_help
  exit 1
}

while getopts "d:n:s:r:a:" opt; do
  case "$opt" in
    \?)
      show_help
      exit 0
      ;;
    d) PKG_GO_PATH=$OPTARG
      ;;
    n) PKG_NAME=$OPTARG
      ;;
    s) SPEC_FILEPATH=$OPTARG
      ;;
    r) RPMBUILD_DIR=$OPTARG
      ;;
    a) ARCHITECTURES=$OPTARG
      ;;
  esac
done

must_exists SPEC_FILEPATH
must_exists PKG_GO_PATH
must_exists PKG_NAME
SPEC_FILENAME=$(basename "$SPEC_FILEPATH")
ARCHITECTURES=${ARCHITECTURES:-$(uname -m)}
RPMBUILD_DIR=${RPMBUILD_DIR:-_output/local/releases}
set -xeo pipefail

# Prepare workspace dir
pushd "$PKG_GO_PATH"
mkdir -p "${RPMBUILD_DIR}"/{BUILD,SOURCES,SPECS,SRPMS}

# Set version variables
SOURCE_GIT_COMMIT=$(git rev-parse --short "HEAD^{commit}" 2>/dev/null)
SOURCE_GIT_TAG=$(git describe --long --tags --abbrev=7 --match '*[0-9]*' | \
  sed -E "s/${PKG_NAME}-([0-9]+\.[0-9]+\.[0-9]+)-.*/\1/" || echo "0.0.0-unknown-${SOURCE_GIT_COMMIT}")
SOURCE_GIT_TREE_STATE=$( ( [ ! -d ".git/" ] || git diff --quiet ) && echo 'clean' || echo 'dirty')
RPM_VERSION=$(echo "${SOURCE_GIT_TAG}" | \
  sed -E 's/v([0-9]+\.[0-9]+\.[0-9]+)-.*/\1/').$(date -u +'%Y%m%d%H%M').${SOURCE_GIT_COMMIT}

# Prepare build archive
tar -czf "${RPMBUILD_DIR}/SOURCES/${PKG_NAME}-${RPM_VERSION}.tar.gz" \
  --exclude=".git" --exclude=_output \
  --transform="s|^|${PKG_NAME}-${RPM_VERSION}/|rSH" .
cp -iv "${SPEC_FILEPATH}" "${RPMBUILD_DIR}/SPECS/${SPEC_FILENAME}"

# Build per-arch RPMs
for ARCH in ${ARCHITECTURES}; do
  rpmbuild -ba --nodeps \
    --target "$ARCH" \
    --define "_topdir $(pwd)/${RPMBUILD_DIR}" \
    --define "_rpmdir $(pwd)/${RPMBUILD_DIR}/rpms" \
    --define "version ${RPM_VERSION}" \
    --define "os_git_vars OS_GIT_VERSION='${SOURCE_GIT_TAG}' OS_GIT_COMMIT='${SOURCE_GIT_COMMIT}'
      OS_GIT_MAJOR='${SOURCE_GIT_MAJOR}' OS_GIT_MINOR='${SOURCE_GIT_MINOR}'
      OS_GIT_TREE_STATE='${SOURCE_GIT_TREE_STATE}'" \
    "${RPMBUILD_DIR}/SPECS/${SPEC_FILENAME}"; \
done

popd
