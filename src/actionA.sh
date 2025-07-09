#!/system/bin/sh
# Welcome (0b00000X) #
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EOF=255
readonly VK_POWER=13
readonly VK_SCREEN=20
readonly VK_UP=38
readonly VK_DOWN=40
readonly moduleName="Bypasser"
readonly moduleId="bypasser"
readonly defaultTimeout=5
readonly actionFolderPath="$(dirname "$0")"
readonly adbFolder="../.."
readonly magiskFolder="${adbFolder}/magisk"
readonly apatchFolder="${adbFolder}/ap"
readonly startTime=$(date +%s%N)
readonly magiskVulnerabilityVersion=27007
exitCode=${EXIT_SUCCESS}

function clearCaches
{
	sync && echo 3 > /proc/sys/vm/drop_caches
	return $?
}

function setPermissions
{
	returnCode=${EXIT_SUCCESS}
	if [[ -n "$(find . -type d -exec chmod 555 {} \; 2>&1)" ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	if [[ -n "$(find . -type f ! -name "*.sh" -exec chmod 444 {} \; 2>&1)" ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	if [[ -n "$(find . -type f -name "*.sh" -exec chmod 544 {} \; 2>&1)" ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	if ! chown -R root:root ".";
	then
		returnCode=${EXIT_FAILURE}
	fi
	return ${returnCode}
}

echo "Welcome to the \`\`action.sh\`\` of the ${moduleName} Magisk Module! "
echo "The absolute path to this script slot is \"$(cd "$(dirname "$0")" && pwd)/$(basename "$0")\". "
clearCaches
if [[ $? -eq ${EXIT_SUCCESS} ]];
then
	echo "Successfully cleared caches. "
else
	exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
	echo "Failed to clear caches. "
fi
chmod 755 "${actionFolderPath}" && cd "${actionFolderPath}"
if [[ $? -eq ${EXIT_SUCCESS} && "$(basename "$(pwd)")" == "${moduleId}" ]];
then
	echo "The current working directory is \"$(pwd)\". "
	setPermissions
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "Successfully set permissions. "
	else
		exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
		echo "Failed to set permissions. "
	fi
else
	echo "The working directory \"$(pwd)\" is unexpected. "
	exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
fi
if ${BOOTMODE};
then
	if [[ "${KSU}" == "true" ]];
	then
		echo "KSU (${KSU_VER_CODE}): Please "
		echo "- deploy the latest SukiSU from the \`\`Actions\`\` tab of its GitHub repository with only applications requiring root privileges configured and granted in the SukiSU Manager, "
		echo "- install the latest ReZygisk module from the \`\`Actions\`\` tab of its GitHub repository as a system module, "
		echo "- embed or install the latest SUSFS as a kernel or system module, "
		echo "- install the latest \`\`Jing Matrix\`\` branch of the LSPosed module from the \`\`Actions\`\` tab of its GitHub repository as a system module with the narrowest scope configured for each plugin, "
		echo "- install the latest Play Integrity Fix (PIF) module as a system module, "
		echo "- install the latest Tricky Store (TS) module as a system module with the correct configurations, and"
		echo "- activate the latest HMA plugin from https://t.me/HideMyApplist with the correct configurations. "
		if [[ -d "${magiskFolder}" ]];
		then
			echo "The Magisk folder exists while the KSU / KSU Next / SukiSU is using. Please consider removing the Magisk folder. "
		fi
		if [[ -d "${apatchFolder}" ]];
		then
			echo "The Apatch folder exists while the KSU / KSU Next is using. Please consider removing the Apatch folder. "
		fi
	elif [[ "${APATCH}" == "true" ]];
	then
		echo "Apatch (${APATCH_VER_CODE}): Please "
		echo "- deploy the latest Apatch from the \`\`Actions\`\` tab of its GitHub repository with only applications requiring root privileges configured and granted in the Apatch Manager, "
		echo "- embed the latest Cherish Peekaboo as a kernel module, "
		echo "- install the latest ReZygisk module from the \`\`Actions\`\` tab of its GitHub repository as a system module, "
		echo "- install the latest NoHello module as a system module with the whitelist mode enabled, "
		echo "- install the latest \`\`Jing Matrix\`\` branch of the LSPosed module from the \`\`Actions\`\` tab of its GitHub repository as a system module with the narrowest scope configured for each plugin, "
		echo "- install the latest Play Integrity Fix (PIF) module as a system module, "
		echo "- install the latest Tricky Store (TS) module as a system module with the correct configurations, and"
		echo "- activate the latest HMA plugin from https://t.me/HideMyApplist with the correct configurations. "
		if [[ -d "${magiskFolder}" ]];
		then
			echo "The Magisk folder exists while the Apatch is using. Please consider removing the Magisk folder. "
		fi
	else
		if [[ -z "${MAGISK_VER_CODE}" ]];
		then
			MAGISK_VER_CODE="$(magisk -V)" &> /dev/null
		fi
		if [[ -z "${MAGISK_VER}" ]];
		then
			MAGISK_VER="$(magisk -v | cut -d ':' -f1)" &> /dev/null
		fi
		if [[ -n "${MAGISK_VER_CODE}" ]];
		then
			if [[ ${MAGISK_VER} == *-kitsune || ${MAGISK_VER} == *-delta ]];
			then
				echo "Magisk Delta (${MAGISK_VER_CODE}): Please "
				echo "- deploy the latest Magisk Delta with the built-in Zygisk enabled, the whitelist mode enabled, and only applications requiring root privileges configured and granted in the Magisk Delta Manager, "
				echo "- install the latest \`\`Jing Matrix\`\` branch of the LSPosed module from the \`\`Actions\`\` tab of its GitHub repository as a system module with the narrowest scope configured for each plugin, "
				echo "- install the latest Play Integrity Fix (PIF) module, "
				echo "- install the latest Tricky Store (TS) module with the correct configurations, "
				echo "- install the latest bindhosts or the built-in Systemless hosts module (optional), and "
				echo "- activate the latest HMA plugin from https://t.me/HideMyApplist with the correct configurations. "
				echo "Please consider switching to the latest Magisk Alpha if possible. "
			else
				if [[ ${MAGISK_VER} == *-alpha ]];
				then
					echo -n "Magisk Alpha "
				elif [[ ${MAGISK_VER} == *-beta ]];
				then
					echo -n "Magisk Beta "
				elif [[ ${MAGISK_VER} == *-canary ]];
				then
					echo -n "Magisk Canary "
				else
					echo -n "Magisk "
				fi
				echo "(${MAGISK_VER_CODE}): Please "
				echo "- deploy the latest Magisk Alpha with the built-in Zygisk and denylist disabled, "
				echo "- execute applications requiring root privileges with root privileges granted, "
				echo "- install the latest Zygisk Next module with the denylist disabled, "
				echo "- install the latest Shamiko module with the whitelist mode enabled, "
				echo "- install the latest \`\`Jing Matrix\`\` branch of the LSPosed module from the \`\`Actions\`\` tab of its GitHub repository as a system module with the narrowest scope configured for each plugin, "
				echo "- install the latest Play Integrity Fix (PIF) module, "
				echo "- install the latest Tricky Store (TS) module with the correct configurations, "
				echo "- install the latest bindhosts or the built-in Systemless hosts module (optional), and "
				echo "- activate the latest HMA plugin from https://t.me/HideMyApplist with the correct configurations. "
			fi
			if [[ ${MAGISK_VER_CODE} -lt ${magiskVulnerabilityVersion} ]];
			then
				echo "Magisk versions before ${magiskVulnerabilityVersion} can contain severe privilege escalation vulnerability. You are using Magisk ${MAGISK_VER_CODE}. Please update it as soon as possible. "
			fi
			if [[ -d "${apatchFolder}" ]];
			then
				echo "The Apatch folder exists while the Magisk is using. Please consider removing the Apatch folder. "
			fi
		else
			echo "Unknown: The rooting solution used is unknown. "
		fi
	fi
else
	echo "Unbooted: The device is not working in the boot mode. "
fi
echo ""

# Zygisk Traces (0b0000X0) #
echo "# Zygisk Traces (0b0000X0) #"
readonly magiskModuleFolder="${adbFolder}/modules"
readonly zygiskSolutionModuleId="zygisksu"
readonly zygiskNextConfigurationFolderPath="${adbFolder}/zygisksu"
readonly zygiskNextDenylistConfigurationFileName="denylist_enforce"
readonly zygiskNextDenylistConfigurationFilePath="${zygiskNextConfigurationFolderPath}/${zygiskNextDenylistConfigurationFileName}"
readonly shamikoModuleId="zygisk_shamiko"
readonly shamikoConfigurationFolderPath="${adbFolder}/shamiko"
readonly shamikoWhitelistConfigurationFileName="whitelist"
readonly shamikoWhitelistConfigurationFilePath="${shamikoConfigurationFolderPath}/${shamikoWhitelistConfigurationFileName}"
readonly zygiskAssistantModuleId="zygisk-assistant"
readonly noHelloModuleId="zygisk_nohello"
readonly noHelloConfigurationFolderPath="${adbFolder}/nohello"
readonly noHelloWhitelistConfigurationFileName="whitelist"
readonly noHelloWhitelistConfigurationFilePath="${noHelloConfigurationFolderPath}/${noHelloWhitelistConfigurationFileName}"
readonly rezygiskConfigurationFolderPath="${adbFolder}/rezygisk"
readonly neozygiskConfigurationFolderPath="${adbFolder}/neozygisk"
readonly builtInZygiskFilePath="${adbFolder}/magisk/zygisk"

function isModuleInstalled
{
	moduleInstallationFolderPath="${magiskModuleFolder}/$1"
	if [[ -d "${moduleInstallationFolderPath}" ]];
	then
		modulePropFileName="module.prop"
		modulePropFilePath="${moduleInstallationFolderPath}/${modulePropFileName}"
		if [[ -f "${modulePropFilePath}" ]];
		then
			if grep -q "^id=$1\$" "${modulePropFilePath}";
			then
				grep "^name=" "${modulePropFilePath}" | cut -d '=' -f2
				return ${EXIT_SUCCESS}
			fi
		fi
	fi
	return ${EXIT_FAILURE}
}

if [[ "${ZYGISK_ENABLED}" == "1" ]];
then
	zygiskSolutionModuleName="$(isModuleInstalled "${zygiskSolutionModuleId}")"
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "The Zygisk solution was implemented by ${zygiskSolutionModuleName}. "
		toBeWritten="1"
		if isModuleInstalled "${shamikoModuleId}" > /dev/null;
		then
			toBeWritten="0"
			echo "The Shamiko module was installed. "
			if [[ "${APATCH}" == "true" ]];
			then
				echo "Please kindly acknowledge that the Shamiko module does not work with Apatch. Please consider using ReZygisk + NoHello in Apatch. "
			elif [[ ${MAGISK_VER} == *-kitsune || ${MAGISK_VER} == *-delta ]];
			then
				echo "Please kindly acknowledge that the Shamiko module does not work with Magisk Delta. Please consider switching to Magisk Alpha or removing the Shamiko module. "
			fi
			mkdir -p "${shamikoConfigurationFolderPath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${shamikoConfigurationFolderPath}" ]];
			then
				echo "Successfully prepared the Shamiko configuration folder \"${shamikoConfigurationFolderPath}\". "
				if [[ -f "${shamikoWhitelistConfigurationFilePath}" ]];
				then
					echo "The Shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\" already existed. "
				else
					echo "The Shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\" did not exist. "
					touch "${shamikoWhitelistConfigurationFilePath}"
					if [[ $? -eq ${EXIT_SUCCESS} && -f "${shamikoWhitelistConfigurationFilePath}" ]];
					then
						echo "Successfully created the Shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\". "
					else
						exitCode=$(expr ${exitCode} \| 2)
						echo "Failed to create the Shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\". "
					fi
				fi
			else
				echo "Failed to prepare the Shamiko configuration folder \"${shamikoConfigurationFolderPath}\". "
			fi
		else
			echo "The Shamiko module was not installed. "
		fi
		if isModuleInstalled "${zygiskAssistantModuleId}" > /dev/null;
		then
			if [[ "0" == "${toBeWritten}" ]];
			then
				if [[ "${APATCH}" != "true" && ${MAGISK_VER} != *-kitsune && ${MAGISK_VER} != *-delta ]];
				then
					echo "The Zygisk Assistant module was installed while the Shamiko module was installed. Please consider only using the Shamiko module in your environment. "
				else
					echo "The Zygisk Assistant module was installed while the Shamiko module was installed. Please consider only using the Zygisk Assistant module in your environment. "
				fi
			else
				echo "The Zygisk Assistant module was installed. "
			fi
			toBeWritten="0"
		else
			echo "The Zygisk Assistant module was not installed. "
		fi
		if isModuleInstalled "${noHelloModuleId}" > /dev/null;
		then
			if [[ "0" == "${toBeWritten}" ]];
			then
				if [[ "${APATCH}" != "true" && ${MAGISK_VER} != *-kitsune && ${MAGISK_VER} != *-delta ]];
				then
					echo "The NoHello module was installed while the Shamiko or the Zygisk Assistant module was installed, which can cause compatibility issues. Please consider only using the Shamiko module in your environment. "
				else
					echo "The NoHello module was installed while the Shamiko or the Zygisk Assistant module was installed, which can cause compatibility issues. Please consider only using the NoHello module in your environment. "
				fi
			else
				echo "The NoHello module was installed. "
			fi
			toBeWritten="0"					
			mkdir -p "${noHelloConfigurationFolderPath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${noHelloConfigurationFolderPath}" ]];
			then
				echo "Successfully prepared the NoHello configuration folder \"${noHelloConfigurationFolderPath}\". "
				if [[ -f "${noHelloWhitelistConfigurationFilePath}" ]];
				then
					echo "The NoHello whitelist configuration file \"${noHelloWhitelistConfigurationFilePath}\" already existed. "
				else
					echo "The NoHello whitelist configuration file \"${noHelloWhitelistConfigurationFilePath}\" did not exist. "
					touch "${noHelloWhitelistConfigurationFilePath}"
					if [[ $? -eq ${EXIT_SUCCESS} && -f "${noHelloWhitelistConfigurationFilePath}" ]];
					then
						echo "Successfully created the NoHello whitelist configuration file \"${noHelloWhitelistConfigurationFilePath}\". "
					else
						exitCode=$(expr ${exitCode} \| 2)
						echo "Failed to create the NoHello whitelist configuration file \"${noHelloWhitelistConfigurationFilePath}\". "
					fi
				fi
			else
				echo "Failed to prepare the NoHello configuration folder \"${noHelloConfigurationFolderPath}\". "
			fi
		else
			echo "The NoHello module was not installed. "
		fi
		if [[ "Zygisk Next" == "${zygiskSolutionModuleName}" ]];
		then
			mkdir -p "${zygiskNextConfigurationFolderPath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${zygiskNextConfigurationFolderPath}" ]];
			then
				echo "Successfully prepared the Zygisk Next configuration folder \"${zygiskNextConfigurationFolderPath}\". "
				if [[ -f "${zygiskNextDenylistConfigurationFilePath}" && "${toBeWritten}" == "$(cat "${zygiskNextDenylistConfigurationFilePath}")" ]];
				then
					echo "The Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\" is already configured. "
				else
					echo "The Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\" was not configured. "
					echo -n "${toBeWritten}" > "${zygiskNextDenylistConfigurationFilePath}"
					if [[ $? -eq ${EXIT_SUCCESS} && -f "${zygiskNextDenylistConfigurationFilePath}" ]];
					then
						echo "Successfully wrote \"${toBeWritten}\" to the Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\". "
					else
						exitCode=$(expr ${exitCode} \| 2)
						echo "Failed to write \"${toBeWritten}\" to the Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\". "
					fi
				fi
			else
				echo "Failed to prepare the Zygisk Next configuration folder \"${zygiskNextConfigurationFolderPath}\". "
			fi
			if [[ -d "${rezygiskConfigurationFolderPath}" ]];
			then
				echo "The ReZygisk configuration folder exists while the Zygisk Next is using. Please consider removing the ReZygisk configuration folder. "
			fi
			if [[ -d "${neozygiskConfigurationFolderPath}" ]];
			then
				echo "The NeoZygisk configuration folder exists while the Zygisk Next is using. Please consider removing the NeoZygisk configuration folder. "
			fi
		elif [[ "ReZygisk" == "${zygiskSolutionModuleName}" ]];
		then
			if [[ -d "${zygiskNextConfigurationFolderPath}" ]];
			then
				echo "The Zygisk Next configuration folder exists while the ReZygisk is using. Please consider removing the Zygisk Next configuration folder. "
			fi
			if [[ -d "${neozygiskConfigurationFolderPath}" ]];
			then
				echo "The NeoZygisk configuration folder exists while the ReZygisk is using. Please consider removing the NeoZygisk configuration folder. "
			fi
		elif [[ "NeoZygisk" == "${zygiskSolutionModuleName}" ]];
		then
			if [[ -d "${zygiskNextConfigurationFolderPath}" ]];
			then
				echo "The Zygisk Next configuration folder exists while the NeoZygisk is using. Please consider removing the Zygisk Next configuration folder. "
			fi
			if [[ -d "${rezygiskConfigurationFolderPath}" ]];
			then
				echo "The ReZygisk configuration folder exists while the NeoZygisk is using. Please consider removing the ReZygisk configuration folder. "
			fi
			if isModuleInstalled "${shamikoModuleId}" > /dev/null;
			then
				if [[ "${APATCH}" == "true" ]];
				then
					echo "The Shamiko module does not work with Apatch or NeoZygisk. Please consider removing this module and switching to ReZygisk + NeHello. "
				else
					echo "The Shamiko module does not work with NeoZygisk. Please consider either switching to Zygisk Next or removing this module. "
				fi
			fi
			if isModuleInstalled "${noHelloModuleId}" > /dev/null;
			then
				echo "The NoHello module does not work with NeoZygisk. Please consider either switching to ReZygisk or removing this module. "
			fi
		fi
	elif [[ -f "${builtInZygiskFilePath}" ]]
	then
		echo "The Zygisk solution was implemented by Magisk built-in Zygisk. "
	else
		echo "The Zygisk was enabled but the implementation was unknown. "
	fi
