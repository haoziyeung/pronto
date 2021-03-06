#coverage run tests/doctests.py --source pronto
#coverage xml --include 'pronto/*'

TOKEN=`cat ./.codacy.token`
PROFILE_FUNC="import pstats as p; f=open('profile.cprof', 'w'); p.Stats('p.tmp',stream=f).print_stats()"


#.PHONY: all
#all:
#	nuitka pronto --module --nofreeze-stdlib --recurse-to=pronto --enhanced --lto --verbose


.PHONY: test
.SILENT: test
test:
	python -m unittest discover -v

#.PHONY: profile
#.SILENT: profile
#profile:
#	python -m cProfile -o '../profile.cprof' tests/doctests.py
#	#echo "Converting profile..."
#	#python -c ${PROFILE_FUNC}
#	#echo "Cleaning..."
#	#rm ./p.tmp
#	pyprof2calltree -k -i profile.cprof


.PHONY: cover
.SILENT: cover
ifndef CODACY_PROJECT_TOKEN
cover:
	export CI=true
	coverage run --source=pronto -m unittest discover
	coverage combine
	coverage xml --include 'pronto/*'
	export CODACY_PROJECT_TOKEN=${TOKEN} && python-codacy-coverage -r coverage.xml
else
cover:
	export CI=true
	coverage run --source pronto -m unittest discover
	coverage xml --include 'pronto/*'
	python-codacy-coverage -r coverage.xml
endif


.PHONY: install
install:
	pip install -r requirements.txt
	pip install .

.PHONY: doc
.SILENT: doc
doc:
	pip install -r requirements-doc.txt -q
	echo $$TARGET
	cd docs && make $(filter-out $@,$(MAKECMDGOALS))

.PHONY: clean
.SILENT: clean
clean:
	if [ -d build ]; then rm -rd build; fi
	if [ -d dist ]; then rm -rd dist; fi
	rm -rf docs/build/*
	rm -rf tests/run
	rm -rf .coverage*
	if [ -d pronto.egg-info ]; then rm -rf pronto.egg-info/; fi
	rm -f ./*.whl
	if [ -f coverage.xml ]; then rm coverage.xml; fi
	if [ -f .coverage ]; then rm .coverage; fi
	if [ -f profile.cprof ]; then rm profile.cprof; fi
	echo "Done cleaning."

.PHONY: upload
upload:
	@python setup.py sdist bdist_wheel upload

# targets of Sphinx makefile
.PHONY: html xml pdf dirhtml singlehtml pickle json htmlhelp
.PHONY: qthelp applehelp devhelp epub epub3 latex latexpdf
.PHONY: latexpdfja text man texinfo info gettext changes
.PHONY: pseudoxml linkcheck doctest coverage dummy

# open browser after html generation
html:
	${BROWSER} docs/build/html/index.html

ifdef EDITOR
coverage:
	${EDITOR} docs/build/coverage/python.txt
endif


.PHONY: compile
.SILENT: compile
compile:
	[ -d build ] || mkdir build
	cd build
	nuitka --module ../pronto --recurse-all --recurse-stdlib \
	--improved --lto --show-modules --nofreeze-stdlib \
	--recurse-directory=../pronto

.PHONY: monitor
.SILENT: monitor
monitor:
	LATEST_BUILD=`travis status | xargs python -c "import sys; print(sys.argv[1][1:])"`
	clear && tput cup 1 0
	while true; do travis show $$LATEST_BUILD; tput cup 1 0; done
