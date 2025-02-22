#!/system/bin/sh
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EOF=255
readonly moduleName="Bypasser"
readonly moduleId="bypasser"
readonly moduleFolderPath="$(dirname "$0")"

function clearCaches
{
	sync && echo 3 > /proc/sys/vm/drop_caches
	return $?
}

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

clearCaches &> /dev/null
chmod 755 "${moduleFolderPath}" 2>/dev/null && cd "${moduleFolderPath}" 2>/dev/null
setPermissions &> /dev/null

setPermissions &> /dev/null 2>/dev/null && chmod 755 "${moduleFolderPath}" 2>/dev/null
clearCaches &> /dev/null
exit ${EXIT_SUCCESS}
