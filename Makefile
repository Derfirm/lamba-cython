CYTHON_SRC := $(shell find _cython -name '*.pyx')

CYTHON_DIRECTIVES = -Xlanguage_level=3

ifdef PICKLESTRUCT_DEBUG_MODE
	CYTHON_DIRECTIVES += -Xprofile=True
	CYTHON_DIRECTIVES += -Xlinetrace=True
endif

POETRY ?= $(HOME)/.local/bin/poetry
POETRY_VERSION = 1.2.0


.PHONY: install-poetry
install-poetry:
	echo $(POETRY_VERSION)
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

.PHONY: install-packages
install-packages:
	$(POETRY) install -vv $(opts)

.PHONY: install
install: install-poetry install-packages

.PHONY: update
update:
	$(POETRY) update -v

.PHONE: fmt
fmt:
	$(POETRY) run black .
	$(POETRY) run isort .

clean:
	$(POETRY) run python setup.py clean
	# Clean sources
	find _cython -name '*.o' -delete
	find _cython -name '*.py[cod]' -delete
	find _cython -name '__pycache__' -delete
	find _cython -name '*.c' -delete
	find _cython -name '*.h' -delete
	find _cython -name '*.so' -delete
	find _cython -name '*.html' -delete
	# Clean tests
	find tests -name '*.py[co]' -delete
	find tests -name '__pycache__' -delete
	# clean build
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find _cython -name '*.egg-info' -exec rm -fr {} +
	find _cython -name '*.egg' -exec rm -rf {} +


cythonize:
	# Compile Cython to C
	$(POETRY) run cython -a $(CYTHON_DIRECTIVES) $(CYTHON_SRC)
	# Move all Cython html reports
	mkdir -p reports/cython/
	find _cython -name '*.html' -exec mv {}  reports/cython/  \;

build: clean cythonize
	$(POETRY) run python setup.py build_ext --inplace


check:
	$(POETRY) run flake8 _cython _python
	$(POETRY) run mypy _cython _python

package: build
	$(POETRY) run python setup.py sdist bdist_wheel
