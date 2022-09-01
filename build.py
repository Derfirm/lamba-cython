import os
import shutil
from distutils.command.build_ext import build_ext
from distutils.core import Extension
from distutils.errors import CCompilerError, DistutilsExecError, DistutilsPlatformError

# gcc arguments hack: enable optimizations
os.environ["CFLAGS"] = "-O3"


class BuildFailed(Exception):
    pass


class ExtBuilder(build_ext):
    # This class allows C extension building to fail.

    built_extensions = []

    def run(self):
        try:
            build_ext.run(self)
        except (DistutilsPlatformError, FileNotFoundError):
            print(
                "  Unable to build the C extensions, "
                "Pendulum will use the pure python code instead."
            )

    def build_extension(self, ext):
        try:
            build_ext.build_extension(self, ext)
        except (CCompilerError, DistutilsExecError, DistutilsPlatformError, ValueError):
            print(
                f'  Unable to build the "{ext.name}" C extension, '
                "Pendulum will use the pure python version of the extension."
            )


# See if Cython is installed
try:
    from Cython.Build import cythonize
# Do nothing if Cython is not available
except ImportError:
    # Got to provide this function. Otherwise, poetry will fail
    def build(setup_kwargs):
        pass


# Cython is installed. Compile
else:
    from distutils.command.build_ext import build_ext

    from setuptools import Extension
    from setuptools.dist import Distribution

    cython_macros = [("CYTHON_TRACE", "1"), ("CYTHON_TRACE_NOGIL", "1")]
    # This function will be executed in setup.py:

    def build(setup_kwargs):
        # The file you want to compile
        extensions = [
            Extension(
                "cython_m.hello", ["cython_m/hello.pyx"], define_macros=cython_macros
            ),
        ]
        # Build

        distribution = Distribution(
            {
                "name": "cython_m",
                "ext_modules": cythonize(
                    extensions,
                    language_level=3,
                    compiler_directives={"linetrace": True},
                ),
            }
        )
        distribution.package_dir = "cython_m"

        cmd = ExtBuilder(distribution)
        cmd.ensure_finalized()
        cmd.run()

        # Copy built extensions back to the project
        for output in cmd.get_outputs():
            relative_extension = os.path.relpath(output, cmd.build_lib)
            if not os.path.exists(output):
                continue

            shutil.copyfile(output, relative_extension)
            mode = os.stat(relative_extension).st_mode
            mode |= (mode & 0o444) >> 2
            os.chmod(relative_extension, mode)

        return setup_kwargs
