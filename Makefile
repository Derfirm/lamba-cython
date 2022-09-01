CYTHON_SRC := $(shell find cython_m -name '*.pyx')

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
	$(POETRY) run black cython_m python_m python_lambda tests
	$(POETRY) run isort cython_m python_m python_lambda tests


clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find cython_m -name '*.egg-info' -exec rm -fr {} +
	find cython_m -name '*.egg' -exec rm -rf {} +

clean-source:
	rm -fr cython_m/__pycache__/
	rm -fr python_m/__pycache__/
	rm -fr python_lambda/__pycache__/
	find cython_m -name '*.o' -delete
	find cython_m -name '*.py[cod]' -delete
	find cython_m -name '__pycache__' -delete
	find cython_m -name '*.c' -delete
	find cython_m -name '*.h' -delete
	find cython_m -name '*.so' -delete
	find cython_m -name '*.html' -delete

clean-serverless:
	rm -rf .serverless/

clean-tests:
	find tests -name '*.py[co]' -delete
	find tests -name '__pycache__' -delete

clean: clean-build clean-source clean-serverless

cythonize:
	# Compile Cython to C
	$(POETRY) run cython -a $(CYTHON_DIRECTIVES) $(CYTHON_SRC)
	# Move all Cython html reports
	mkdir -p reports/cython/
	find cython_m -name '*.html' -exec mv {}  reports/cython/  \;


check:
	$(POETRY) run flake8 cython_m python_m
	$(POETRY) run mypy cython_m python_


wheel:
	@poetry build -v

deploy: build_wheels_aarch64
	AWS_PROFILE=lambda serverless deploy --stage test --force

invoke:
	AWS_PROFILE=lambda serverless invoke --function hello-cython --stage test

invoke-python:
	AWS_PROFILE=lambda serverless invoke --function hello-python --stage test

build_wheels_aarch64:
	docker pull quay.io/pypa/manylinux2014_aarch64
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux2014_aarch64 /io/build-wheels.sh


# test wheels build, no needed for release
wheels_x64: build_wheels_x64 build_wheels_aarch64

wheels_i686: build_wheels_i686

build_wheels_x64:
	docker pull quay.io/pypa/manylinux1_x86_64
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels.sh

build_wheels_i686:
	docker pull quay.io/pypa/manylinux1_i686
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_i686 /io/build-wheels.sh

build_wheels_2_x86_64:
	docker pull quay.io/pypa/manylinux_2_28_x86_64
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux_2_28_x86_64 /io/build-wheels.sh


