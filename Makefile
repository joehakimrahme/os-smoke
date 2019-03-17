test: test-bash test-dash test-ksh test-sh

test-bash:
	shellcheck -s bash smoke.sh

test-dash:
	shellcheck -s dash smoke.sh

test-ksh:
	shellcheck -s ksh smoke.sh

test-sh:
	shellcheck -s sh smoke.sh
