#!/bin/bash
#
# script to generate the api_server/___init___.py file
#

# set variables 

if $(git describe --tags --abbrev=0); then
    GHE_VERSION="$(git describe --tags --abbrev=0)"
else
    CURRENT_VERSION=$(cat package.json \
                    | grep version \
                    | head -1 \
                    | awk -F: '{ print $2 }' \
                    | sed 's/[",]//g' \
                    | tr -d '[[:space:]]')

    GHE_VERSION="${CURRENT_VERSION}-${BRANCH_NAME}-$(git rev-parse HEAD | head -c 7)"
fi

npm version "${GHE_VERSION}"

GIT_COMMIT=$(git rev-parse HEAD)
BUILD_TIMESTAMP=$(date +'%Y-%m-%dT%H:%M:%SZ')

# Create ___init___.py file 
echo "
import os

__version__ = '$GHE_VERSION'

commit_hash = '$GIT_COMMIT'

build_timestamp = '$BUILD_TIMESTAMP'

" > ___init___.py
