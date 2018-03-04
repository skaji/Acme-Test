package MyRunAfterRelease;

use Moose;
extends 'Dist::Zilla::Plugin::Run::AfterRelease';

sub _inject {
    my ($array, $sub, $item) = @_;
    my ($i) = grep { local $_ = $array->[$_]; $sub->($_) } 0.. $#{$array};
    if (defined $i) {
        splice @$array, $i + 1, 0, $item;
        return 1;
    }
    return;
}

# https://metacpan.org/source/RJBS/Dist-Zilla-6.011/lib/Dist/Zilla/Role/Plugin.pm
around register_component => sub {
    my ($orig, $class, $name, $arg, $section) = @_;
    my $self = $class->plugin_from_config($name, $arg, $section);
    my $version = $self->VERSION || 0;
    $self->log_debug([ 'online, %s v%s', $self->meta->name, $version ]);
    _inject
        $self->zilla->plugins,
        sub { ref $_ eq "Dist::Zilla::Plugin::CopyFilesFromRelease" },
        $self,
        or die "ERROR";
    return;
};

__PACKAGE__->meta->make_immutable;

1;
