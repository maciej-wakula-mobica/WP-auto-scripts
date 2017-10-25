#!/bin/bash

echo "Based on https://wptechinnovation.github.io/wpw-doc-dev/nodejs/"
typeset root="${HOME}/wpw/test/java/"
mkdir -p "${root}"

set -e
set -u

echo "JAVA Development Kit version..."
java -version
[[ $? -ne 0 ]] && {
	echo "JAVA error - was tested with JDK 1.8">&2
	exit 2
}
echo "Apache Maven version"
mvn --version
[[ $? -ne 0 ]] && {
	echo "Maven error">&2
	exit 2
}

cd "${root}"
rm -rf ./*

echo ".=============."
echo "| Get started |"
echo "'============='"
git clone https://github.com/WPTechInnovation/wpw-sdk-java.git
cd wpw-sdk-java
git submodule update --init --recursive 
mvn

echo ".------------."
echo "| RPC-Agents |"
echo "'------------'"
#ls -l library/iot-core-component/bin
echo "unset WPW_HOME (${WPW_HOME:=unset})"
unset WPW_HOME

echo ".==================."
echo "| Run the examples |"
echo "'=================='"
typeset pid_p
typeset pid_c
#java --jar &
#pid_p=$!
#sleep 3  # Wait a moment so that producer would start
#java --jar &
#pid_c=$!
#sleep 20
#echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
#( kill -9 $pid_p $pid_c )
#rm -rf "${root}"
exit 0
