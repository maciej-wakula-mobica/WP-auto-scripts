#!/bin/bash

echo "Based on https://docs.google.com/document/d/1KeJabrh_0iBuePrJNwN-0Pmp2WaPwkMMHhp_I30fXHg/edit?ts=59ef4030#heading=h.s670rsui5exn"
echo "Might work incorrectly on windows - as it is one of a kind operating system... sorry for that"

typeset root="${HOME}/wpw/test/py27/"
typeset runpath="${PWD}"

# Startup {{{
	rm -rf "${root}"
	mkdir -p "${root}"

	function msg {
		echo " _$(printf "%${#1}.${#1}s" ""|tr " " "_")_" ; echo "[ ${1} ]"
	}

	set -e
	set -u

	cd "${root}"
	rm -rf ./*
# }}}

echo ".===============."
echo "| Prerequisites |"
echo "'==============='"
# {{{
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
# }}}

echo ".------------------."
echo "| API keys replace |"
echo "'------------------'"
# {{{
	. "${runpath}/replace-API-keys.sh"
	find "${root}" -type f --name '*.py' -exec sed -i.bak "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f --name '*.py' -exec sed -i.bak "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
	find "${root}" -type f --name '*.json' -exec sed -i.bak "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f --name '*.json' -exec sed -i.bak "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
# }}}

echo ".=============."
echo "| Get started |"
echo "'============='"
# {{{
	msg "git clone \"https://github.com/WPTechInnovation/wpw-sdk-python.git\""
	git clone "https://github.com/WPTechInnovation/wpw-sdk-python.git"

	msg "cd wpw-sdk-python"
	cd wpw-sdk-python

	msg "git submodule update --init --recursive"
	git submodule update --init --recursive

	msg "sudo python3 setup.py install"
	sudo python3 setup.py install
# }}}

echo ".------------."
echo "| RPC-Agents |"
echo "'------------'"
# {{{
	#ls -l library/iot-core-component/bin
	echo "unset WPW_HOME (${WPW_HOME:=unset})"
	unset WPW_HOME
# }}}

echo ".==================."
echo "| Run the examples |"
echo "'=================='"
# {{{
	typeset pid_p
	typeset pid_c

	msg "python3 runProducerOWP.py &"
	python3 runProducerOWP.py &
	pid_p=$!
	sleep 3  # Wait a moment so that producer would start

	msg "python3 runConsumerOWP.py &"
	python3 runConsumerOWP.py &
	pid_c=$!
	sleep 20

	echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
	( kill -9 $pid_p $pid_c )
	echo

	msg "python3 runProducerCallbacksOWP.py &"
	python3 runProducerCallbacksOWP.py&
	pid_p=$!
	sleep 3  # Wait a moment so that producer would start

	msg "python3 runConsumerOWP.py &"
	python3 runConsumerOWP.py &
	pid_c=$!
	sleep 20

	echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
	( kill -9 $pid_p $pid_c )
# }}}

rm -rf "${root}"
exit 0
# vim:fdm=marker foldmarker={{{,}}}
