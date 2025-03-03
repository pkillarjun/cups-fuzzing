#!/bin/bash -eu
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# prepare fuzz dir
cp -r $SRC/fuzzing/projects/libcups/fuzzer $SRC/libcups/oss-fuzz/

# build project
cd $SRC/libcups
git submodule update --init --recursive

if [[ $SANITIZER = "address" ]]; then
    export CFLAGS="$CFLAGS -fsanitize=address"
    export CXXFLAGS="$CXXFLAGS -fsanitize=address"
    export LDFLAGS="-fsanitize=address"
fi

./configure
make

# build fuzzers
pushd oss-fuzz/
make
make oss-fuzz
popd

# prepare corpus
pushd $SRC/fuzzing/projects/libcups/seeds
for seed_folder in *; do
    zip -r $seed_folder.zip $seed_folder
done
cp *.zip $OUT
popd