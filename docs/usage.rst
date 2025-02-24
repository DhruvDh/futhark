.. _usage:

Basic Usage
===========

Futhark contains several code generation backends.  Each is provided
as subcommand of the ``futhark`` binary.  For example, ``futhark c``
compiles a Futhark program by translating it to sequential C code,
while ``futhark pyopencl`` generates Python code with calls to the
PyOpenCL library.  The different compilers all contain the same
frontend and optimisation pipeline - only the code generator is
different.  They all provide roughly the same command line interface,
but there may be minor differences and quirks due to characteristics
of the specific backends.

There are two main ways of compiling a Futhark program: to an
executable (by using ``--executable``, which is the default), and to a
library (``--library``).  Executables can be run immediately, but are
useful mostly for testing and benchmarking.  Libraries can be called
from non-Futhark code.

Compiling to Executable
-----------------------

A Futhark program is stored in a file with the extension ``.fut``.  It
can be compiled to an executable program as follows::

  $ futhark c prog.fut

This makes use of the ``futhark c`` compiler, but any other will work
as well.  The compiler will automatically invoke ``gcc`` to produce an
executable binary called ``prog``.  If we had used ``futhark py``
instead of ``futhark c``, the ``prog`` file would instead have
contained Python code, along with a `shebang`_ for easy execution.  In
general, when compiling file ``foo.fut``, the result will be written
to a file ``foo`` (i.e. the extension will be stripped off).  This can
be overridden using the ``-o`` option.  For more details on specific
compilers, see their individual manual pages.

.. _shebang: https://en.wikipedia.org/wiki/Shebang_%28Unix%29

Executables generated by the various Futhark compilers share a common
command-line interface, but may also individually support more
options.  When a Futhark program is run, execution starts at one of
its *entry points*.  By default, the entry point named ``main`` is
run.  An alternative entry point can be indicated by using the ``-e``
option.  All entry point functions must be declared appropriately in
the program (see :ref:`entry-points`).  If the entry point takes any
parameters, these will be read from standard input in a subset of the
Futhark syntax.  A binary input format is also supported; see
:ref:`binary-data-format`.  The result of the entry point is printed
to standard output.

Only a subset of all Futhark values can be passed to an executable.
Specifically, only primitives and arrays of primitive types are
supported.  In particular, nested tuples and arrays of tuples are not
permitted.  Non-nested tuples are supported are supported as simply
flat values.  This restriction is not present for Futhark programs
compiled to libraries.  If an entry point *returns* any such value,
its printed representation is unspecified.  As a special case, an
entry point is allowed to return a flat tuple.

Instead of compiling, there is also an interpreter, accessible as
``futhark run`` and ``futhark repl``.  The latter is an interactive
prompt, useful for experimenting with Futhark expressions.  Be aware
that the interpreter runs code very slowly.


.. _executable-options:

Executable Options
^^^^^^^^^^^^^^^^^^

All generated executables support the following options.

  ``-t FILE``

    Print the time taken to execute the program to the indicated file,
    an integral number of microseconds.  The time taken to perform setup
    or teardown, including reading the input or writing the result, is
    not included in the measurement.  See the documentation for specific
    compilers to see exactly what is measured.

  ``-r RUNS``

    Run the specified entry point the given number of times (plus a
    warmup run).  The program result is only printed once, after the
    last run.  If combined with ``-t``, one measurement is printed per
    run.  This is a good way to perform benchmarking.

  ``-D``

    Print debugging information on standard error.  Exactly what is
    printed, and how it looks, depends on which Futhark compiler is
    used.  This option may also enable more conservative (and slower)
    execution, such as frequently synchronising to check for errors.

  ``-b``

    Print the result using the binary data format
    (:ref:`binary-data-format`).  For large outputs, this is
    significantly faster and takes up less space.

Parallel Options
~~~~~~~~~~~~~~~~

The following options are supported by executables generated with the
parallel backends (``opencl``, ``pyopencl``, ``csopencl``, and
``cuda``).

  ``--tuning=FILE``

    Load tuning options from the indicated *tuning file*.  The file
    must contain lines of the form ``SIZE=VALUE``, where each *SIZE*
    must be one of the sizes listed by the ``--print-sizes`` option
    (without size class), and the *VALUE* must be a non-negative
    integer.  Extraneous spaces or blank lines are not allowed.  A zero
    means to use the default size, whatever it may be.  In case of
    duplicate assignments to the same size, the last one takes
    predecence.  This is equivalent to passing each size setting on
    the command like using the ``--size`` option, but more convenient.

  ``--print-sizes``

    Print a list of tunable sizes followed by their *size class* in
    parentheses, which indicates what they are used for.

  ``--size=SIZE=VALUE``

    Set one of the tunable sizes to the given value.  Using the
    ``--tuning`` option is more convenient.

OpenCL-specific Options
~~~~~~~~~~~~~~~~~~~~~~~

