if [ -n "$1" ]; then
  ${ME} $1 -h
else
  cat <<EOF
attach       - attach a file to a pr
claim        - take all unassigned prs from a submitter
close        - close a pr
comment      - comment on a pr
get          - get a pr locally
edit         - edit a pr
help         - display this message
init         - collect info and initialize config files
inprog       - mark a pr in progress
login        - login to bugzilla
overto       - reassign a pr to someone
patch        - patch a port
port_commit  - COMMIT a pr [will be prompted]
port_submit  - submit a pr with shar/patch for a port
search       - search prs
show         - display a pr and primary attachment to STDOUT
src_submit   - submit a pr with patch for src
take         - assign a pr to yourself
timeout      - comment on a pr stating maintainer and timeout duration
top          - show top assignee / reporters
version      - display software version
EOF
fi
