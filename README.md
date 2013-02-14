# Upbuild

Simple directory tree build helper

## Installation

    $ gem install upbuild

## Usage

Write a command-file named `.upbuild` in the directory at the level you
want to build.  In basic usage build command line is created by
passing each line of the file as an argument.  Eg:

    echo
    hello
    world

When run with `upbuild` will run echo "hello" "world" from the shell.
Upbuild looks back toward the root of your directory tree until it
finds a `.upbuild` file to run.  The directory that the command-file
is found in becomes the working directory for the command defined in
the file.

### Passing arguments from command-line

You can break a command into mandatory and overridable parts by
splitting it using "`--`".  eg:

    ls
    -la
    --
    some_directory

When run as `upbuild` will run `ls -la some_directory`.  However if
you instead run as `upbuild another_directory` it will run `ls -la
another_directory`.  The part of the command after `--` will be
replaced with the arguments to `upbuild`.

### Multiple commands

Additionally multiple commands can be strung-together by separating
them using `&&`.  Each command will be run as long until one command
returns a failure, or the last command is run.  The return-code for
the command will be that of the last command (ie the failure, or if
all successful, the last command).  eg:

    make
    TARGET=debug
    --
    tests
    &&
    make
    TARGET=release
    --
    tests

When invoked as `upbuild` will run `make TARGET=debug tests`, and if
that succeeds run `make TARGET=release tests`.  If you want to publish
both you could build a target other than tests by specifying it on the
command-line.  eg: `upbuild publish`.


### Getting output from GUI commands

Some build tools are GUI focused and don't nicely support
scripting. Some such tools may have a silent "build feature, but no
build feed-back.  Thankfully some of these generate their own output
files, so we may synthesise some output.

    uv4
    @outfile log.txt
    -j0
    -b
    project.uvproj
    -o log.txt

The following build will execute "uv4 -j0 -b project.uvproj -o
log.txt" and emit the contents of log.txt at the end of the run -
irrespective of sucess or failure.