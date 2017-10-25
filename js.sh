#!/bin/bash

echo "Based on https://wptechinnovation.github.io/wpw-doc-dev/nodejs/"
echo "Might work incorrectly on windows - as it is one of a kind operating system... sorry for that"

typeset root="${HOME}/wpw/test/js/"

# Startup {{{
	rm -rf "${root}"
	mkdir -p "${root}"

	echo "Trying to kill any RPC agents that might be running... although there should be none"
	# There is a known issue with old version of python where rpc-agent could stay running
	# New version of rpc-agent should have watchdog and close itself
	for pid in $(ps -o pid,command|grep -E 'rpc-agent-(linux|windows|darwin)-(386|amd64|arm32|arm64)(\.exe)?'|grep -v "${!}"|cut -d' ' -f 1) ; do kill $pid ; done

	function msg {
		echo " _$(printf "%${#1}.${#1}s" ""|tr " " "_")_" ; echo "[ ${1} ]"
	}
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
# }}}

echo ".=============."
echo "| Get started |"
echo "'============='"
# {{{
	msg "git clone \"https://github.com/WPTechInnovation/wpw-sdk-nodejs\""
	git clone "https://github.com/WPTechInnovation/wpw-sdk-nodejs"

	msg "cd wpw-sdk-nodejs"
	cd wpw-sdk-nodejs

	msg "git submodule update --init --recursive"
	git submodule update --init --recursive
	#git submodule update --init --recursive --depth=4

	msg "npm install"
	npm install
# }}}

echo ".------------------."
echo "| API keys replace |"
echo "'------------------'"
# {{{
	. "${runpath}/replace-API-keys.sh"
	find "${root}" -type f --name '*.js' -exec sed -i.bak "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f --name '*.js' -exec sed -i.bak "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
# }}}

echo ".------------."
echo "| RPC-Agents |"
echo "'------------'"
# {{{
	ls -l library/iot-core-component/bin
	echo "unset WPW_HOME (was ${WPW_HOME:=unset})"
	unset WPW_HOME
# }}}

echo ".==================."
echo "| Run the examples |"
echo "'=================='"
# {{{
	typeset pid_p
	typeset pid_c
	{
		msg "node example-producer-callbacks.js &"
		node example-producer-callbacks.js &
		pid_p=$!
	}
	sleep 3  # Wait a moment so that producer would start
	{
		msg "node example-consumer.js &"
		node example-consumer.js &
		pid_c=$!
	}
	sleep 20
	echo "Assuming the payent should be already made - killing producer ($pid_p) and consumer ($pid_c)"
	( kill -9 $pid_p $pid_c )
# }}}

#rm -rf "${root}"
# Cleanup {{{
	echo "Trying to kill any RPC agents that might be running... although there should be none"
	# There is a known issue with old version of python where rpc-agent could stay running
	# New version of rpc-agent should have watchdog and close itself
	for pid in $(ps -o pid,command|grep -E 'rpc-agent-(linux|windows|darwin)-(386|amd64|arm32|arm64)(\.exe)?'|grep -v "${!}"|cut -d' ' -f 1) ; do kill $pid ; done
# }}}
exit 0
# vim:fdm=marker foldmarker={{{,}}}
