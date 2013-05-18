# NAME

Sys::Cmd - run a system command or spawn a system processes

# VERSION

0.80.1 Development release

# SYNOPSIS

    use Sys::Cmd qw/run spawn/;

    # Get command output, raise exception on failure:
    $output = run(@cmd);

    # Feed command some input, get output as lines,
    # raise exception on failure:
    @output = run(@cmd, { input => 'feedme' });

    # Spawn and interact with a process somewhere else:
    $proc = spawn( @cmd, { dir => '/' , encoding => 'iso-8859-3'} );

    while (my $line = $proc->stdout->getline) {
        $proc->stdin->print("thanks");
    }

    my @errors = $proc->stderr->getlines;

    $proc->wait_child();  # Done!
    $proc->close();       # Cleanup

    # read exit information
    $proc->exit();      # exit status
    $proc->signal();    # signal
    $proc->core();      # core dumped? (boolean)

# DESCRIPTION

__Sys::Cmd__ lets you run system commands and capture their output, or
spawn and interact with a system process through its `STDIN`,
`STDOUT`, and `STDERR` file handles. The following functions are
exported on demand by this module:

- run( @cmd, \[\\%opt\] ) => $output | @output

Execute `@cmd` and return what the command sent to its `STDOUT`,
raising an exception in the event of error. In array context returns a
list instead of a plain string.

