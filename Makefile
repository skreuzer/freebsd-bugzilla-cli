NAME=	bz
PREFIX?=	/usr/local
DATADIR_REL?=	share/${NAME}
DATADIR?=	${PREFIX}/${DATADIR_REL}

BSD_INSTALL_SCRIPT?=    install -m 555
BSD_INSTALL_DATA?=      install -m 444

MKDIR?=	/bin/mkdir -p

BACKENDS=	pybugz

install:
	@${MKDIR} ${DESTDIR}${PREFIX}/bin
	${BSD_INSTALL_SCRIPT} bin/${NAME} ${DESTDIR}${PREFIX}/bin
	@${MKDIR} ${DESTDIR}${DATADIR}
	${BSD_INSTALL_SCRIPT} ${DATADIR_REL}/*.sh ${DESTDIR}${DATADIR}
.for i in ${BACKENDS}
	@${MKDIR} ${DESTDIR}${DATADIR}/${i}
	${BSD_INSTALL_SCRIPT} ${DATADIR_REL}/${i}/* ${DESTDIR}${DATADIR}/${i}
.endfor

release:
	sed -i '' -e "s,BZ_VERSION=.*,BZ_VERSION=${VERSION}," ${DATADIR_REL}/_version.sh
	git add ${DATADIR_REL}/version.sh
	git commit -m "Tag ${VERSION}"
	git tag ${VERSION}
	git push --tags
	git push

.PHONY: install release
