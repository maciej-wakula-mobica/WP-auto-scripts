#!/bin/bash

echo "Based on https://docs.google.com/document/d/1hKeqNgBa9YSgaGGF1eqHO0Q1uTBmdDl3fko_nXHpPrY/edit?ts=59f04dfa"
echo "Might work incorrectly on windows - as it is one of a kind operating system... sorry for that"

typeset root="${HOME}/wpw/test/java/"
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

	echo "JAVA Development Kit version..."
	java -version
	[[ $? -ne 0 ]] && {
		echo "JAVA error - was tested with JDK 1.8 on 2017-10-25">&2
		exit 2
	}
	echo "Apache Maven version"
	mvn --version
	[[ $? -ne 0 ]] && {
		echo "Maven error - was tested with 3.0.5 and 3.5.2 on 2017-10-25">&2
		exit 2
	}

	cd "${root}"
	rm -rf ./*
# }}}

echo ".=============."
echo "| Get started |"
echo "'============='"
{ # {{{
	msg "git clone https://github.com/WPTechInnovation/wpw-sdk-java.git"
	git clone https://github.com/WPTechInnovation/wpw-sdk-java.git

	msg "cd wpw-sdk-java"
	cd wpw-sdk-java

	msg "git submodule update --init --recursive"
	git submodule update --init --recursive 

	msg "mvn"
	mvn >"${root}/mvn.stdout" 2>"${root}/mvn.stderr"
} # }}}

echo ".------------------."
echo "| API keys replace |"
echo "'------------------'"
# {{{
	. "${runpath}/replace-API-keys.sh"
	find "${root}" -type f -name '*.java' -exec sed -i.bak -E -e "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f -name '*.java' -exec sed -i.bak -E -e "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
	find "${root}" -type f -name '*.json' -exec sed -i.bak -E -e "s/${DUMMY_SKEYS}/${SKEY}/g" {} \;
	find "${root}" -type f -name '*.json' -exec sed -i.bak -E -e "s/${DUMMY_CKEYS}/${CKEY}/g" {} \;
# }}}

echo ".------------."
echo "| RPC-Agents |"
echo "'------------'"
# {{{
	#ls -l library/iot-core-component/bin
	echo "unset WPW_HOME (was ${WPW_HOME:=unset})"
	unset WPW_HOME
# }}}

echo ".==================."
echo "| Run the examples |"
echo "'=================='"
# {{{
	typeset pid_p
	typeset pid_c

	#${root}/wpw-sdk-java/sample-consumer/target/sample-consumer-v0.7-alpha.jar
	#${root}/wpw-sdk-java/sample-producer/target/sample-producer-v0.7-alpha.jar
	#${root}/wpw-sdk-java/sample-producer-callbacks/target/sample-producer-callbacks-v0.7-alpha.jar
	#${root}/wpw-sdk-java/car-charger/target/car-charger-v0.7-alpha.jar
	#${root}/wpw-sdk-java/car-example/target/car-example-v0.7-alpha.jar
	{
		msg "cd \"${root}/wpw-sdk-java/sample-producer/\""
		cd "${root}/wpw-sdk-java/sample-producer/"
	}
	{
		msg "java -jar \"${root}/wpw-sdk-java/sample-producer/target/sample-producer-v0.7-alpha.jar\" &"
		java -jar "${root}/wpw-sdk-java/sample-producer/target/sample-producer-v0.7-alpha.jar" &
		pid_p=$!
	}
	sleep 3  # Wait a moment so that producer would start
	{
		msg "cd \"${root}/wpw-sdk-java/sample-producer/\""
		cd "${root}/wpw-sdk-java/sample-producer/"
	}
	{
		msg "java -jar \"${root}/wpw-sdk-java/sample-consumer/target/sample-consumer-v0.7-alpha.jar\" &"
		java -jar "${root}/wpw-sdk-java/sample-consumer/target/sample-consumer-v0.7-alpha.jar" &
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
