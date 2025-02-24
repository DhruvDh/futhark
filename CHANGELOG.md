# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.13.0]

### Added

### Removed

### Changed

### Fixed

  * Various small fixes to type errors.

## [0.12.2]

### Added

  * New tool: `futhark autotune`, for tuning the threshold parameters
    used by incremental flattening.  Based on work by Svend Lund
    Breddam, Simon Rotendahl, and Carl Mathias Graae Larsen.

  * New tool: `futhark dataget`, for extracting test input data.  Most
    will probably never use this.

  * Programs compiled with the `cuda` backend now take options
    `--default-group-size`, `--default-num-groups`, and
    `--default-tile-size`.

  * Segmented `reduce_by_index` are now substantially fasted for small
    histograms.

  * New functions: `f32.lerp` and `f64.lerp`, for linear interpolation.

### Fixed

  * Fixes to aliasing of record updates.

  * Fixed unnecessary array duplicates after coalescing optimisations.

  * `reduce_by_index` nested in `map`s will no longer sometimes
    require huge amounts of memory.

  * Source location now correct for unknown infix operators.

  * Function parameters are no longer in scope of themselves (#798).

  * Fixed a nasty out-of-bounds error in handling of irregular allocations.

  * The `floor`/`ceil` functions in `f32`/`f64` now handle infinities
    correctly (and are also faster).

  * Using `%` on floats now computes fmod instead of crashing the compiler.

## [0.12.1]

### Added

  * The internal representation of parallel constructs has been
    overhauled and many optimisations rewritten.  The overall
    performance impact should be neutral on aggregate, but there may
    be changes for some programs (please report if so).

  * Futhark now supports structurally typed sum types and pattern
    matching!  This work was done by Robert Schenck.  There remain
    some problems with arrays of sum types that themselves contain
    arrays.

  * Significant reduction in compile time for some large programs.

  * Manually specified type parameters need no longer be exhaustive.

  * Mapped `rotate` is now simplified better.  This can be
    particularly helpful for stencils with wraparound.

### Removed

  * The `~` prefix operator has been removed.  `!` has been extended
    to perform bitwise negation when applied to integers.

### Changed

  * The `--futhark` option for `futhark bench` and `futhark test` now
    defaults to the binary being used for the subcommands themselves.

  * The legacy `futhark -t` option (which did the same as `futhark
    check`) has been removed.

  * Lambdas now bind less tightly than type ascription.

  * `stream_map` is now `map_stream` and `stream_red` is now
    `reduce_stream`.

### Fixed

  * `futhark test` now understands `--no-tuning` as it was always
    supposed to.

  * `futhark bench` and `futhark test` now interpret `--exclude` in
    the same way.

  * The Python and C# backends can now properly read binary boolean
    input.

## [0.11.2]

### Fixed

  * Entry points whose types are opaque due to module ascription, yet
    whose representation is simple (scalars or arrays of scalars) were
    mistakely made non-opaque when compiled with ``--library``.  This
    has been fixed.

  * The CUDA backend now supports default sizes in `.tuning` files.

  * Loop interchange across multiple dimensions was broken in some cases (#767).

  * The sequential C# backend now generates code that compiles (#772).

  * The sequential Python backend now generates code that runs (#765).

## [0.11.1]

### Added

  * Segmented scans are a good bit faster.

  * `reduce_by_index` has received a new implementation that uses
    local memory, and is now often a good bit faster when the target
    array is not too large.

  * The `f32` and `f64` modules now contain `gamma` and `lgamma`
    functions.  At present these do not work in the C# backend.

  * Some instances of `reduce` with vectorised operators (e.g. `map2
    (+)`) are orders of magnitude faster than before.

  * Memory usage is now lower on some programs (specifically the ones
    that have large `map`s with internal intermediate arrays).

### Removed

  * Size *parameters* (not *annotations*) are no longer permitted
    directly in `let` and `loop` bindings, nor in lambdas.  You are
    likely not affected (except for the `stream` constructs; see
    below).  Few people used this.

### Changed

  * The array creation functions exported by generated C code now take
    `int64_t` arguments for the shape, rather than `int`.  This is in
    line with what the shape functions return.

  * The types for `stream_map`, `stream_map_per`, `stream_red`, and
    `stream_red_per` have been changed, such that the chunk function
    now takes the chunk size as the first argument.

### Fixed

  * Fixes to reading values under Python 3.

  * The type of a variable can now be deduced from its use as a size
    annotation.

  * The code generated by the C-based backends is now also compilable
    as C++.

  * Fix memory corruption bug that would occur on very large segmented
    reductions (large segments, and many of them).

## [0.10.2]

### Added

  * `reduce_by_index` is now a good bit faster on operators whose
    arguments are two 32-bit values.

  * The type checker warns on size annotations for function parameters
    and return types that will not be visible from the outside,
    because they refer to names nested inside tuples or records.  For
    example, the function

        let f (n: i32, m: i32): [n][m]i32 = ...

    will cause such a warning.  It should instead be written

        let f (n: i32) (m: i32): [n][m]i32 = ...

  * A new library function
    `futhark_context_config_select_device_interactively()` has been
    added.

### Fixed

  * Fix reading and writing of binary files for C-compiled executables
    on Windows.

  * Fixed a couple of overly strict internal sanity checks related to
    in-place updates (#735, #736).

  * Fixed a couple of convoluted defunctorisation bugs (#739).

## [0.10.1]

### Added

  * Using definitions from the `intrinsic` module outside the prelude
    now results in a warning.

  * `reduce_by_index` with vectorised operators (e.g. `map2 (+)`) is
    orders of magnitude faster than before.

  * Executables generated with the `pyopencl` backend now support the
    options `--default-tile-size`, `--default-group-size`,
    `--default-num-groups`, `--default-threshold`, and `--size`.

  * Executables generated with `c` and `opencl` now print a help text
    if run with invalid options.  The `py` and `pyopencl` backends
    already did this.

  * Generated executables now support a `--tuning` flag for passing
    many tuned sizes in a file.

  * Executables generated with the `cuda` backend now take an
    `--nvrtc-option` option.

  * Executables generated with the `opencl` backend now take a
    `--build-option` option.

### Removed

  * The old `futhark-*` executables have been removed.

### Changed

  * If an array is passed for a function parameter of a polymorphic
    type, all arrays passed for parameters of that type must have the
    same shape.  For example, given a function

        let pair 't (x: t) (y: t) = (x, y)

    The application `pair [1] [2,3]` will now fail at run-time.

  * `futhark test` now numbers un-named data sets from 1 rather than
    0.  This only affects the text output and the generated JSON
    files, and fits the tuple element ordering in Futhark.

  * String literals are now of type `[]u8` and contain UTF-8 encoded
    bytes.

### Fixed

  * An significant problematic interaction between empty arrays and
    inner size declarations has been closed (#714).  This follows a
    range of lesser empty-array fixes from 0.9.1.

  * `futhark datacmp` now prints to stdout, not stderr.

  * Fixed a major potential out-of-bounds access when sequentialising
    `reduce_by_index` (in most cases the bug was hidden by subsequent
    C compiler optimisations).

  * The result of an anonymous function is now also forbidden from
    aliasing a global variable, just as with named functions.

  * Parallel scans now work correctly when using a CPU OpenCL
    implementation.

  * `reduce_by_index` was broken on newer NVIDIA GPUs when using fancy
    operators.  This has been fixed.

## [0.9.1]

### Added

  * `futhark cuda`: a new CUDA backend by Jakob Stokholm Bertelsen.

  * New command for comparing data files: `futhark datacmp`.

  * An `:mtype` command for `futhark repl` that shows the type of a
    module expression.

  * `futhark run` takes a `-w` option for disabling warnings.

### Changed

  * Major command reorganisation: all Futhark programs have been
    combined into a single all-powerful `futhark` program.  Instead of
    e.g. `futhark-foo`, use `futhark foo`.  Wrappers will be kept
    around under the old names for a little while.  `futharki` has
    been split into two commands: `futhark repl` and `futhark run`.
    Also, `py` has become `python` and `cs` has become `csharp`, but
    `pyopencl` and `csopencl` have remained as they were.

  * The result of a function is now forbidden from aliasing a global
    variable.  Surprisingly little code is affected by this.

  * A global definition may not be ascribed a unique type.  This never
    had any effect in the first place, but now the compiler will
    explicitly complain.

  * Source spans are now printed in a slightly different format, with
    ending the line number omitted when it is the same as the start
    line number.

### Fixed

  * `futharki` now reports source locations of `trace` expressions
    properly.

  * The type checker now properly complains if you try to define a
    type abbreviation that has unused size parameters.

## [0.8.1]

### Added

  * Now warns when `/futlib/...` files are redundantly imported.

  * `futharki` now prints warnings for files that are ":load"ed.

  * The compiler now warns when entry points are declared with types
    that will become unnamed and opaque, and thus impossible to
    provide from the outside.

  * Type variables invented by the type checker will now have a
    unicode subscript to distinguish them from type parameters
    originating in the source code.

  * `futhark-test` and `futhark-bench` now support generating random
    test data.

  * The library backends now generate proper names for arrays of
    opaque values.

  * The parser now permits empty programs.

  * Most transpositions are now a good bit faster, especially on
    NVIDIA GPUs.

### Removed

  * The `<-` symbol can no longer be used for in-place updates and
    record updates (deprecated in 0.7.3).

### Changed

  * Entry points that accept a single tuple-typed parameter are no
    longer silently rewritten to accept multiple parameters.

### Fixed

  * The `:type` command in `futharki` can now handle polymorphic
    expressions (#669).

  * Fixed serious bug related to chaining record updates.

  * Fixed type inference of record fields (#677).

  * `futharki` no longer goes in an infinite loop if a ``for`` loop
    contains a negative upper bound.

  * Overloaded number types can no longer carry aliases (#682).

## [0.7.4]

### Added

  * Support type parameters for operator specs defined with `val`.

### Fixed

  * Fixed nasty defunctionalisation bug (#661).

  * `cabal sdist` and `stack sdist` works now.

## [0.7.3]

### Added

  * Significant performance changes: there is now a constant extra
    compilation overhead (less than 200ms on most machines).  However,
    the rest of the compiler is 30-40% faster (or more in some cases).

  * A warning when ambiguously typed expressions are assigned a
    default (`i32` or `f64`).

  * In-place updates and record updates are now written with `=`
    instead of `<-`.  The latter is deprecated and will be removed in
    the next major version (#650).

### Fixed

  * Polymorphic value bindings now work properly with module type
    ascription.

  * The type checker no longer requires types used inside local
    functions to be unambiguous at the point where the local function
    is defined.  They must still be unambiguous by the time the
    top-level function ends.  This is similar to what other ML
    languages do.

  * `futhark-bench` now writes "μs" instead of "us".

  * Type inference for infix operators now works properly.

## [0.7.2]

### Added

  * `futhark-pkg` now supports GitLab.

  * `futhark-test`s `--notty` option now has a `--no-terminal` alias.
    `--notty` is deprecated, but still works.

  * `futhark-test` now supports multiple entry points per test block.

  * Functional record updates: `r with f <- x`.

### Fixed

  * Fix the `-C` option for `futhark-test`.

  * Fixed incorrect type of `reduce_by_index`.

  * Segmented `reduce_by_index` now uses much less memory.

## [0.7.1]

### Added

  * C# backend by Mikkel Storgaard Knudsen (`futhark-cs`/`futhark-csopencl`).

  * `futhark-test` and `futhark-bench` now take a `--runner` option.

  * `futharki` now uses a new interpreter that directly interprets the
    source language, rather than operating on the desugared core
    language.  In practice, this means that the interactive mode is
    better, but that interpretation is also much slower.

  * A `trace` function that is semantically `id`, but makes `futharki`
    print out the value.

  * A `break` function that is semantically `id`, but makes `futharki`
    stop and provide the opportunity to inspect variables in scope.

  * A new SOAC, `reduce_by_index`, for expressing generalised
    reductions (sometimes called histograms).  Designed and
    implemented by Sune Hellfritzsch.

### Removed

  * Most of futlib has been removed.  Use external packages instead:

    * `futlib/colour` => https://github.com/athas/matte

    * `futlib/complex` => https://github.com/diku-dk/complex

    * `futlib/date` => https://github.com/diku-dk/date

    * `futlib/fft` => https://github.com/diku-dk/fft

    * `futlib/linalg` => https://github.com/diku-dk/fft

    * `futlib/merge_sort`, `futlib/radix_sort` => https://github.com/diku-dk/sorts

    * `futlib/random` => https://github.com/diku-dk/cpprandom

    * `futlib/segmented` => https://github.com/diku-dk/segmented

    * `futlib/sobol` => https://github.com/diku-dk/sobol

    * `futlib/vector` => https://github.com/athas/vector

    No replacement: `futlib/mss`, `futlib/lss`.

  * `zip6`/`zip7`/`zip8` and their `unzip` variants have been removed.
    If you build gigantic tuples, you're on your own.

  * The `>>>` operator has been removed.  Use an unsigned integer type
    if you want zero-extended right shifts.

### Changed

  * The `largest`/`smallest` values for numeric modules have been
    renamed `highest`/`lowest`.

### Fixed

  * Many small things.

## [0.6.3]

### Added

  * Added a package manager: `futhark-pkg`.  See also [the
    documentation](http://futhark.readthedocs.io/en/latest/package-management.html).

  * Added `log2` and `log10` functions to `f32` and `f64`.

  * Module type refinement (`with`) now permits refining parametric
    types.

  * Better error message when invalid values are passed to generated
    Python entry points.

  * `futhark-doc` now ignores files whose doc comment is the word
    "ignore".

  * `copy` now works on values of any type, not just arrays.

  * Better type inference for array indexing.

### Fixed

  * Floating-point numbers are now correctly rounded to nearest even
    integer, even in exotic cases (#377).

  * Fixed a nasty bug in the type checking of calls to consuming
    functions (#596).

## [0.6.2]

### Added

  * Bounds checking errors now show the erroneous index and the size
    of the indexed array.  Some other size-related errors also show
    more information, but it will be a while before they are all
    converted (and say something useful - it's not entirely
    straightforward).

  * Opaque types now have significantly more readable names,
    especially if you add manual size annotations to the entry point
    definitions.

  * Backticked infix operators can now be used in operator sections.

### Fixed

  * `f64.e` is no longer pi.

  * Generated C library code will no longer `abort()` on application
    errors (#584).

  * Fix file imports on Windows.

  * `futhark-c` and `futhark-opencl` now generates thread-safe code (#586).

  * Significantly better behaviour in OOM situations.

  * Fixed an unsound interaction between in-place updates and
    parametric polymorphism (#589).

## [0.6.1]

### Added

  * The `real` module type now specifies `tan`.

  * `futharki` now supports entering declarations.

  * `futharki` now supports a `:type` command (or `:t` for short).

  * `futhark-test` and `futhark-benchmark` now support gzipped data
    files.  They must have a `.gz` extension.

  * Generated code now frees memory much earlier, which can help
    reduce the footprint.

  * Compilers now accept a `--safe` flag to make them ignore `unsafe`.

  * Module types may now define *lifted* abstract types, using the
    notation `type ^t`.  These may be instantiated with functional
    types.  A lifted abstract type has all the same restrictions as a
    lifted type parameter.

### Removed

  * The `rearrange` construct has been removed.  Use `transpose` instead.

  * `futhark-mode.el` has been moved to a [separate
    repository](https://github.com/diku-dk/futhark-mode).

  * Removed `|>>` and `<<|`.  Use `>->` and `<-<` instead.

  * The `empty` construct is no longer supported.  Just use empty
    array literals.

### Changed

  * Imports of the basis library must now use an absolute path
    (e.g. `/futlib/fft`, not simply `futlib/fft`).

  * `/futlib/vec2` and `/futlib/vec3` have been replaced by a new
    `/futlib/vector` file.

  * Entry points generated by the C code backend are now prefixed with
    `futhark_entry_` rather than just `futhark_`.

  * `zip` and `unzip` are no longer language constructs, but library
    functions, and work only on two arrays and pairs, respectively.
    Use functions `zipN/unzipN` (for `2<=n<=8`).

### Fixed

  * Better error message on EOF.

  * Fixed handling of `..` in `import` paths.

  * Type errors (and other compiler feedback) will no longer contain
    internal names.

  * `futhark-test` and friends can now cope with infinities and NaNs.
    Such values are printed and read as `f32.nan`, `f32.inf`,
    `-f32.inf`, and similarly for `f32`.  In `futhark-test`, NaNs
    compare equal.

## [0.5.2]

### Added

  * Array index section: `(.[i])` is shorthand for `(\x -> x[i])`.
    Full slice syntax supported. (#559)

  * New `assert` construct. (#464)

  * `futhark-mode.el` now contains a definition for flycheck.

### Fixed

  * The index produced by `futhark-doc` now contains correct links.

  * Windows linebreaks are now fully supported for test files (#558).

## [0.5.1]

### Added

  * Entry points need no longer be syntactically first-order.

  * Added overloaded numeric literals (#532).  This means type
    suffixes are rarely required.

  * Binary and unary operators may now be bound in patterns by
    enclosing them in parenthesis.

  * `futhark-doc` now produces much nicer documentation.  Markdown is
    now supported in documentation comments.

  * `/futlib/functional` now has operators `>->` and `<-<` for
    function composition.  `<<|` are `|>>` are deprecated.

  * `/futlib/segmented` now has a `segmented_reduce`.

  * Scans and reductions can now be horizontally fused.

  * `futhark-bench` now supports multiple entry points, just like
    `futhark-test`.

  * ".." is now supported in `include` paths.

### Removed

  * The `reshape` construct has been removed.  Use the
    `flatten`/`unflatten` functions instead.

  * `concat` and `rotate` no longer support the `@` notation.  Use
    `map` nests instead.

  * Removed `-I`/`--library`.  These never worked with
    `futhark-test`/`futhark-bench` anyway.

### Changed

  * When defining a module type, a module of the same name is no
    longer defined (#538).

  * The `default` keyword is no longer supported.

  * `/futlib/merge_sort` and `/futlib/radix_sort` now define
    functions instead of modules.

### Fixed

  * Better type inference for `rearrange` and `rotate`.

  * `import` path resolution is now much more robust.

## [0.4.1]

### Added

  * Unused-result elimination for reductions; particularly useful when
    computing with dual numbers for automatic differentiation.

  * Record field projection is now possible for variables of (then)
    unknown types.  A function parameter must still have an
    unambiguous (complete) type by the time it finishes checking.

### Fixed

  * Fixed interaction between type ascription and type inference (#529).

  * Fixed duplication when an entry point was also called as a function.

  * Futhark now compiles cleanly with GHC 8.4.1 (this is also the new default).

## [0.4.0]

### Added

   * The constructor for generated PyOpenCL classes now accepts a
     `command_queue` parameter (#480).

   * Transposing small arrays is now much faster when using OpenCL
     backend (#478).

   * Infix operators can now be defined in prefix notation, e.g.:

         let (+) (x: i32) (y: i32) = x - y

     This permits them to have type- and shape parameters.

   * Comparison operators (<=, <, >, >=) are now valid for boolean
     operands.

   * Ordinary functions can be used as infix by enclosing them in
     backticks, as in Haskell.  They are left-associative and have
     lowest priority.

   * Numeric modules now have `largest`/`smallest` values.

   * Numeric modules now have `sum`, `product`, `maximum`, and
     `minimum` functions.

   * Added ``--Werror`` command line option to compilers.

   * Higher-order functions are now supported (#323).

   * Type inference is now supported, although with some limitations
     around records, in-place updates, and `unzip`. (#503)

   * Added a range of higher-order utility functions to the prelude,
     including (among others):

         val (|>) '^a '^b: a ->  (a -> b) -> b

         val (<|) '^a '^b: (a -> b) -> a -> b

         val (|>>) '^a 'b '^c: (a -> b) -> (b -> c) -> a -> c

         val (<<|) '^a 'b '^c: (b -> c) -> (a -> b) a -> c

### Changed

   * `FUTHARK_VERSIONED_CODE` is now `FUTHARK_INCREMENTAL_FLATTENING`.

   * The SOACs `map`, `reduce`, `filter`, `partition`, `scan`,
     `stream_red,` and `stream_map` have been replaced with library
     functions.

   * The futlib/mss and futlib/lss modules have been rewritten to use
     higher-order functions instead of modules.

### Fixed

   * Transpositions in generated OpenCL code no longer crashes on
     large but empty arrays (#483).

   * Booleans can now be compared with relational operators without
     crashing the compiler (#499).

## [0.3.1]

### Added

   * `futhark-bench` now tries to align benchmark results for better
     legibility.

### Fixed

   * `futhark-test`: now handles CRLF linebreaks correctly (#471).

   * A record field can be projected from an array index expression (#473).

   * Futhark will now never automatically pick Apple's CPU device for
     OpenCL, as it is rather broken.  You can still select it
     manually (#475).

   * Fixes to `set_bit` functions in the math module (#476).

## [0.3.0]

### Added

   * A comprehensible error message is now issued when attempting to
     run a Futhark program on an OpenCL that does not support the
     types used by the program.  A common case was trying to use
     double-precision floats on an Intel GPU.

   * Parallelism inside of a branch can now be exploited if the branch
     condition and the size of its results is invariant to all
     enclosing parallel loops.

   * A new OpenCL memory manager can in some cases dramatically
     improve performance for repeated invocations of the same entry
     point.

   * Experimental support for incremental flattening.  Set the
     environment variable `FUTHARK_VERSIONED_CODE` to any value to try
     it out.

   * `futhark-dataset`: Add `-t`/`-type` option.  Useful for
     inspecting data files.

   * Better error message when ranges written with two dots
     (`x..y`).

   * Type errors involving abstract types from modules now use
     qualified names (less "expected 't', got 't'", more "expected
     'foo.t', got 'bar.t'").

   * Shorter compile times for most programs.

   * `futhark-bench`: Add ``--skip-compilation`` flag.

   * `scatter` expressions nested in `map`s are now parallelised.

   * futlib: an `fft` module has been added, thanks to David
     P.H. Jørgensen and Kasper Abildtrup Hansen.

### Removed

   * `futhark-dataset`: Removed `--binary-no-header` and
     `--binary-only-header` options.

   * The `split` language construct has been removed.  There is a
     library function `split` that does approximately the same.

### Changed

  * futlib: the `complex` module now produces a non-abstract `complex`
    type.

  * futlib: the `random` module has been overhauled, with several new
    engines and adaptors changed, and some of the module types
    changed.  In particular, `rng_distribution` now contains a numeric
    module instead of an abstract type.

  * futlib: The `vec2` and `vec3` modules now represent vectors as
    records rather than tuples.

  * futlib: The `linalg` module now has distinct convenience functions
    for multiplying matrices with row and column vectors.

  * Only entry points defined directly in the file given to the
    compiler will be visible.

  * Range literals are now written without brackets: `x...y`.

  * The syntax `(-x)` can no longer be used for a partial application
    of subtraction.

  * `futhark-test` and `futhark-bench` will no longer append `.bin` to
    executables.

  * `futhark-test` and `futhark-bench` now replaces actual/expected
    files from previous runs, rather than increasing the litter.

### Fixed

  * Fusion would sometimes remove safety checks on e.g. `reshape`
    (#436).

  * Variables used as implicit fields in a record construction are now
    properly recognised as being used.

  * futlib: the `num_bits` field for the integer modules in `math` now
    have correct values.

## [0.2.0]

### Added

  * Run-time errors due to failed assertions now include a stack
    trace.

  * Generated OpenCL code now picks more sensible group size and count
    when running on a CPU.

  * `scatter` expressions nested in `map`s may now be parallelised
    ("segmented scatter").

  * Add `num_bits`/`get_bit`/`set_bit` functions to numeric module
    types, including a new `float` module type.

  * Size annotations may now refer to preceding parameters, e.g:

        let f (n: i32) (xs: [n]i32) = ...

  * `futhark-doc`: retain parameter names in generated docs.

  * `futhark-doc`: now takes `-v`/`--verbose` options.

  * `futhark-doc`: now generates valid HTML.

  * `futhark-doc`: now permits files to contain a leading documentation
    comment.

  * `futhark-py`/`futhark-pyopencl`: Better dynamic type checking in
    entry points.

  * Primitive functions (sqrt etc) can now be constant-folded.

  * Futlib: /futlib/vec2 added.

### Removed

  * The built-in `shape` function has been removed.  Use `length` or
    size parameters.

### Changed

  * The `from_i32`/`from_i64` functions of the `numeric` module type
    have been replaced with functions named `i32`/`i64`.  Similarly
    functions have been added for all the other primitive types
    (factored into a new `from_prim` module type).

  * The overloaded type conversion functions (`i32`, `f32`, `bool`,
    etc) have been removed.  Four functions have been introduced for
    the special cases of converting between `f32`/`f64` and `i32`:
    `r32`, `r64`, `t32`, `t64`.

  * Modules and variables now inhabit the same name space.  As a
    consequence, we now use `x.y` to access field `y` of record `x`.

  * Record expression syntax has been simplified.  Record
    concatenation and update is no longer directly supported.
    However, fields can now be implicitly defined: `{x,y}` now creates
    a record with field `x` and `y`, with values taken from the
    variables `x` and `y` in scope.

### Fixed

  * The `!=` operator now works properly on arrays (#426).

  * Allocations were sometimes hoisted incorrectly (#419).

  * `f32.e` is no longer pi.

  * Various other fixes.

## [0.1.0]

  (This is just a list of highlights of what was included in the first
   release.)

  * Code generators: Python and C, both with OpenCL.

  * Higher-order ML-style module system.

  * In-place updates.

  * Tooling: futhark-test, futhark-bench, futhark-dataset, futhark-doc.

  * Beginnings of a basis library, "futlib".
