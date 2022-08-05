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
    name="picklestruct",
    packages=packages,
    # cmdclass={"build_ext": build_ext},
    ext_modules=extensions,
    # ext_package='picklestruct',
    # py_modules=["picklestruct"],
    # package_dir={"picklestruct": "picklestruct"},
    # packages=find_packages(where=".", include=["picklestruct"]),
)