else
	echo "The Zygisk was not enabled. "
fi
echo ""

# HMA(L) (0b000X00) #
echo "# HMA(L) (0b000X00) #"
readonly webrootName="webroot"
readonly webrootFolderPath="${webrootName}"
readonly webrootFilePath="${webrootName}.zip"
readonly webrootUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/webroot.zip"
readonly webrootDigestUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/webroot.zip.sha512"
readonly classificationFolderName="classifications"
readonly classificationFolderPath="${webrootFolderPath}/${classificationFolderName}"
readonly dataAppFolder="/data/app"
readonly largerOldScanningScope="/data"
readonly smallerOldScanningScope="/data/misc"
readonly blacklistName="Blacklist"
readonly whitelistName="Whitelist"
if [[ -n "${EXTERNAL_STORAGE}" ]];
then
	readonly downloadFolderPath="${EXTERNAL_STORAGE}/Download"
else
	readonly downloadFolderPath="/sdcard/Download"
fi
readonly blacklistConfigurationFileName=".HMA(L)_Blacklist_Config.json"
readonly blacklistConfigurationFilePath="${downloadFolderPath}/${blacklistConfigurationFileName}"
readonly whitelistConfigurationFileName=".HMA(L)_Whitelist_Config.json"
readonly whitelistConfigurationFilePath="${downloadFolderPath}/${whitelistConfigurationFileName}"
readonly reportLink="https://github.com/TMLP-Team/Bypasser"
gapTime=0

