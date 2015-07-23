use strict;
use warnings;
package Dist::Zilla::PluginBundle::OpusVL;

#VERSION

use Moose;
use Moose::Autobox;
use Dist::Zilla 2.100922; # TestRelease
with 'Dist::Zilla::Role::PluginBundle::Easy';
with 'Dist::Zilla::Role::PluginBundle::Config::Slicer';
 
use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;
 
has manual_version => (
    is          => 'ro',
    isa         => 'Bool',
    lazy        => 1,
    default => sub { $_[0]->payload->{manual_version} },
);
 
has major_version => (
    is          => 'ro',
    isa         => 'Int',
    lazy        => 1,
    default => sub { $_[0]->payload->{version} || 0 },
);
 
has is_task => (
    is          => 'ro',
    isa         => 'Bool',
    lazy        => 1,
    default => sub { $_[0]->payload->{task} },
);
 
has github_issues => (
    is          => 'ro',
    isa         => 'Bool',
    lazy        => 1,
    default => sub { $_[0]->payload->{github_issues} },
);
 
sub configure {
    my ($self) = @_;
 
    $self->add_plugins('Git::GatherDir');
    $self->add_plugins('CheckPrereqsIndexed');
    $self->add_bundle('@Filter', {
        '-bundle' => '@Basic',
        '-remove' => [ 'GatherDir', 'UploadToCPAN' ],
    });

    $self->add_plugins(qw(
        AutoPrereqs
        Git::NextVersion
        ReadmeFromPod
        PkgVersion
        MetaConfig
        MetaJSON
        NextRelease
        PodSyntaxTests
        Test::Compile
        ReportVersions::Tiny
        CPANFile
    ));

    $self->add_plugins(
        [ CopyFilesFromBuild => {
            copy => 'cpanfile'
        } ],
    );
 
    $self->add_plugins(
        [ Prereqs => 'TestMoreWithSubtests' => {
            -phase => 'test',
            -type  => 'requires',
            'Test::More' => '0.96'
        } ],
    );
 
    $self->add_bundle('@Git');
}
 
__PACKAGE__->meta->make_immutable;
no Moose;
 
1;

=encoding utf8

=head1 NAME

Dist::Zilla::PluginBundle::OpusVL - Standard behaviour for OpusVL modules

=head1 SYNOPSIS

In your F<dist.ini>:

    [@OpusVL]

=head1 DESCRIPTION

This generally implements the workflow that OpusVL modules will use.

It is roughly equivalent to:

  [Git::GatherDir]
  [@Basic]
  ; ...but without GatherDir and UploadToCPAN

  [AutoPrereqs]
  [Git::NextVersion]
  [PkgVersion]
  [MetaConfig]
  [MetaJSON]
  [NextRelease]

  ; ensure non-dzil users can cpanm from source
  [CPANFile]
  [CopyFilesFromBuild]
  copy = cpanfile

  [Test::ChangesHasContent]
  [PodSyntaxTests]
  [Test::Compile]
  [ReportVersions::Tiny]

  [@Git]
  [Prereqs / TestMoreWithSubtests]
  Test::More = 0.96

=head1 AUTHOR

Alastair McGowan-Douglas <alastair.mcgowan@opusvl.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2015 OpusVL

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