The following options are supported by executables generated with the
OpenCL backends (``opencl``, ``pyopencl``, and ``csopencl``):

  ``-P``

    Measure the time taken by various OpenCL operations (such as
    kernels) and print a summary at the end.  Unfortunately, it is
    currently nontrivial (and manual) to relate these operations back
    to source Futhark code.

  ``-p PLATFORM``

    Pick the first OpenCL platform whose name contains the given
    string.  The special string ``#k``, where ``k`` is an integer, can
    be used to pick the *k*-th platform, numbered from zero.

  ``-d DEVICE``

    Pick the first OpenCL device whose name contains the given string.
    The special string ``#k``, where ``k`` is an integer, can be used
    to pick the *k*-th device, numbered from zero.  If used in
    conjunction with ``-p``, only the devices from matching platforms
    are considered.

  ``--default-group-size INT``

    The default size of OpenCL workgroups that are launched.  Capped
    to the hardware limit if necessary.

  ``--default-num-groups INT``

    The default number of OpenCL workgroups that are launched.

  ``--dump-opencl FILE``

    Don't run the program, but instead dump the embedded OpenCL
    program to the indicated file.  Useful if you want to see what is
    actually being executed.

  ``--load-opencl FILE``

    Instead of using the embedded OpenCL program, load it from the
    indicated file.  This is extremely unlikely to result in succesful
    execution unless this file is the result of a previous call to
    ``--dump-opencl`` (perhaps lightly modified).

  ``--dump-opencl-binary FILE``

    Don't run the program, but instead dump the compiled version of
    the embedded OpenCL program to the indicated file.  On NVIDIA
    platforms, this will be PTX code.  If this option is set, no entry
    point will be run.

  ``--load-opencl-binary FILE``

    Load an OpenCL binary from the indicated file.

  ``--build-option OPT``

    Add an additional build option to the string passed to
    ``clBuildProgram()``.  Refer to the OpenCL documentation for which
    options are supported.  Be careful - some options can easily
    result in invalid results.

There is rarely a need to use both ``-p`` and ``-d``.  For example, to
run on the first available NVIDIA GPU, ``-p NVIDIA`` is sufficient, as
there is likely only a single device associated with this platform.
On \*nix (including macOS), the `clinfo
<https://github.com/Oblomov/clinfo>`_ tool (available in many package
managers) can be used to determine which OpenCL platforms and devices
are available on a given system.  On Windows, `CPU-z
<https://www.cpuid.com/softwares/cpu-z.html>`_ can be used.

CUDA-specific Options
~~~~~~~~~~~~~~~~~~~~~

The following options are supported by executables generated by the
``cuda`` backend:

  ``--dump-cuda FILE``

    Don't run the program, but instead dump the embedded CUDA program
    to the indicated file.  Useful if you want to see what is actually
    being executed.

  ``--load-cuda FILE``

    Instead of using the embedded CUDA program, load it from the
    indicated file.  This is extremely unlikely to result in succesful
    execution unless this file is the result of a previous call to
    ``--dump-cuda`` (perhaps lightly modified).

  ``--dump-ptx FILE``

    As ``--dump-cuda``, but dumps the compiled PTX code instead.

  ``--load-ptx FILE``

    Instead of using the embedded CUDA program, load compiled PTX code
    from the indicated file.

  ``--nvrtc-option=OPT``

    Add the given option to the command line used to compile CUDA
    kernels with NVRTC.  The list of supported options varies with the
    CUDA version but can be `found in the NVRTC
    documentation
    <https://docs.nvidia.com/cuda/nvrtc/index.html#group__options>`_.

For convenience, CUDA executables also accept the same
``--default-num-groups`` and ``--default-group-size`` options that the
OpenCL backend uses.  These then refer to grid size and thread block
size, respectively.

Compiling to Library
--------------------

While compiling a Futhark program to an executable is useful for
testing, it is not suitable for production use.  Instead, a Futhark
program should be compiled into a reusable library in some target
language, enabling integration into a larger program.  Five of the
Futhark compilers support this: ``futhark c``, ``futhark opencl``, ``futhark cuda``,
``futhark py``, and ``futhark pyopencl``.

General Concerns
^^^^^^^^^^^^^^^^

Futhark entry points are mapped to some form of function or method in
the target language.  Generally, an entry point taking *n* parameters
will result in a function taking *n* parameters.  Extra parameters may
be added to pass in context data, or *out*-parameters for writing the
result, for target languages that do not support multiple return
values from functions.

Not all Futhark types can be mapped cleanly to the target language.
Arrays of tuples, for example, are a common issue.  In such cases, *opaque
types* are used in the generated code.  Values of these types cannot
be directly inspected, but can be passed back to Futhark entry points.
In the general case, these types will be named with a random hash.
However, if you insert an explicit type annotation (and the type
name contains only characters valid for identifiers for the used
backend), the indicated name will be used.  Note that arrays contain
brackets, which are usually not valid in identifiers.  Defining a
simple type alias is the best way around this.

Generating C
^^^^^^^^^^^^

A Futhark program ``futlib.fut`` can be compiled to reusable C code
using either::

  $ futhark c --library futlib.fut

