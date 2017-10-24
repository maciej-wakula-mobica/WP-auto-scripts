#!/bin/bash

echo "Based on https://wptechinnovation.github.io/wpw-doc-dev/nodejs/"
typeset root="${HOME}/wpw/test/js/"
mkdir -p "${root}"

set -e
set -u

echo "Node version..."
node --version
[[ $? -ne 0 ]] && {
	echo "Node error - download Node 4.x (long term support) or newer">&2
	exit 2
}
echo "NPM version"
npm --version
[[ $? -ne 0 ]] && {
	echo "NPM error - recommended is 2.5.11 or newer">&2
	exit 2
}
echo "Tested on node v4.8.4 and NPM 2.5.11"

cd "${root}"
rm -rf ./*

echo ".=============."
echo "| Get started |"
echo "'============='"
git clone https://github.com/WPTechInnovation/wpw-sdk-nodejs
cd wpw-sdk-nodejs
git submodule update --init --recursive 
#git submodule update --init --recursive --depth=4
npm install

echo ".------------."
echo "| RPC-Agents |"
echo "'------------'"
ls -l library/iot-core-component/bin
echo "unset WPW_HOME (${WPW_HOME:=unset})"
unset WPW_HOME

echo ".==================."
echo "| Run the examples |"
echo "'=================='"
typeset pid_p
typeset pid_c
node example-producer-callbacks.js &
pid_p=$!
sleep 3  # Wait a moment so that producer would start
node example-consumer.js &
pid_c=$!
sleep 20
echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
( kill -9 $pid_p $pid_c )
rm -rf "${root}"
exit 0
