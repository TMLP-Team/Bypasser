#!/system/bin/sh
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EOF=255
readonly moduleName="Bypasser"
readonly moduleId="bypasser"
readonly actionFolderPath="$(dirname "$0")"
readonly actionPropPath="action.prop"

function setPermissions
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

chmod 755 "${actionFolderPath}" && cd "${actionFolderPath}"
if [[ $? == ${EXIT_SUCCESS} && "$(basename "$(pwd)")" == "${moduleId}" ]];
then
	setPermissions
	if [[ -f "${actionPropPath}" ]];
	then
		target="$(cat "${actionPropPath}")";
		if [[ "A" == "${target}" || "B" == "${target}" ]];
		then
			actionPath="action${target}.sh"
			if [[ -f "${actionPath}" ]];
			then
				if [[ -x "${actionPath}" ]];
				then
					if sh -n "${actionPath}";
					then
						sh "${actionPath}" "$@"
						exit ${EXIT_SUCCESS}
					else
						echo "Failed to execute \`\`action.sh\`\` since the necessary script \`\`${actionPath}\`\` failed to pass the local shell syntax check (sh). "
						echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
						exit ${EXIT_FAILURE}
					fi
				else
					echo "Failed to execute \`\`action.sh\`\` since the necessary script \`\`${actionPath}\`\` was not executable. "
					echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
					exit 2
				fi
			else
				echo "Failed to execute \`\`action.sh\`\` since the necessary script \`\`${actionPath}\`\` was missing. "
				echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
				exit 3
			fi
		else
			echo "Failed to execute \`\`action.sh\`\` since improper configurations were detected. "
			echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
			exit 4
		fi
	else
		echo "Failed to execute \`\`action.sh\`\` since configurations are missing. "
		echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
		exit 5
	fi
else
	echo "Failed to execute \`\`action.sh\`\` since the working directory \"$(pwd)\" is unexpected. "
	echo "Please try to flash the latest version of the ${moduleName} Magisk Module. "
	exit ${EOF}
fi
