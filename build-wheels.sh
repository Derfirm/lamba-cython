#!/bin/bash
set -e -x

#cd $(dirname $0)
#
export PATH=/opt/python/cp38-cp38/bin/:$PATH
#
#curl -fsS -o get-poetry.py https://install.python-poetry.org
#python get-poetry.py --preview -y
#rm get-poetry.py
#
##for PYBIN in /opt/python/cp3*/bin; do
##  if [ "$PYBIN" == "/opt/python/cp34-cp34m/bin" ]; then
##    continue
##  fi
##  if [ "$PYBIN" == "/opt/python/cp35-cp35m/bin" ]; then
##    continue
##  fi
##  rm -rf build
##  "${PYBIN}/python" -m /root/.local/bin/poetry build -vvv
##done
#
#/root/.local/bin/poetry build -vvv
#rm -rf build
#
#cd dist
#for whl in *.whl; do
#    auditwheel repair "$whl"
#    rm "$whl"
#done



function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" -w /io/wheelhouse/
    fi
}

cd ./io

# Compile wheels
#for PYBIN in /opt/python/cp3[8-9]*/bin; do
##     "${PYBIN}/pip" install .
##     "${PYBIN}/pip" install pytest
#    "${PYBIN}/pip" wheel /io/ --no-deps -w wheelhouse/
#done

pip wheel /io/ --no-deps -w wheelhouse/

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done
