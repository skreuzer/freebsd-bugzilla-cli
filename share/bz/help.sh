cmds=$(ls -1 ${BZ_SCRIPTDIR} | grep .sh$ | grep -v ^_ | sed -e 's,.sh, ,g' -e 's,|$,,')

echo $cmds
