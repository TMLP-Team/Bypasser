#/system/bin/sh
EXIT_SUCCESS=0
EXIT_FAILURE=1
EOF=255
moduleName=Bypasser
currentWorkingDirectory=$(pwd)
ui_print "Welcome to the installer of the ${moduleName} Magisk Module! "

# Magisk #
if ! $BOOTMODE;
then
	ui_print "Warning: Installing from recovery does not make sense currently. "
fi

# Action #
chmod +x ./action.sh
actionStrings=$(./action.sh)
exitCode=$?
if [[ ${EXIT_SUCCESS} == ${exitCode} ]];
then
	ui_print "Successfully executed the \`\`action.sh\`\`. "
else
	ui_print "Warning: The execution of \`\`action.sh\`\` returned a non-zero exit code (${exitCode}). "
fi
if [[ -z "${MAGISK_VER_CODE}" ]];
then
	ui_print "Warning: Cannot guarantee whether the action button is supported. "
	ui_print "Warning: Maybe you can update configurations only by flashing a newer version. "
else
	if [[ ${MAGISK_VER_CODE} -ge 28000 ]];
	then
		ui_print "The action button is supported (${MAGISK_VER_CODE}). "
	else
		ui_print "Warning: The action button is not supported (${MAGISK_VER_CODE}). "
		ui_print "Warning: Maybe you can update configurations only by flashing a newer version. "
		ui_print "Warning: Please try to use the latest manager (Magisk: \${MAGISK_VER_CODE}>= 28000). "
	fi
fi
