use strict;
use warnings;
package Dist::Zilla::PluginBundle::Author::OpusVL;

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

our $VERSION = '0.001';
 
use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;
 
sub configure {
    my ($self) = @_;
 
    $self->add_plugins(qw(
        Git::GatherDir
        Prereqs::FromCPANfile
    ));
    $self->add_bundle('@Filter', {
        '-bundle' => '@Basic',
        '-remove' => [ 'GatherDir', 'UploadToCPAN' ],
    });

    $self->add_plugins(qw(
        AutoPrereqs
        ReadmeFromPod
        MetaConfig
        MetaJSON
        PodSyntaxTests
        Test::Compile
        Test::ReportPrereqs
        CPANFile
    ));

    $self->add_plugins(
        [ CopyFilesFromBuild => {
            copy => 'cpanfile'
        } ],
    );

    $self->add_plugins(qw(
        CheckChangesHasContent
        RewriteVersion
        NextRelease
    ),
        [ 'Git::Commit' =>
            CommitGeneratedFiles => { 
                allow_dirty => [ qw/dist.ini Changes cpanfile LICENSE/ ]
        } ],
    qw(
        Git::Tag
        BumpVersionAfterRelease
    ),
        ['Git::Commit' => 
            CommitVersionBump => { allow_dirty_match => '^lib/', commit_msg => "Bumped version number" } ],
        'CPAN::Mini::Inject::REST'
    );

    $self->add_plugins(
        [ Prereqs => 'TestMoreWithSubtests' => {
            -phase => 'test',
            -type  => 'requires',
            'Test::More' => '0.96'
        } ],
    );
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
