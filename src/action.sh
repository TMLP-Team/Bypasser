#!/system/bin/sh
EXIT_SUCCESS=0
EXIT_FAILURE=1
EOF=127
blacklistName="Blacklist"
whitelistName="Whitelist"
configFolderPath="/sdcard/Download"
blacklistConfigFileName="HMAL_Blacklist_Config.json"
blacklistConfigFilePath="${configFolderPath}/${blacklistConfigFileName}"
whitelistConfigFileName="HMAL_Whitelist_Config.json"
whitelistConfigFilePath="${configFolderPath}/${whitelistConfigFileName}"

function getType()
{
	if [[ "B" == "$1" || "C" == "$1" || "D" == "$1" ]];
	then
		arr=$(curl -s "https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/Classification/classification$1.txt")
		if [[ $? == ${EXIT_SUCCESS} ]];
		then
			for pkg in $arr
			do
				if echo "${pkg}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
				then
					echo "${pkg}"
				fi
			done
			return ${EXIT_SUCCESS}
		else
			return $?
		fi
	else
		return ${EOF}
	fi
}

function getListArray()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\","
	done
	if [[ "${content}" == *, ]];
	then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

function getBlacklistScopeArray()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\":{\"useWhitelist\":false,\"excludeSystemApps\":false,\"applyTemplates\":[\"${blacklistName}\"],\"extraAppList\":[]},"
	done
	if [[ "${content}" == *, ]]; then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

function getWhitelistScopeArrayC()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[\"${package}\"]},"
	done
	if [[ "${content}" == *, ]]; then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

function getWhitelistScopeArrayD()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[]},"
	done
	if [[ "${content}" == *, ]]; then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

classificationB=$(getType "B")
returnCodeB=$?
classificationC=$(getType "C")
returnCodeC=$?
classificationD=$(getType "D")
returnCodeD=$?
if [[ ${returnCodeB} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched $(echo "$classificationB" | wc -l) package name(s) of Type \$B\$. "
else
	echo "Failed to fetch package names of Type \$B\$. "
fi
if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched $(echo "$classificationC" | wc -l) package name(s) of Type \$C\$. "
else
	echo "Failed to fetch package names of Type \$C\$. "
fi
if [[ ${returnCodeD} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched $(echo "$classificationD" | wc -l) package name(s) of Type \$D\$. "
else
	echo "Failed to fetch package names of Type \$D\$. "
fi

if [[ ${returnCodeB} == ${EXIT_SUCCESS} ]];
then
	blacklistAppList=$(getListArray ${classificationB})
	if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
	then
		whitelistScopeList="$(getWhitelistScopeArrayC ${classificationC}),$(getWhitelistScopeArrayD ${classificationD})"
	else
		whitelistScopeList=""
	fi
else
	blacklistAppList=""
fi
if [[ ${returnCodeD} == ${EXIT_SUCCESS} ]];
then
	whitelistAppList=$(getListArray ${classificationD})
	if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
	then
		blacklistScopeList=$(getBlacklistScopeArray ${classificationC} ${classificationD})
	else
		blacklistScopeList=""
	fi
else
	whitelistAppList=""
fi
commonConfigContent="{\"configVersion\":90,\"forceMountData\":true,\"templates\":{\"${blacklistName}\":{\"isWhitelist\":false,\"appList\":[${blacklistAppList}]},\"${whitelistName}\":{\"isWhitelist\":true,\"appList\":[${whitelistAppList}]}},"
blacklistConfigContent="${commonConfigContent}\"scope\":{${blacklistScopeList}}}"
whitelistConfigContent="${commonConfigContent}\"scope\":{${whitelistScopeList}}}"

exitCode=0
if [[ ! -d "${configFolderPath}" ]];
then
	mkdir -p "${configFolderPath}"
fi
if [[ -d "${configFolderPath}" ]];
then
	echo "Successfully created the folder \"${configFolderPath}\". "
	echo "${blacklistConfigContent}" > "${blacklistConfigFilePath}"
	if [[ 0 == ${?} && -e "${blacklistConfigFilePath}" ]];
	then
		echo "Successfully generated the config file \"${blacklistConfigFilePath}\". "
	else
		exitCode=1
		echo "Failed to generate the config file \"${blacklistConfigFilePath}\". "
	fi
	echo "${whitelistConfigContent}" > "${whitelistConfigFilePath}"
	if [[ 0 == ${?} && -e "${whitelistConfigFilePath}" ]];
	then
		echo "Successfully generated the config file \"${whitelistConfigFilePath}\". "
	else
		exitCode=2
		echo "Failed to generate the config file \"${whitelistConfigFilePath}\". "
	fi
else
	exitCode=3
	echo "Failed to create the folder \"${configFolderPath}\". "
fi

echo "Finished executing the \`\`action.sh\`\` (${exitCode}). "
exit ${exitCode}
