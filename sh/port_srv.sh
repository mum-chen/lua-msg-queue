#!
CMD=$1
PORT=$2

if [ ${CMD} = checkport ];	then
	lsof -ni :${PORT} >/dev/null 2>&1 && {
        echo used
        exit 0
    }
else
	echo null-cmd
	exit 0
fi
