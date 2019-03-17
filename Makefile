test: test-bash test-dash test-ksh test-sh

test-bash:
	shellcheck -s bash os-smoke.sh

test-dash:
	shellcheck -s dash os-smoke.sh

test-ksh:
	shellcheck -s ksh os-smoke.sh

test-sh:
	shellcheck -s sh os-smoke.sh
