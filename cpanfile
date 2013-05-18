requires 'Carp';
requires 'Cwd';
requires 'Exporter::Tidy';
requires 'File::Which';
requires 'File::chdir';
requires 'IO::Handle';
requires 'Log::Any';
requires 'Moo';
requires 'POSIX';
requires 'perl', '5.006';

on build => sub {
    requires 'Cwd';
    requires 'Data::Dumper';
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'File::Spec';
    requires 'File::Temp';
    requires 'Test::Command';
    requires 'Test::More';
};
