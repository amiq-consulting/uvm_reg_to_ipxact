#!/bin/sh

#/******************************************************************************
# * (C) Copyright 2017 AMIQ Consulting
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *
# * PROJECT:     UVM/SystemVerilog Register Model to IP-XACT
# *
# *******************************************************************************/

# Go to the root directory of the project
cd $(cd `dirname $0` && pwd)/.. && export PROJECT_HOME=`pwd`

rm -rf ./docs && mkdir ./docs

specador.sh -lang vlog -cmd $PROJECT_HOME/.dvt/default.build -preferences $PROJECT_HOME/.dvt/specador.xml

if [ -d ./docs/js ]; then
   cp -f .dvt/custom.js ./docs/js
fi

# Exit if successful
if [[ $? == 0 ]]; then
    cd scripts/
    exit 0
fi

cd scripts/

# Exit and return error code if unsuccessful
printf "\n\nSIMULATION UNSUCCESSFUL\n\n\n"

exit $?