function getClassification
{
	if [[ $# -eq 1 ]];
	then
		if [[ "B" == "$1" || "C" == "$1" || "D" == "$1" ]];
		then
			classificationFilePath="${classificationFolderPath}/classification$1.txt"
			if [[ -f "${classificationFilePath}" ]];
			then
				arr="$(cat "${classificationFilePath}")"
				returnCode=$?
				if [[ ${returnCode} -eq ${EXIT_SUCCESS} && -n "${arr}" ]];
				then
					arr="$(echo -n ${arr} | sort | uniq)"
					echoFlag=0
					for package in ${arr}
					do
						if echo -n "${package}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
						then
							if [[ 1 == ${echoFlag} ]];
							then
								echo -e -n "\n${package}"
							else
								echo -n "${package}"
								echoFlag=1
							fi
						fi
					done
					return ${EXIT_SUCCESS}
				else
					return ${returnCode}
				fi
			else
				return ${EOF}
			fi
		else
			return ${EOF}
		fi
	else
		return ${EOF}
	fi
}

function getTheKeyPressed
{
	if echo "$1" | grep -qE '^[1-9][0-9]*$';
	then
		timeout=$1
	else
		timeout=${defaultTimeout}
	fi
	read -r -t ${timeout} pressString < <(getevent -ql)
	pressCode=$?
	if [[ ${EXIT_SUCCESS} == ${pressCode} ]];
	then
		if [[ "${pressString}" == *KEY_VOLUMEUP* ]];
		then
			echo "The [+] was pressed. "
			return ${VK_UP}
		elif [[ "${pressString}" == *KEY_VOLUMEDOWN* ]];
		then
			echo "The [-] was pressed. "
			return ${VK_DOWN}
		elif [[ "${pressString}" == *KEY_POWER* ]];
		then
			echo "The power key was pressed. "
			return ${VK_POWER}
		elif [[ "${pressString}" == *ABS_MT_TRACKING_ID* ]];
		then
			echo "The screen was pressed. "
			return ${VK_SCREEN}
		else
			echo "The following unknown event occurred. "
			echo "${pressString}" | sed 's/^/\t/'
			return ${EXIT_FAILURE}
		fi
	else
		echo "Users did not respond within ${timeout} second(s). "
		return ${EOF}
	fi
}

function getArray
{
	if [[ $# == 1 ]];
	then
		content=""
		arr="$(echo -n "$1" | sort | uniq)"
		for package in ${arr}
		do
			content="${content}\"${package}\","
		done
		if [[ "${content}" == *, ]];
		then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}	

function getBlacklistScopeStringC
{
	if [[ $# == 1 ]];
	then
		content=""
		arr="$(echo -n "$1" | sort | uniq)"
		totalLength="$(echo "${arr}" | wc -l)"
		headIndex=0
		tailIndex=$(expr ${totalLength} - ${headIndex} - 1)
		for package in ${arr}
		do
			extraAppList="$(getArray "$(echo -e -n "$(echo -n "${arr}" | head -${headIndex})\n$(echo -n "${arr}" | tail -${tailIndex})")")"
			headIndex=$(expr ${headIndex} + 1)
			tailIndex=$(expr ${tailIndex} - 1)
			content="${content}\"${package}\":{\"useWhitelist\":false,\"excludeSystemApps\":false,\"applyTemplates\":[\"${blacklistName}\"],\"extraAppList\":[${extraAppList}]},"
		done
		if [[ "${content}" == *, ]]; then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}

function getBlacklistScopeStringD
{
	if [[ $# == 2 ]];
	then
		content=""
		arr="$(echo -n "$1" | sort | uniq)"
		extraAppList="$(getArray "$(echo -n "$2" | sort | uniq)")"
		for package in ${arr}
		do
			content="${content}\"${package}\":{\"useWhitelist\":false,\"excludeSystemApps\":false,\"applyTemplates\":[\"${blacklistName}\"],\"extraAppList\":[${extraAppList}]},"
		done
		if [[ "${content}" == *, ]]; then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}

function getWhitelistScopeString
{
	if [[ $# == 2 ]];
	then
		content=""
		arrC="$(echo "$1" | sort | uniq)"
		arrD="$(echo "$2" | sort | uniq)"
		for package in ${arrC}
		do
			content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[\"${package}\"]},"
		done
		for package in ${arrD}
		do
			content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[]},"
		done
		if [[ "${content}" == *, ]]; then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}

webrootDigest="$(curl -s "${webrootDigestUrl}")"
if [[ $? -eq ${EXIT_SUCCESS} && -n "${webrootDigest}" ]];
then
	echo "Successfully fetched the SHA-512 value of the latest ZIP file of the web UI. "
	if [[ -d "${webrootFolderPath}" && "$(find "${webrootFolderPath}" -type f ! -name "*.sha512" ! -name "*.prop" -exec sha512sum {} \; | sort)" == "${webrootDigest}" ]];
	then
		echo "The current web UI is already up-to-date. "
	else
		echo "The current web UI is out-of-date and needs to be updated. "
		abortFlag=${EXIT_SUCCESS}
		if [[ -d "${webrootFolderPath}" ]];
		then
			rm -rf "${webrootFolderPath}.bak" && mv -fT "${webrootFolderPath}" "${webrootFolderPath}.bak"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${webrootFolderPath}.bak" ]];
			then
				echo "Successfully moved \"${webrootFolderPath}\" to \"${webrootFolderPath}.bak\". "
			else
				abortFlag=${EXIT_FAILURE}
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to move \"${webrootFolderPath}\" to \"${webrootFolderPath}.bak\". "
			fi
		else
			echo "No old web UI folders were found to be backed up. "
		fi
		if [[ ${EXIT_SUCCESS} -eq ${abortFlag} ]];
		then
			curl -s "${webrootUrl}" -o "${webrootFilePath}" && unzip "${webrootFilePath}" -d "${webrootFolderPath}" && rm -f "${webrootFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${webrootFolderPath}" && "$(find "${webrootFolderPath}" -type f ! -name "*.sha512" ! -name "*.prop" -exec sha512sum {} \; | sort)" == "${webrootDigest}" ]];
			then
				echo "Successfully updated and verified the web UI. "
				if [[ -d "${webrootFolderPath}.bak" ]];
				then
					rm -rf "${webrootFolderPath}.bak"
					if [[ $? -eq ${EXIT_SUCCESS} && ! -d "${webrootFolderPath}.bak" ]];
					then
						echo "Successfully removed \"${webrootFolderPath}.bak\". "
					else
						echo "Failed to remove \"${webrootFolderPath}.bak\". "
					fi
				else
					echo "No old web UI folders that should be removed were found. "
				fi
			else
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to update or verify the web UI. "
				if [[ -d "${webrootFolderPath}.bak" ]];
				then
					rm -rf "${webrootFolderPath}" && mv -fT "${webrootFolderPath}.bak" "${webrootFolderPath}"
					if [[ $? -eq ${EXIT_SUCCESS} && -d "${webrootFolderPath}" ]];
					then
						echo "Successfully restored \"${webrootFolderPath}.bak\" to \"${webrootFolderPath}\". "
					else
						echo "Failed to restore \"${webrootFolderPath}.bak\" to \"${webrootFolderPath}\". "
					fi
				else
					echo "No old web UI folders were found for restoring. "
				fi
			fi
		fi
	fi
else
	exitCode=$(expr ${exitCode} \| 32)
	echo "Failed to fetch the SHA-512 value of the latest ZIP file of the web UI. "
fi
if [[ $(expr ${exitCode} \& 32) -ne ${EXIT_SUCCESS} ]];
then
	echo "The updating of the classifications might fail. This will use the classification cache files to generate the HMA(L) configurations. "
fi
classificationB="$(getClassification "B")"
returnCodeB=$?
if [[ -n "${classificationB}" ]];
then
	lengthB=$(echo "${classificationB}" | wc -l)
else
	lengthB=0
fi
classificationC="$(getClassification "C")"
returnCodeC=$?
if [[ -n "${classificationC}" ]];
then
	lengthC=$(echo "${classificationC}" | wc -l)
else
	lengthC=0
fi
classificationD="$(getClassification "D")"
returnCodeD=$?
if [[ -n "${classificationD}" ]];
then
	lengthD=$(echo "${classificationD}" | wc -l)
else
	lengthD=0
fi
if [[ ${returnCodeB} -eq ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched ${lengthB} package name(s) of Classification \$B\$ from the library. "
	if [[ $# -ge 1 ]];
	then
		keyCode="$1"
	else
		echo "Please press the [+] or [-] key in ${defaultTimeout} seconds if you want to perform the local scanning (\`\`/data\`\`). Otherwise, you may touch the screen to skip the timing. "
		startGapTime=$(date +%s%N)
		getTheKeyPressed
		keyCode=$?
		endGapTime=$(date +%s%N)
		gapTime=$(expr ${endGapTime} - ${startGapTime})
	fi
	if [[ ${VK_UP} -eq ${keyCode} || ${VK_DOWN} -eq ${keyCode} ]];
	then
		localBCount=0
		folderCount=0
		fileCount=0
		failureInstallationCount=0
		failureInstallationRemovedCount=0
		echo "Performing local user application installation directory scanning. "
		for item in "${dataAppFolder}/"*
		do
			if [[ -d "${item}" ]];
			then
				if basename "${item}" | grep -qE "^vmdl[0-9]+\\.tmp\$";
				then
					failureInstallationCount=$(expr ${failureInstallationCount} + 1)
					if rm -rf "${item}";
					then
						failureInstallationRemovedCount=$(expr ${failureInstallationRemovedCount} + 1)
						echo "[${failureInstallationRemovedCount}/${failureInstallationCount}] Found a failure installation at \"${item}\", which has been removed. "
					else
						echo "[${failureInstallationRemovedCount}/${failureInstallationCount}] Found a failure installation at \"${item}\", which could not be removed. "
					fi
				else
					folderCount=$(expr ${folderCount} + 1)
					subItems="$(ls -1 "${item}")"
					if [[ $(echo "${subItems}" | wc -l) -eq 1 ]];
					then
						firstItem="$(echo "${subItems}" | awk "NR==1")"
						packageName="$(basename "${firstItem}" | cut -d "-" -f 1)"
						if echo -n "${packageName}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
						then
							if ! echo -n "${classificationB}" | grep -qF "${packageName}";
							then
								printableStrings="$(cat "${item}/${firstItem}/base.apk" | strings)"
								if echo "${printableStrings}" | grep -qE "/xposed/|xposed_init";
								then
									localBCount=$(expr ${localBCount} + 1)
									classificationB="$(echo -e -n "${classificationB}\n${packageName}")"
									echo -n "[${localBCount}] Found the string \"/xposed/\" or \"xposed_init\" in \`\`${packageName}\`\`, which was not in and has been added to Classification \$B\$. "
								fi
							fi
						else
							echo "- Failed to resolve the folder \"${item}\". "
						fi
					else
						echo "- There is at least 1 additional item in \"${item}\", which should not exist. "
					fi
				fi
			elif [ -f "${item}" ];
			then
				if [[ "${item}" == *.apk ]];
				then
					fileCount=$(expr ${fileCount} + 1)
					packageName="$(basename "${item}")"
					packageName="${packageName%.apk}"
					if echo -n "${packageName}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
					then
						if ! echo -n "${classificationB}" | grep -qF "${packageName}";
						then
							printableStrings="$(cat "${item}/${firstItem}/base.apk" | strings)"
							if echo "${printableStrings}" | grep -qE "/xposed/|xposed_init";
							then
								localBCount=$(expr ${localBCount} + 1)
								classificationB="$(echo -e -n "${classificationB}\n${packageName}")"
								echo -n "[${localBCount}] Found the string \"/xposed/\" or \"xposed_init\" in \`\`${packageName}\`\`, which was not in and has been added to Classification \$B\$. "
							fi
						fi
					else
						echo "- Failed to resolve the APK file \"${item}\". "
					fi
				else
					echo "- A file that should not exist was found at \"${item}\". "
				fi
			fi
		done
		if [[ ${folderCount} -gt 0 ]] && [[ ${fileCount} -gt 0 ]];
		then
			echo "A mixture of folders and files was detected in the \"${dataAppFolder}\" directory. "
		fi
		if [[ ${failureInstallationCount} -ge 1 ]];
		then
			echo "Found ${failureInstallationCount} failure installation(s) in the \"${dataAppFolder}\" directory with ${failureInstallationRemovedCount} removed successfully. "
		fi
		if [[ ${localBCount} -ge 1 ]];
		then
			echo "Successfully fetched ${localBCount} package name(s) of Classification \$B\$ from the local machine. "
			echo "Kindly report the package name(s) with the corresponding classification(s) to \"${reportLink}\" if you wish to. "
		fi
		originalLengthB=${lengthB}
		classificationB=$(echo -n "${classificationB}" | sort | uniq)
		if [[ -n "${classificationB}" ]];
		then
			lengthB=$(echo "${classificationB}" | wc -l)
		else
			lengthB=0
		fi
		echo "Successfully fetched ${lengthB} package name(s) of Classification \$B\$ from the library (${originalLengthB}) and the local machine (${localBCount}). "
		oldConfigurationFolderCount=0
		removedOldConfigurationFolderCount=0
		echo "Removing old HMA(L) configuration directories. "
		for oldPath in $(find "${largerOldScanningScope}" -type d -and \( -name "*h_m_a_l*" -or -name "*hma*" -or -name "*hma1*" -or -name "hmal*" \))
		do
			if [[ -e "${oldPath}/config.json" && -d "${oldPath}/log" ]];
			then
				oldConfigurationFolderCount=$(expr ${oldConfigurationFolderCount} + 1)
				if rm -rf "${oldPath}";
				then
					removedOldConfigurationFolderCount=$(expr ${removedOldConfigurationFolderCount} + 1)
					echo "[${removedOldConfigurationFolderCount}/${oldConfigurationFolderCount}] Successfully removed \"${oldPath}\" (L). "
				else
					echo "[${removedOldConfigurationFolderCount}/${oldConfigurationFolderCount}] Failed to remove \"${oldPath}\" (L). "
				fi
			fi
		done
		for oldPath in $(find "${smallerOldScanningScope}" -mindepth 2 -type d -and \( -name "*h_m_a_l*" -or -name "*hma*" -or -name "*hma1*" -or -name "hmal*" \))
		do
			if [[ -z "$(ls -A "${oldPath}")" ]];
			then
				oldConfigurationFolderCount=$(expr ${oldConfigurationFolderCount} + 1)
				if rm -rf "${oldPath}";
				then
					removedOldConfigurationFolderCount=$(expr ${removedOldConfigurationFolderCount} + 1)
					echo "[${removedOldConfigurationFolderCount}/${oldConfigurationFolderCount}] Successfully removed \"${oldPath}\" (S). "
				else
					echo "[${removedOldConfigurationFolderCount}/${oldConfigurationFolderCount}] Failed to remove \"${oldPath}\" (S). "
				fi
			fi
		done
		if [[ ${oldConfigurationFolderCount} -ge 2 ]];
		then
			echo "Found ${oldConfigurationFolderCount} old HMA(L) configuration directories in the \"${largerOldScanningScope}\" directory, with ${removedOldConfigurationFolderCount} removed successfully. "
		elif [[ ${oldConfigurationFolderCount} -eq 1 ]];
		then
			echo "Found 1 old HMA(L) configuration directory in the \"${largerOldScanningScope}\" directory, with ${removedOldConfigurationFolderCount} removed successfully. "
		else
			echo "No old HMA(L) configuration folders were found. "
		fi
	fi
else
	classificationB=""
	lengthB=0
	echo "Failed to fetch package names of Classification \$B\$ from the library. "
fi
if [[ ${returnCodeC} -eq ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched ${lengthC} package name(s) of Classification \$C\$ from the library. "
else
	classificationC=""
	lengthC=0
	echo "Failed to fetch package names of Classification \$C\$ from the library. "
fi
if [[ ${returnCodeD} -eq ${EXIT_SUCCESS} ]];
then
	localDCount=0
	for packageName in $(pm list packages -3 | cut -d ':' -f2)
	do
		if ! echo -e -n "${classificationB}\n${classificationC}\n${classificationD}" | grep -qF "${packageName}";
		then
			localDCount=$(expr ${localDCount} + 1)
			classificationD="$(echo -e -n "${classificationD}\n${packageName}")"
		fi
	done
	originalLengthD=${lengthD}
	classificationD=$(echo -n "${classificationD}" | sort | uniq)
	if [[ -n "${classificationD}" ]];
	then
		lengthD=$(echo "${classificationD}" | wc -l)
	else
		lengthD=0
	fi
	echo "Successfully fetched ${lengthD} package name(s) of Classification \$D\$ from the library (${originalLengthD}) and the local machine (${localDCount}). "
else
	classificationD=""
	lengthD=0
	echo "Failed to fetch package names of Classification \$D\$ from the library. "
fi
if [[ ${returnCodeB} -eq ${EXIT_SUCCESS} ]];
then
	blacklistAppList="$(getArray "${classificationB}")"
	whitelistScopeList="$(getWhitelistScopeString "${classificationC}" "${classificationD}")"
else
	blacklistAppList=""
	whitelistScopeList=""
fi
if [[ ${returnCodeD} -eq ${EXIT_SUCCESS} ]];
then
	whitelistAppList=$(getArray "${classificationD}")
	if [[ ${returnCodeC} -eq ${EXIT_SUCCESS} ]];
	then
		blacklistScopeListC="$(getBlacklistScopeStringC "${classificationC}")"
		blacklistScopeListD="$(getBlacklistScopeStringD "${classificationD}" "${classificationC}")"
		if [[ -z "${blacklistScopeListC}" ]];
		then
			blacklistScopeList="${blacklistScopeListD}"
		else
			blacklistScopeList="${blacklistScopeListC},${blacklistScopeListD}"
		fi
	else
		blacklistScopeList=""
	fi
else
	whitelistAppList=""
	blacklistScopeList=""
fi
commonConfigContent="{\"configVersion\":90,\"forceMountData\":true,\"templates\":{\"${blacklistName}\":{\"isWhitelist\":false,\"appList\":[${blacklistAppList}]},\"${whitelistName}\":{\"isWhitelist\":true,\"appList\":[${whitelistAppList}]}},"
blacklistConfigContent="${commonConfigContent}\"scope\":{${blacklistScopeList}}}"
whitelistConfigContent="${commonConfigContent}\"scope\":{${whitelistScopeList}}}"
mkdir -p "${downloadFolderPath}"
if [[ $? -eq ${EXIT_SUCCESS} && -d "${downloadFolderPath}" ]];
then
	echo "Successfully prepared the folder \"${downloadFolderPath}\". "
	echo -n "${blacklistConfigContent}" > "${blacklistConfigurationFilePath}"
	if [[ $? -eq ${EXIT_SUCCESS} && -f "${blacklistConfigurationFilePath}" ]];
	then
		echo "Successfully generated the configuration file \"${blacklistConfigurationFilePath}\". "
	else
		exitCode=$(expr ${exitCode} \| 4)
		echo "Failed to generate the configuration file \"${blacklistConfigurationFilePath}\". "
	fi
	echo -n "${whitelistConfigContent}" > "${whitelistConfigurationFilePath}"
	if [[ $? -eq ${EXIT_SUCCESS} && -f "${whitelistConfigurationFilePath}" ]];
	then
		echo "Successfully generated the configuration file \"${whitelistConfigurationFilePath}\". "
	else
		exitCode=$(expr ${exitCode} \| 4)
		echo "Failed to generate the configuration file \"${whitelistConfigurationFilePath}\". "
	fi
else
	exitCode=$(expr ${exitCode} \| 4)
	echo "Failed to prepare the folder \"${downloadFolderPath}\". "
fi
if [[ -z "${blacklistAppList}" || -z "${blacklistScopeList}" || -z "${whitelistAppList}" || -z "${whitelistScopeList}" ]];
then
	echo "At least one list was empty. Please check the configurations generated before importing. "
fi
echo ""

# Tricky Store (0b00X000) #
echo "# Tricky Store (0b00X000) #"
readonly trickyStoreModuleId="tricky_store"
readonly trickyStoreConfigurationFolderPath="${adbFolder}/tricky_store"
readonly trickyStoreTargetFileName="target.txt"
readonly trickyStoreSecurityPatchFileName="security_patch.txt"
readonly trickyStoreTargetFilePath="${trickyStoreConfigurationFolderPath}/${trickyStoreTargetFileName}"
readonly trickyStoreSecurityPatchFilePath="${trickyStoreConfigurationFolderPath}/${trickyStoreSecurityPatchFileName}"
readonly classificationS="$(echo -e -n "com.google.android.gsf\ncom.google.android.gms\ncom.android.vending")"
readonly lengthS=$(echo "${classificationS}" | wc -l)
readonly patchContent="$(date +%Y%m01)"

if isModuleInstalled "${trickyStoreModuleId}" > /dev/null;
then
	echo "The Tricky Store module was installed. "
	if [[ -d "${trickyStoreConfigurationFolderPath}" ]];
	then
		echo "The Tricky Store configuration folder was found at \"${trickyStoreConfigurationFolderPath}\". "
		echo "${patchContent}" > "${trickyStoreSecurityPatchFilePath}"
		if [[ $? -eq ${EXIT_SUCCESS} && -f "${trickyStoreSecurityPatchFilePath}" ]];
		then
			echo "Successfully wrote \"${patchContent}\" to \"${trickyStoreSecurityPatchFilePath}\". "
		else
			exitCode=$(expr ${exitCode} \| 8)
			echo "Failed to write \"${patchContent}\" to \"${trickyStoreSecurityPatchFilePath}\". "
		fi
		abortFlag=${EXIT_SUCCESS}
		if [[ -f "${trickyStoreTargetFilePath}" ]];
		then
			echo "The Tricky Store target file was found at \"${trickyStoreTargetFilePath}\". "
			cp -fp "${trickyStoreTargetFilePath}" "${trickyStoreTargetFilePath}.bak"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${trickyStoreTargetFilePath}.bak" ]];
			then
				echo "Successfully copied \"${trickyStoreTargetFilePath}\" to \"${trickyStoreTargetFilePath}.bak\". "
			else
				abortFlag=${EXIT_FAILURE}
				echo "Failed to copy \"${trickyStoreTargetFilePath}\" to \"${trickyStoreTargetFilePath}.bak\". "
			fi
		else
			echo "The copying has been skipped since no Tricky Store target files were detected. "
		fi
		if [[ ${EXIT_SUCCESS} -eq ${abortFlag} ]];
		then
			lines="${classificationS}"
			if [[ -n "${classificationB}" ]];
			then
				lines="$(echo -e -n "${lines}\n$(echo -n "${classificationB}")")"
			fi
			if [[ -n "${classificationC}" ]];
			then
				lines="$(echo -e -n "${lines}\n$(echo -n "${classificationC}")")"
			fi
			if [[ -n "${classificationD}" ]];
			then
				lines="$(echo -e -n "${lines}\n$(echo -n "${classificationD}")")"
			fi
			classificationL="$(pm list packages | cut -d ':' -f 2)"
			if [[ -n "${classificationL}" ]];
			then
				lengthL=$(echo "${classificationL}" | wc -l)
				echo "Successfully fetched ${lengthL} package name(s) from the local machine. "
			else
				lengthL=0
				echo "No package names were fetched from the local machine. "
			fi
			if [[ -n "${classificationL}" ]];
			then
				lines="$(echo -e -n "${lines}\n$(echo -n "${classificationL}")")"
			fi
			lines=$(echo -n "${lines}" | sort | uniq)
			echo "${lines}" > "${trickyStoreTargetFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${trickyStoreTargetFilePath}" ]];
			then
				cnt=$(cat "${trickyStoreTargetFilePath}" | wc -l)
				echo "Successfully wrote ${cnt} target(s) to \"${trickyStoreTargetFilePath}\". "
				expectedCount=$(expr ${lengthS} + ${lengthB} + ${lengthC} + ${lengthD} + ${lengthL})
				if [[ ${cnt} -le ${expectedCount} ]];
				then
					echo "Successfully verified \"${trickyStoreTargetFilePath}\" (${cnt} <= ${expectedCount} = ${lengthS} + ${lengthB} + ${lengthC} + ${lengthD} + ${lengthL}). "
				else
					exitCode=$(expr ${exitCode} \| 8)
					echo "Failed to verify \"${trickyStoreTargetFilePath}\" (${cnt} > ${expectedCount} = ${lengthS} + ${lengthB} + ${lengthC} + ${lengthD} + ${lengthL}). "
				fi
			else
				exitCode=$(expr ${exitCode} \| 8)
				echo "Failed to write to \"${trickyStoreTargetFilePath}\". "
			fi
		fi
	else
		echo "No Tricky Store configuration folders were detected. "
	fi
else
	echo "The Tricky Store module was not installed. "
fi
echo ""

# Shell (0b0X0000) #
echo "# Shell (0b0X0000) #"
readonly sensitiveApplications="com.google.android.safetycore com.google.android.contactkeys"
readonly policiesToBeDeleted="hidden_api_policy hidden_api_policy_p_apps hidden_api_policy_pre_p_apps hidden_api_blacklist_exemptions"
readonly propertiesToBeSet="ro.boot.vbmeta.device_state:locked ro.boot.verifiedbootstate:green vendor.boot.secboot:enabled"
readonly propertiesToExist="ro.boot.vbmeta.avb_version ro.boot.vbmeta.hash_alg ro.boot.vbmeta.size ro.boot.vbmeta.digest"
readonly propertiesToBeDeleted="persist.sys.vold_app_data_isolation_enabled persist.zygote.app_data_isolation"
readonly persistentPropertyFilePath="/data/property/persistent_properties"
readonly directoryForTesting="/data/data/com.android.settings"
readonly plainUserExecution="$(echo -e "if [[ -n \"\${EXTERNAL_STORAGE}\" ]];\n\
then\n\
	readonly folders=\"/data/data /data/user/0 /data/user_de/0 \${EXTERNAL_STORAGE}/Android/data\"\n\
	readonly wxDownloadFolderPath=\"\${EXTERNAL_STORAGE}/Download/WechatXposed\"\n\
else\n\
	readonly folders=\"/data/data /data/user/0 /data/user_de/0 /sdcard/Android/data\"\n\
	readonly wxDownloadFolderPath=\"/sdcard/Download/WechatXposed\"\n\
fi\n\
for packageName in \$(cat \"${classificationFolderPath}/classificationB.txt\")\n\
do\n\
	for folder in \${folders}\n\
	do\n\
		leakedPath=\"\${folder}/\${packageName}\"
		if [[ -e \"\${leakedPath}\" ]];\n\
		then\n\
			echo \"- Found \\\"\${leakedPath}\\\" (Classification \\\$B\\\$). \"\n\
		fi\n\
	done\n\
done\n\
for packageName in \$(cat \"${classificationFolderPath}/classificationC.txt\")\n\
do\n\
	for folder in \${folders}\n\
	do\n\
		leakedPath=\"\${folder}/\${packageName}\"
		if [[ -e \"\${leakedPath}\" ]];\n\
		then\n\
			echo \"- Found \\\"\${leakedPath}\\\" (Classification \\\$C\\\$). \"\n\
		fi\n\
	done\n\
done\n\
test -e \"\${wxDownloadFolderPath}\" && echo \"- Found \\\"\${wxDownloadFolderPath}\\\". ")"
readonly bannedSubStrings="-AICP -arter97 -blu_spark -CAF -cm- -crDroid -crdroid -CyanogenMod -Deathly -EAS- -eas- -ElementalX -Elite -franco -hadesKernel -Lineage- -lineage- -LineageOS -lineageos -mokee -MoRoKernel -Noble -Optimus -SlimRoms -Sultan -sultan"
readonly sourceXmlFilePath="/etc/compatconfig/services-platform-compat-config.xml"
readonly replacementEntry="system"
readonly targetXmlFilePath="${replacementEntry}${sourceXmlFilePath}"

echo "The sensitive applications are being handled. "
sensitiveApplicationCount=0
disabledSensitiveApplicationCount=0
packageList="$(pm list packages)"
for sensitiveApplication in ${sensitiveApplications}
do
	if echo "${packageList}" | grep -qF "${sensitiveApplication}";
	then
		sensitiveApplicationCount=$(expr ${sensitiveApplicationCount} + 1)
		if pm disable "${sensitiveApplication}" &> /dev/null;
		then
			disabledSensitiveApplicationCount=$(expr ${disabledSensitiveApplicationCount} + 1)
			echo "- The sensitive application \"${sensitiveApplication}\" was detected, which has been disabled. "
		else
			exitCode=$(expr ${exitCode} \| 16)
			echo "- The sensitive application \"${sensitiveApplication}\" was detected, which failed to be disabled. "
		fi
	fi
done
if [[ ${sensitiveApplicationCount} -le 1 ]];
then
	echo "Successfully disabled ${disabledSensitiveApplicationCount} / ${sensitiveApplicationCount} sensitive application(s). "
else
	echo "No sensitive applications were found. "
fi
echo "The policies are being handled. "
for policyToBeDeleted in ${policiesToBeDeleted}
do
	executionContent="$(settings delete global ${policyToBeDeleted})"
	if [[ $? -eq ${EXIT_SUCCESS} && "${executionContent}" == "Deleted 0 rows" ]];
	then
		echo "- The execution of \`\`settings delete global ${policyToBeDeleted}\`\` succeeded. "
	else
		exitCode=$(expr ${exitCode} \| 16)
		echo "- The execution of \`\`settings delete global ${policyToBeDeleted}\`\` failed. "
	fi
done
echo "The properties are being handled. "
for propertyKeyValue in ${propertiesToBeSet}
do
	propertyKey="$(echo "${propertyKeyValue}" | cut -d ':' -f1)"
	propertyValue="$(echo "${propertyKeyValue}" | cut -d ':' -f2)"
	executionContent="$(getprop "${propertyKey}")"
	if [[ $? -eq ${EXIT_SUCCESS} && "${executionContent}" == "${propertyValue}" ]];
	then
		echo "- The value of \`\`${propertyKey}\`\` was \"${executionContent}\", which was proper. "
	else
		resetprop "${propertyKey}" "${propertyValue}"
		if [[ $? -eq ${EXIT_SUCCESS} && "$(getprop "${propertyKey}")" == "${propertyValue}" ]];
		then
			echo "- The value of \`\`${propertyKey}\`\` was \"${executionContent}\", which should be and successfully set to \"${propertyValue}\". "
		else
			echo "- The value of \`\`${propertyKey}\`\` was \"${executionContent}\", which should be but failed to set to \"${propertyValue}\". "
			exitCode=$(expr ${exitCode} \| 16)
		fi
	fi
done
propertyToExistFlag=${EXIT_SUCCESS}
for propertyToExist in ${propertiesToExist}
do
	if [[ -n "$(getprop "${propertyToExist}")" ]];
	then
		echo "- The property \"${propertyToExist}\" existed and its value was not empty, which was normal. "
	else
		propertyToExistFlag=${EXIT_FAILURE}
		echo "- The property \"${propertyToExist}\" did not exist or its value was empty, which was abnormal. "
	fi
done
for propertyToBeDeleted in ${propertiesToBeDeleted}
do
	resetprop --delete "${propertyToBeDeleted}"
	if [[ $? -eq ${EXIT_SUCCESS} || $? -eq 255 ]];
	then
		echo "- The execution of \`\`resetprop --delete \"${propertyToBeDeleted}\"\`\` succeeded. "
	else
		echo "- The execution of \`\`resetprop --delete \"${propertyToBeDeleted}\"\`\` failed. "
		exitCode=$(expr ${exitCode} \| 16)
	fi
done
if [[ -f "${persistentPropertyFilePath}" ]];
then
	sed -i '/persist\.sys\.vold_app_data_isolation_enabled/d; /persist\.zygote\.app_data_isolation/d' "${persistentPropertyFilePath}"
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "- Successfully removed persistent property traces from \"${persistentPropertyFilePath}\". "
	else
		echo "- Failed to remove persistent property traces from \"${persistentPropertyFilePath}\". "
	fi
else
	echo "- The persistent property file \"${persistentPropertyFilePath}\" did not exist. "
fi
if [[ ${propertyToExistFlag} -eq ${EXIT_FAILURE} ]];
then
	if [[ "${KSU}" == "true" || "${APATCH}" == "true" ]];
	then
		echo "Missing properties, please install the latest [VBMeta Fixer](https://github.com/reveny/Android-VBMeta-Fixer) module as a system module. "
	else
		echo "Missing properties, please install the latest [VBMeta Fixer](https://github.com/reveny/Android-VBMeta-Fixer) module. "
	fi
fi
if su -Z u:r:untrusted_app:s0 shell -c "test -e \"${directoryForTesting}\"";
then
	echo "Skipped checking the existence of applications in Classifications \$B\$ and \$C\$ that are leaked by the specified folders as a non-root user due to the unsupported environments. "
else
	echo "Checking the existence of applications in Classifications \$B\$ and \$C\$ leaked by the specified folders as a non-root user. "
	plainUserContent="$(su -Z u:r:untrusted_app:s0 shell -c "${plainUserExecution}")"
	if [[ $? -eq ${EOF} ]];
	then
		echo "Could not check the existence of applications in Classifications \$B\$ and \$C\$ that are leaked by the specified folders as a non-root user due to the EOF signal. "
	else
		echo "${plainUserContent}"
		if [[ -n "${plainUserContent}" ]];
		then
			echo "Found $(echo "${plainUserContent}" | wc -l) issue(s) during checking the existence of applications in Classifications \$B\$ and \$C\$ leaked by the specified folders as a plain user. "
		else
			echo "Congratulations on no applications in Classifications \$B\$ and \$C\$ leaked by the specified folders. "
		fi
	fi
fi
bannedSubStringFoundFlag=${EXIT_SUCCESS}
releaseVersion="$(uname -r)"
for bannedSubString in ${bannedSubStrings}
do
	if [[ "${releaseVersion}" == *"${bannedSubString}"* ]];
	then
		bannedSubStringFoundFlag=${EXIT_FAILURE}
		echo "Found the banned substring \"${bannedSubString}\" in the current release version \"${releaseVersion}\". "
		break
	fi
done
if [[ ${bannedSubStringFoundFlag} -eq ${EXIT_SUCCESS} ]];
then
	echo "No banned substrings were found in the current release version \"${releaseVersion}\". "
fi
if [[ -s "${sourceXmlFilePath}" ]];
then
	if grep -qF 'enableAfterTargetSdk="0" id="143937733"' "${sourceXmlFilePath}";
	then
		echo "The current \"${sourceXmlFilePath}\" is already a replaced one. "
	else
		echo "Generating replacement, the \"${sourceXmlFilePath}\" will be replaced after the device reboots. "
		targetXmlFolderPath="$(dirname "${targetXmlFilePath}")"
		if mkdir -p "${targetXmlFolderPath}";
		then
			echo "Successfully created the folder \"${targetXmlFolderPath}\". "
			toBeWritten=$(sed -E 's/(enableAfterTargetSdk=")[0-9]+(" id="143937733")/\10\2/g' "${sourceXmlFilePath}")
			echo -n "${toBeWritten}" > "${targetXmlFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${targetXmlFilePath}" ]];
			then
				echo "Successfully generated \"${targetXmlFilePath}\". "
			else
				exitCode=$(expr ${exitCode} \| 16)
				echo "Failed to generate \"${targetXmlFilePath}\". "
			fi
		else
			exitCode=$(expr ${exitCode} \| 16)
			echo "Failed to create the folder \"${targetXmlFolderPath}\". "
		fi
	fi
else
	echo "The \"${sourceXmlFilePath}\" did not exist or was found to be empty. "
	rm -rf "${replacementEntry}" && mkdir -p "${replacementEntry}"
	if [[ $? -eq ${EXIT_SUCCESS} && -d "${replacementEntry}" ]];
	then
		echo "Successfully removed replacement in this module. "
	else
		echo "Failed to remove replacement in this module. "
	fi
fi
androidVersion=$(getprop ro.build.version.release)
if [[ ${androidVersion} -ge 10 ]];
then
	settings put global show_hidden_icon_apps_enabled 0
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "Successfully enabled the feature of hiding desktop icons (Android ${androidVersion}). "
	else
		echo "Failed to enable the feature of hiding desktop icons (Android ${androidVersion}). "
	fi
fi
echo ""

# Update (0bX00000) #
echo "# Update (0bX00000) #"
readonly actionPropFileName="action.prop"
readonly actionPropFilePath="${webrootFolderPath}/${actionPropFileName}"
readonly currentAB="A"
readonly targetAB="B"
readonly targetAction="action${targetAB}.sh"
readonly actionUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/${targetAction}"
readonly actionDigestUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/${targetAction}.sha512"

shellDigest="$(curl -s "${actionDigestUrl}")"
if [[ $? -eq ${EXIT_SUCCESS} && -n "${shellDigest}" ]];
then
	echo "Successfully fetched the SHA-512 value of the latest \`\`${targetAction}\`\` from GitHub. "
	if [[ -f "${targetAction}" && "$(sha512sum "${targetAction}" | cut -d " " -f1)" == "${shellDigest}" ]];
	then
		echo "The target action \`\`${targetAction}\`\` is already up-to-date. "
		if [[ -f "${actionPropFilePath}" && "$(cat "${actionPropFilePath}")" == "${currentAB}" ]];
		then
			echo "The action slot remained ${currentAB}. "
		else
			echo "The action slot seemed inconsistent with the actual one. "
			rm -f "${actionPropFilePath}" && echo -n "${currentAB}" > "${actionPropFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${actionPropFilePath}" ]];
			then
				echo "Successfully synchronized the actual action slot to \"${actionPropFilePath}\". "
			else
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to synchronize the actual action slot to \"${actionPropFilePath}\". "
			fi
		fi
	else
		echo "The target action \`\`${targetAction}\`\` is out-of-date and needs to be updated. "
		shellContent="$(curl -s "${actionUrl}")"
		if [[ $? -eq ${EXIT_SUCCESS} && -n "${shellContent}" ]];
		then
			echo "Successfully fetched the latest \`\`${targetAction}\`\` from GitHub. "
			if [[ "$(echo "${shellContent}" | sha512sum | cut -d " " -f1)" == "${shellDigest}" ]];
			then
				echo "Successfully verified the latest \`\`${targetAction}\`\`. "
				if echo "${shellContent}" | sh -n;
				then
					echo "The latest \`\`${targetAction}\`\` successfully passed the local shell syntax check (sh). "
					rm -f "${targetAction}"
					echo "${shellContent}" > "${targetAction}"
					if [[ $? -eq ${EXIT_SUCCESS} && -f "${targetAction}" ]];
					then
						echo "Successfully updated \`\`${targetAction}\`\`. "
						rm -f "${actionPropFilePath}" && echo -n "${targetAB}" > "${actionPropFilePath}"
						if [[ $? -eq ${EXIT_SUCCESS} && -f "${actionPropFilePath}" ]];
						then
							echo "Successfully switched the action slot to ${targetAB} in \"${actionPropFilePath}\". "
						else
							exitCode=$(expr ${exitCode} \| 32)
							echo "Failed to switch the action slot to ${targetAB} in \"${actionPropFilePath}\". "
						fi
					else
						exitCode=$(expr ${exitCode} \| 32)
						echo "Failed to update \`\`${targetAction}\`\`. "
					fi
				else
					exitCode=$(expr ${exitCode} \| 32)
					echo "The latest \`\`${targetAction}\`\` failed to pass the local shell syntax check (sh). "
				fi
			else
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to verify the latest \`\`${targetAction}\`\`. "
			fi
		else
			exitCode=$(expr ${exitCode} \| 32)
			echo "Failed to fetch the latest \`\`${targetAction}\`\` from GitHub. "
		fi
	fi
else
	exitCode=$(expr ${exitCode} \| 32)
	echo "Failed to fetch the SHA-512 value of the latest \`\`${targetAction}\`\` from GitHub. "
fi
echo ""

# Exit #
readonly endTime=$(date +%s%N)
readonly timeDelta=$(expr ${endTime} - ${startTime} - ${gapTime})

if [[ ${EXIT_SUCCESS} -eq $(expr ${exitCode} \& ${EXIT_FAILURE}) ]];
then
	setPermissions && chmod 755 "${actionFolderPath}"
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "Successfully set permissions. "
	else
		exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
		echo "Failed to set permissions. "
	fi
fi
clearCaches
if [[ $? -eq ${EXIT_SUCCESS} ]];
then
	echo "Successfully cleared caches. "
else
	exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
	echo "Failed to clear caches. "
fi
echo "Finished executing the \`\`action.sh\`\` in $(expr ${timeDelta} / 1000000000).$(expr ${timeDelta} % 1000000000) second(s) (${exitCode}). "
exit ${exitCode}
