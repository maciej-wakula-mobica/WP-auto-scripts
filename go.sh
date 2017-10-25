#!/bin/bash

echo "Based on https://docs.google.com/document/d/10itB0dALYlKUtYrwCfi4V8nH4yC_tzTablFBmGJn0dE/edit?ts=59ef12a3#"
echo "Might work incorrectly on windows - as it is one of a kind operating system... sorry for that"

typeset root="${HOME}/wpw/test/go/"
typeset runpath="${PWD}"

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

	echo "GO version..."
	go version
	[[ $? -ne 0 ]] && {
		echo "GO error - was tested with GO 1.7.5 and 1.9 on 2017-10-25">&2
		exit 2
	}

	cd "${root}"
	rm -rf ./*
# }}}

echo ".=============."
echo "| Get started |"
echo "'============='"
{ # {{{
	msg "export GOPATH=\"${root}\""
	export GOPATH="${root}"

	msg "go get git.apache.org/thrift.git/lib/go/thrift/..."
	go get git.apache.org/thrift.git/lib/go/thrift/...

	msg "cd $GOPATH/src/git.apache.org/thrift.git"
	cd $GOPATH/src/git.apache.org/thrift.git

	msg "git checkout 0.10.0"
	git checkout 0.10.0

	msg "go get github.com/WPTechInnovation/wpw-sdk-go/..."
	go get github.com/WPTechInnovation/wpw-sdk-go/...
} # }}}

echo ".------------------."
echo "| API keys replace |"
echo "'------------------'"
# {{{
	. "${runpath}/replace-API-keys.sh"
	find "${root}" -type f -name '*.go' -exec sed -E -e -i.bak "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f -name '*.go' -exec sed -E -e -i.bak "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
	find "${root}" -type f -name '*.json' -exec sed -E -e -i.bak "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f -name '*.json' -exec sed -E -e -i.bak "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
# }}}

echo ".------------."
echo "| RPC-Agents |"
echo "'------------'"
# {{{
	#ls -l library/iot-core-component/bin
	echo "unset WPW_HOME (was ${WPW_HOME:=unset})"
	unset WPW_HOME
# }}}

echo ".====================."
echo "| Runng the examples |"
echo "'===================='"
# {{{
	typeset pid_p
	typeset pid_c

	#${root}/wpw-sdk-java/sample-consumer/target/sample-consumer-v0.7-alpha.jar
	#${root}/wpw-sdk-java/sample-producer/target/sample-producer-v0.7-alpha.jar
	#${root}/wpw-sdk-java/sample-producer-callbacks/target/sample-producer-callbacks-v0.7-alpha.jar
	#${root}/wpw-sdk-java/car-charger/target/car-charger-v0.7-alpha.jar
	#${root}/wpw-sdk-java/car-example/target/car-example-v0.7-alpha.jar
	{
		msg "cd \"$GOPATH/src/github.com/WPTechInnovation/wpw-sdk-go/examples/sample-producer-callbacks\""
		cd "$GOPATH/src/github.com/WPTechInnovation/wpw-sdk-go/examples/sample-producer-callbacks"

		msg "go build"
		go build

		msg "./sample-producer-callbacks &"
		./sample-producer-callbacks &
		pid_p=$!
	}
	sleep 3  # Wait a moment so that producer would start
	{
		msg "cd \"$GOPATH/src/github.com/WPTechInnovation/wpw-sdk-go/examples/sample-consumer\""
		cd "$GOPATH/src/github.com/WPTechInnovation/wpw-sdk-go/examples/sample-consumer"

		msg "go build"
		go build

		msg "./sample-consumer &"
		./sample-consumer &
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
