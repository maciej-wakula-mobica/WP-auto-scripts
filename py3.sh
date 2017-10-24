#!/bin/bash

echo "Based on https://wptechinnovation.github.io/wpw-doc-dev/python27://docs.google.com/document/d/1KeJabrh_0iBuePrJNwN-0Pmp2WaPwkMMHhp_I30fXHg/edit?ts=59ef4030#heading=h.s670rsui5exn"
typeset root="${HOME}/wpw/test/py27/"
mkdir -p "${root}"

set -e
set -u

cd "${root}"
rm -rf ./*

echo ".===============."
echo "| Prerequisites |"
echo "'==============='"
python3 --version
[[ $? -ne 0 ]] && {
	echo "Python 3.x expected in PATH">&2
	exit 2
}
echo "Setuptools version..."
easy_install3 --version
[[ $? -ne 0 ]] && {
	echo "Setuptools error - install it first (ex. \`sudo apt install python3-setuptools\`)">&2
	exit 2
}
echo "Create an account with Worldpay Online.... cannot automatically test"
echo "Not checking the API keys"

echo ".=============."
echo "| Get started |"
echo "'============='"
git clone https://github.com/WPTechInnovation/wpw-sdk-python.git
cd wpw-sdk-python
git submodule update --init --recursive
sudo python3 setup.py install

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
python3 runProducerOWP.py &
pid_p=$!
sleep 3  # Wait a moment so that producer would start
python3 runConsumerOWP.py
pid_c=$!
sleep 20
echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
( kill -9 $pid_p $pid_c )
echo

python3 runProducerCallbacksOWP.py
pid_p=$!
sleep 3  # Wait a moment so that producer would start
python3 runConsumerOWP.py
pid_c=$!
sleep 20
echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
( kill -9 $pid_p $pid_c )

rm -rf "${root}"
exit 0
