use strict;
use warnings;
package Dist::Zilla::PluginBundle::Author::OpusVL;

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

our $VERSION = '0.010';
 
use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;
 
sub configure {
    my ($self) = @_;

    die "CPAN::Mini::Inject::REST hostname must be set in mcpani_host"
        if not $self->payload->{mcpani_host};
 
    $self->add_plugins(qw(
        Git::GatherDir
        Prereqs::FromCPANfile
    ));
    $self->add_bundle('@Filter', {
        '-bundle' => '@Basic',
        '-remove' => [ 'GatherDir', 'UploadToCPAN', 'TestRelease' ],
    });

    $self->add_plugins(qw(
        AutoPrereqs
        ReadmeFromPod
        MetaConfig
        MetaJSON
        PodSyntaxTests
        Test::Compile
        Test::ReportPrereqs
        CheckChangesHasContent
        RewriteVersion
        NextRelease
        Repository
    ),
        [ Encoding => 
            CommonBinaryFiles => {
                match => '\.(png|jpg|db)$',
                encoding => 'bytes'
        } ],
        # Don't try to weave scripts. They have their own POD.
        [ PodWeaver => { finder => ':InstallModules' } ],
        [ 'Git::Commit' =>
            CommitGeneratedFiles => { 
                allow_dirty => [ qw/dist.ini Changes cpanfile LICENSE/ ]
        } ],
        'ExecDir',
        [ ExecDir =>
            ScriptDir => { dir => 'script' }
        ],
    qw(
        Git::Tag
        BumpVersionAfterRelease
    ),
        ['Git::Commit' => 
            CommitVersionBump => { allow_dirty_match => '^lib/', commit_msg => "Bumped version number" } ],
        'Git::Push',
        ['CPAN::Mini::Inject::REST' => 
            $self->config_slice({
                mcpani_host => 'host',
                mcpani_port => 'port',
                mcpani_protocol => 'protocol',
            }) ],
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

Dist::Zilla::PluginBundle::Author::OpusVL - Standard behaviour for OpusVL modules

=head1 SYNOPSIS

In your F<dist.ini>:

    [@Author::OpusVL]
    mcpani_host = some.cpan.host

=head1 DESCRIPTION

This generally implements the workflow that OpusVL modules will use.

It is roughly equivalent to:

  [Git::GatherDir]
  [@Basic]
  ; ...but without GatherDir and UploadToCPAN

  [Prereqs::FromCPANfile]
  [AutoPrereqs]
  [ReadmeFromPod]
  [MetaConfig]
  [MetaJSON]
  [PodSyntaxTests]
  [Test::Compile]
  [Test::ReportPrereqs]
  [CheckChangesHasContent]
  [RewriteVersion]
  [NextRelease]
  [Repository]
  [PodWeaver]
  
  [Git::Commit / CommitGeneratedFiles]
  allow_dirty = dist.ini
  allow_dirty = Changes 
  allow_dirty = cpanfile 
  allow_dirty = LICENSE

  [Git::Tag]
  [BumpVersionAfterRelease]
  [Git::Commit / CommitVersionBump]
  allow_dirty_match = ^lib/
  commit_msg = "Bumped version number"

  [Git::Push]
  [CPAN::Mini::Inject::REST]

  [Prereqs / TestMoreWithSubtests]
  -phase = test
  -type  = requires
  Test::More = 0.96
