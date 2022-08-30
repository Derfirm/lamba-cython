import os

os.environ["CFLAGS"] = "-O3"
from setuptools import Extension, setup

cython_macros = [("CYTHON_TRACE", "1"), ("CYTHON_TRACE_NOGIL", "1")]
cython_directives = {
    "profile": True,
    "linetrace": True,
    "boundscheck": False,
    "wraparound": False,
    "cdivision": True,
    "embedsignature": True,
}


packages = ["picklestruct"]
extensions = [
    Extension("_cython.hello", ["_cython/hello.pyx"], define_macros=cython_macros),
]


setup(
    setup_requires=['wheel'],
    name="picklestruct",
    packages=packages,
    ext_modules=extensions,

)
