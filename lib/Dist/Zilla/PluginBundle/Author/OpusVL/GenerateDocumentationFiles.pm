package Dist::Zilla::PluginBundle::Author::OpusVL::GenerateDocumentationFiles;

use Moose;
use 5.014;

with (
    'Dist::Zilla::Role::PluginBundle::Easy',
    'Dist::Zilla::Role::PluginBundle::PluginRemover',
    'Dist::Zilla::Role::PluginBundle::Config::Slicer',
);
use namespace::clean;
use Data::Section -setup;


our $VERSION = '0.013';

sub configure {
    my $self = shift;

	$self->add_plugins([GenerateFile => 'Generate_Contrib' => { filename => 'CONTRIBUTING.md', content => [split /\n/, ${$self->section_data('CONTRIBUTING.md')}] }]);
	my @from_build = qw(INSTALL LICENSE CONTRIBUTING.md META.json README);

	$self->add_plugins(
		'InstallGuide',
		[CopyFilesFromRelease => { filename => \@from_build }],
        ['Git::GatherDir' => { exclude_filename => [@from_build] }],
        [ 'Git::Commit' =>
            { allow_dirty => [ @from_build ] } ],
	);
}

__PACKAGE__->meta->make_immutable;
1;


=head1 NAME

Dist::Zilla::PluginBundle::Author::OpusVL::GenerateDocumentationFiles - Push generated documentation into git

=head1 DESCRIPTION

This bundle is just an extra to allow the README and other documentation to be 
copied into the git repo for repo's kept on github.

It will also ensure the INSTALL and CONTRIBUTING files are created too.

This is heavily inspired by DBOOK's Author bundle and also relies on the CONTRIBUTING
guide started by DAGOLDEN.

=head1 METHODS

=head2 configure

=head1 ATTRIBUTES


=cut

__DATA__
__[ CONTRIBUTING.md ]__
# HOW TO CONTRIBUTE

Thank you for considering contributing to this distribution.  This file
contains instructions that will help you work with the source code.

The distribution is managed with [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla).
This means that many of the usual files you might expect are not in the
repository, but are generated at release time.  Some generated files are kept
in the repository as a convenience (e.g. Build.PL/Makefile.PL and META.json).

Generally, **you do not need Dist::Zilla to contribute patches**.  You may need
Dist::Zilla to create a tarball.  See below for guidance.

## Getting dependencies

If you have App::cpanminus 1.6 or later installed, you can use
[cpanm](https://metacpan.org/pod/cpanm) to satisfy dependencies like this:

    $ cpanm --installdeps --with-develop .

You can also run this command (or any other cpanm command) without installing
App::cpanminus first, using the fatpacked `cpanm` script via curl or wget:

    $ curl -L https://cpanmin.us | perl - --installdeps --with-develop .
    $ wget -qO - https://cpanmin.us | perl - --installdeps --with-develop .

Otherwise, look for either a `cpanfile` or `META.json` file for a list of
dependencies to satisfy.

## Running tests

You can run tests directly using the `prove` tool:

    $ prove -l
    $ prove -lv t/some_test_file.t

For most of my distributions, `prove` is entirely sufficient for you to test
any patches you have. I use `prove` for 99% of my testing during development.

## Code style and tidying

Please try to match any existing coding style.  If there is a `.perltidyrc`
file, please install Perl::Tidy and use perltidy before submitting patches.

## Installing and using Dist::Zilla

[Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) is a very powerful
authoring tool, optimized for maintaining a large number of distributions with
a high degree of automation, but it has a large dependency chain, a bit of a
learning curve and requires a number of author-specific plugins.

To install it from CPAN, I recommend one of the following approaches for the
quickest installation:

    # using CPAN.pm, but bypassing non-functional pod tests
    $ cpan TAP::Harness::Restricted
    $ PERL_MM_USE_DEFAULT=1 HARNESS_CLASS=TAP::Harness::Restricted cpan Dist::Zilla

    # using cpanm, bypassing *all* tests
    $ cpanm -n Dist::Zilla

In either case, it's probably going to take about 10 minutes.  Go for a walk,
go get a cup of your favorite beverage, take a bathroom break, or whatever.
When you get back, Dist::Zilla should be ready for you.

Then you need to install any plugins specific to this distribution:

    $ dzil authordeps --missing | cpanm

You can use Dist::Zilla to install the distribution's dependencies if you
haven't already installed them with cpanm:

    $ dzil listdeps --missing --develop | cpanm

Once everything is installed, here are some dzil commands you might try:

    $ dzil build
    $ dzil test
    $ dzil regenerate

You can learn more about Dist::Zilla at http://dzil.org/

## Other notes

This distribution maintains the generated `META.json` and either `Makefile.PL`
or `Build.PL` in the repository. This allows two things:
[Travis CI](https://travis-ci.org/) can build and test the distribution without
requiring Dist::Zilla, and the distribution can be installed directly from
Github or a local git repository using `cpanm` for testing (again, not
requiring Dist::Zilla).

    $ cpanm git://github.com/Author/Distribution-Name.git
    $ cd Distribution-Name; cpanm .

Contributions are preferred in the form of a Github pull request. See
[Using pull requests](https://help.github.com/articles/using-pull-requests/)
for further information. You can use the Github issue tracker to report issues
without an accompanying patch.

# CREDITS

This file was adapted from an initial `CONTRIBUTING.mkdn` file from David
Golden under the terms of the Apache 2 license, with inspiration from the
contributing documents from [Dist::Zilla::Plugin::Author::KENTNL::CONTRIBUTING](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::KENTNL::CONTRIBUTING)
and [Dist::Zilla::PluginBundle::Author::ETHER](https://metacpan.org/pod/Dist::Zilla::PluginBundle::Author::ETHER).
__END__
