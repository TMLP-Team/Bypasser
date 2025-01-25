#!/system/bin/sh
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EOF=255
readonly moduleName="Bypasser"
readonly actionPropPath="action.prop"
readonly actionAPath="actionA.sh"
readonly actionBPath="actionB.sh"
readonly actionFolderPath="$(dirname "$0")"

function setPermissions()
{
	returnCode=${EXIT_SUCCESS}
	find . -type d -exec chmod 755 {} \;
	if [[ $? != ${EXIT_SUCCESS} ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	find . ! -name "*.sh" -type f -exec chmod 444 {} \;
	if [[ $? != ${EXIT_SUCCESS} ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	find . -name "*.sh" -type f -exec chmod 544 {} \;
	if [[ $? != ${EXIT_SUCCESS} ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	return ${returnCode}
}

if chmod 755 "${actionFolderPath}" && cd "${actionFolderPath}";
then
	setPermissions
	if [[ -f "${actionPropPath}" ]];
	then
		target="$(cat "${actionPropPath}")";
		if [[ "A" == "${target}" ]];
		then
			if [[ -f "${actionAPath}" ]];
			then
				sh "${actionAPath}"
				exit ${EXIT_SUCCESS}
			fi
		elif [[ "B" == "${target}" ]];
		then
			if [[ -f "${actionBPath}" ]];
			then
				sh "${actionBPath}"
				exit ${EXIT_SUCCESS}
			fi
		else
			echo "Failed to execute \`\`action.sh\`\` since wrong configurations are detected. "
			echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
			exit ${EXIT_FAILURE}
		fi
	else
		echo "Failed to execute \`\`action.sh\`\` since configurations are missing. "
		echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
		exit ${EXIT_FAILURE}
	fi
else
	echo "Failed to execute \`\`action.sh\`\` since the working directory \"$(pwd)\" is unexpected. "
	echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
	exit ${EOF}
fi
