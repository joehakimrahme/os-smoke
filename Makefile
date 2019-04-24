test: test-bash test-dash test-ksh test-sh

test-bash:
	shellcheck -s bash -x ./common.sh os-smoke.sh os-unsmoke.sh

test-dash:
	shellcheck -s dash -x ./common.sh os-smoke.sh os-unsmoke.sh

test-ksh:
	shellcheck -s ksh -x ./common.sh os-smoke.sh os-unsmoke.sh

test-sh:
	shellcheck -s sh -x ./common.sh os-smoke.sh os-unsmoke.sh