Or::

  $ futhark opencl --library futlib.fut

This produces two files in the current directory: ``futlib.c`` and
``futlib.h``.  If we wish (and are on a Unix system), we can then
compile ``futlib.c`` to a shared library like this::

  $ gcc dotprod.c -o libdotprod.so -fPIC -shared

However, details of how to link the generated code with other C code
is highly system-dependent, and outside the scope of this manual.

The generated header file (here, ``futlib.h``) specifies the API, and
is intended to be human-readable.  The basic usage revolves around
creating a *configuration object*, which can then be used to obtain a
*context object*, which must be passed whenever entry points are
called.

The configuration object is created using the following function::

  struct futhark_context_config *futhark_context_config_new();

Depending on the backend, various functions are generated to modify
the configuration.  The following is always available::

  void futhark_context_config_set_debugging(struct futhark_context_config *cfg,
                                            int flag);

A configuration object can be used to create a context with the
following function::

  struct futhark_context *futhark_context_new(struct futhark_context_config *cfg);

Memory management is entirely manual.  Deallocation functions are
provided for all types defined in the header file.  Everything
returned by an entry point must be manually deallocated.

Functions that can fail return an integer: 0 on success and a non-zero
value on error.  A human-readable string describing the error can be
retrieved with the following function::

  char *futhark_context_get_error(struct futhark_context *ctx);

It is the caller's responsibility to ``free()`` the returned string.
Any subsequent call to the function returns ``NULL``, until a new
error occurs.

For now, many internal errors, such as failure to allocate memory,
will cause the function to ``abort()`` rather than return an error
code.  However, all application errors (such as bounds and array size
checks) will produce an error code.

The API functions are thread safe.

C with OpenCL
~~~~~~~~~~~~~

When generating C code with ``futhark opencl`` (which is likely the
common case), extra API functions are provided for directly accessing
or providing the OpenCL objects used by Futhark.  Take care when using
these functions.  In particular, a Futhark context can now be provided
with the command queue to use::

  struct futhark_context *futhark_context_new_with_command_queue(struct futhark_context_config *cfg, cl_command_queue queue);

As a ``cl_command_queue`` specifies an OpenCL device, this is also how
manual platform and device selection is possible.  A function is also
provided for retrieving the command queue used by some Futhark
context::

  cl_command_queue futhark_context_get_command_queue(struct futhark_context *ctx);

This can be used to connect two separate Futhark contexts that have
been loaded dynamically.

The raw ``cl_mem`` object underlying a Futhark array can be accessed
with the function named ``futhark_values_raw_type``, where ``type``
depends on the array in question.  For example::

  cl_mem futhark_values_raw_i32_1d(struct futhark_context *ctx, struct futhark_i32_1d *arr);

The array will be stored in row-major form in the returned memory
object.  The function performs no copying, so the ``cl_mem`` still
belongs to Futhark, and may be reused for other purposes when the
corresponding array is freed.  A dual function can be used to
construct a Futhark array from a ``cl_mem``::

  struct futhark_i32_1d *futhark_new_raw_i32_1d(struct futhark_context *ctx,
                                                cl_mem data,
                                                int offset,
                                                int dim0);

This function *does* copy the provided memory into fresh internally
allocated memory.  The array is assumed to be stored in row-major form
``offset`` bytes into the memory region.

Generating Python
^^^^^^^^^^^^^^^^^

The ``futhark py`` and ``futhark pyopencl`` compilers both support
generating reusable Python code, although the latter of these
generates code of sufficient performance to be worthwhile.  The
following mentions options and parameters only available for
``futhark pyopencl``.  You will need at least PyOpenCL version 2015.2.

We can use ``futhark pyopencl`` to translate the program
``futlib.fut`` into a Python module ``futlib.py`` with the following
command::

  $ futhark pyopencl --library futlib.fut

This will create a file ``futlib.py``, which contains Python code that
defines a class named ``futlib``.  This class defines one method for
each entry point function (see :ref:`entry-points`) in the Futhark
program.  The methods take one parameter for each parameter in the
corresponding entry point, and return a tuple containing a value for
every value returned by the entry point.  For entry points returning a
single (non-tuple) value, just that value is returned (that is,
single-element tuples are not returned).

After the class has been instantiated, these methods can be invoked to
run the corresponding Futhark function.  The constructor for the class
takes various keyword parameters:

  ``interactive=BOOL``

    If ``True`` (the default is ``False``), show a menu of available
    OpenCL platforms and devices, and use the one chosen by the user.

  ``platform_pref=STR``

    Use the first platform that contains the given string.  Similar to
    the ``-p`` option for executables.

  ``device_pref=STR``

    Use the first device that contains the given string.  Similar to
    the ``-d`` option for executables.

Futhark arrays are mapped to either the Numpy ``ndarray`` type or the
`pyopencl.array <https://documen.tician.de/pyopencl/array.html>`_
type.  Scalars are mapped to Numpy scalar types.