The first element of `@cmd` will be looked up using [File::Which](http://search.cpan.org/perldoc?File::Which) if
it is not found as a relative file name. The command input and
environment can be modified with an optional hashref containing the
following key/values:

    - dir

    The working directory the command will be run in.

    - encoding

    An string value identifying the encoding of the input/output
    file-handles. Defaults to 'utf8'.

    - env

    A hashref containing key/values to be added to the current environment
    at run-time. If a key has an undefined value then the key is removed
    from the environment altogether.

    - input

    A string which is fed to the command via its standard input, which is
    then closed.

- runx( @cmd, \[\\%opt\] ) => $outerrput | @outerrput

The same as the `run` function but with the command's `STDERR` output
appended to the `STDOUT` output.

- spawn( @cmd, \[\\%opt\] ) => Sys::Cmd

Return a __Sys::Cmd__ object (documented below) representing the process
running @cmd, with attributes set according to the optional \\%opt
hashref.  The first element of the `@cmd` array is looked up using
[File::Which](http://search.cpan.org/perldoc?File::Which) if it is not found in the file-system as a relative file
name.

__Sys::Cmd__ objects can of course be created using the standard `new`
constructor if you prefer that to the `spawn` function:

    $proc = Sys::Cmd->new(
        cmd => \@cmd,
        dir => '/',
        env => { SOME => 'VALUE' },
        enc => 'iso-8859-3',
        input => 'feedme',
        on_exit => sub {
            my $proc = shift;
            print $proc->pid .' exited with '. $proc->exit;
        },
    );

Note that __Sys::Cmd__ objects created this way will not lookup the
command using [File::Which](http://search.cpan.org/perldoc?File::Which) the way the `run`, `runx` and `spawn`
functions do.

__Sys::Cmd__ uses [Log::Any](http://search.cpan.org/perldoc?Log::Any) `debug` calls for logging purposes.

# CONSTRUCTOR

- new(%args) => Sys::Cmd

Spawns a process based on %args. %args must contain at least a `cmd`
value, and optionally `encoding`, `env`, `dir` and `input` values
as defined as attributes below.

If an `on_exit` subref argument is provided a SIGCHLD handler will be
installed (process wide!) which is called asynchronously (with the
__Sys::Cmd__ object as first argument) when the child exits.

# ATTRIBUTES

All attributes are read-only.

- cmd

An array ref containing the command and its arguments.

- dir

The working directory the command will be run in.

- encoding

An string value identifying the encoding of the input/output
file-handles. Defaults to 'utf8'.

- env

A hashref containing key/values to be added to the current environment
at run-time. If a key has an undefined value then the key is removed
from the environment altogether.

- input

A string which is fed to the command via its standard input, which is
then closed. This is a shortcut for printing to, and closing the
command's _stdin_ file-handle. An empty string will close the
command's standard input without writing to it. On some systems, some
commands may close standard input on startup, which will cause a
SIGPIPE when trying to write to it. This will raise an exception.

- pid

The command's process ID.

- stdin

The command's _STDIN_ file handle, based on [IO::Handle](http://search.cpan.org/perldoc?IO::Handle) so you can
call print() etc methods on it. Autoflush is automatically enabled on
this handle.

- stdout

The command's _STDOUT_ file handle, based on [IO::Handle](http://search.cpan.org/perldoc?IO::Handle) so you can
call getline() etc methods on it.

- stderr

The command's _STDERR_ file handle, based on [IO::Handle](http://search.cpan.org/perldoc?IO::Handle) so you can
call getline() etc methods on it.

- exit

The command's exit value, shifted by 8 (see "perldoc -f system"). Set
either when a SIGCHLD is received or after a call to `wait_child()`.

- signal

The signal number (if any) that terminated the command, bitwise-added
with 127 (see "perldoc -f system"). Set either when a SIGCHLD is
received or after a call to `wait_child()`.



- core

A boolean indicating the process core was dumped. Set either when a
SIGCHLD is received or after a call to `wait_child()`.



# METHODS

- cmdline => @list | $str

In array context returns a list of the command and its arguments.  In
scalar context returns a string of the command and its arguments joined
together by spaces.

- wait\_child()

Wait for the child to exit and collect the exit status. This method is
resposible for setting the _exit_, _signal_ and _core_ attributes.

- close()

Close all pipes to the child process.  This method is automatically
called when the `Sys::Cmd` object is destroyed.  Annoyingly, this
means that in the following example `$fh` will be closed when you
tried to use it:

    my $fh = Sys::Cmd->new( %args )->stdout;

So you have to keep track of the Sys::Cmd object manually.

# SEE ALSO

[Sys::Cmd::Template](http://search.cpan.org/perldoc?Sys::Cmd::Template)

# ALTERNATIVES

[AnyEvent::Run](http://search.cpan.org/perldoc?AnyEvent::Run), [AnyEvent::Util](http://search.cpan.org/perldoc?AnyEvent::Util), [Argv](http://search.cpan.org/perldoc?Argv), [Capture::Tiny](http://search.cpan.org/perldoc?Capture::Tiny),
[Child](http://search.cpan.org/perldoc?Child), [Forks::Super](http://search.cpan.org/perldoc?Forks::Super), [IO::Pipe](http://search.cpan.org/perldoc?IO::Pipe), [IPC::Capture](http://search.cpan.org/perldoc?IPC::Capture), [IPC::Cmd](http://search.cpan.org/perldoc?IPC::Cmd),
[IPC::Command::Multiplex](http://search.cpan.org/perldoc?IPC::Command::Multiplex), [IPC::Exe](http://search.cpan.org/perldoc?IPC::Exe), [IPC::Open3](http://search.cpan.org/perldoc?IPC::Open3),
[IPC::Open3::Simple](http://search.cpan.org/perldoc?IPC::Open3::Simple), [IPC::Run](http://search.cpan.org/perldoc?IPC::Run), [IPC::Run3](http://search.cpan.org/perldoc?IPC::Run3),
[IPC::RunSession::Simple](http://search.cpan.org/perldoc?IPC::RunSession::Simple), [IPC::ShellCmd](http://search.cpan.org/perldoc?IPC::ShellCmd), [IPC::System::Simple](http://search.cpan.org/perldoc?IPC::System::Simple),
[POE::Pipe::TwoWay](http://search.cpan.org/perldoc?POE::Pipe::TwoWay), [Proc::Background](http://search.cpan.org/perldoc?Proc::Background), [Proc::Fork](http://search.cpan.org/perldoc?Proc::Fork),
[Proc::Spawn](http://search.cpan.org/perldoc?Proc::Spawn), [Spawn::Safe](http://search.cpan.org/perldoc?Spawn::Safe), [System::Command](http://search.cpan.org/perldoc?System::Command)

# SUPPORT

This distribution is managed via github:

    https://github.com/mlawren/sys-cmd/tree/devel

This distribution follows the semantic versioning model:

    http://semver.org/

Code is tidied up on Git commit using githook-perltidy:

    http://github.com/mlawren/githook-perltidy

# AUTHOR

Mark Lawrence <nomad@null.net>, based heavily on
[Git::Repository::Command](http://search.cpan.org/perldoc?Git::Repository::Command) by Philippe Bruhat (BooK).

# COPYRIGHT AND LICENSE

Copyright 2011-2012 Mark Lawrence <nomad@null.net>

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.
