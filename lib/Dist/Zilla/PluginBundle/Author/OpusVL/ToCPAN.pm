package Dist::Zilla::PluginBundle::Author::OpusVL::ToCPAN;

use Moose;

use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Author::OpusVL;

our $VERSION = '0.009';

sub configure {
    my $self = shift;
    $self->add_bundle('@Filter', {
        '-bundle' => '@OpusVL',
        '-remove' => [ 'CPAN::Mini::Inject::REST', 'Repository' ],
    });

    $self->add_plugins(qw(
        UploadToCPAN
        GitHub::Meta
    ),
        [ ReadmeFromPod => GithubReadme => { type => 'pod' } ]);
}
1;
