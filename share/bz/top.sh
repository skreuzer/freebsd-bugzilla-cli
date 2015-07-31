. ${BZ_BACKENDDIR}/top.sh

field=$1
limit=${2:-10}

bztop $field $limit
