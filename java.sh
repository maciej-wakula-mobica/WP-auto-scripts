#!/bin/bash

echo "Based on https://docs.google.com/document/d/1hKeqNgBa9YSgaGGF1eqHO0Q1uTBmdDl3fko_nXHpPrY/edit?ts=59f04dfa"
echo "Might work incorrectly on windows - as it is one of a kind operating system... sorry for that"

typeset root="${HOME}/wpw/test/java/"

# Startup {{{
	rm -rf "${root}"
	mkdir -p "${root}"

	function msg {
		echo " _$(printf "%${#1}.${#1}s" ""|tr " " "_")_" ; echo "[ ${1} ]"
	}
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
	mvn
} # }}}

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
exit 0
# vim:fdm=marker foldmarker={{{,}}}