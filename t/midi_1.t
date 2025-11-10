use v5.42;
use File::Find ();

use FindBin;
use Test2::V0;
use JSON::PP;

my $bin_re = qr/^[0-9a-f]+$/i;

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;



# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, "$FindBin::Bin/../MIDI_1/");
done_testing;
exit;

sub slurp {
    open my $fh, '<', shift or die $!;
    local $/ = undef;
    <$fh>;
}

sub validate_subtest( $fn, $subtest ) {
    my $description = $subtest->{ description } // '';
    ok( $description, qq{Subtest in $fn has description : "$description"} );
    ok( $subtest->{ data }, qq{Subtest "$description" in $fn has input data} );
    ok( $subtest->{ expect }, qq{Subtest "$description" in $fn has expected output} );

    my ( $events, $binary ) = ref $subtest->{ expect }
        ? ( $subtest->@{ qw/ expect data / } )
        : ( $subtest->@{ qw/ data expect / } );

    like( $binary =~ y/ //dr, $bin_re, qq{Binary string in subtest "$description" in $fn appears valid} );
    ok( ref $events eq 'ARRAY' && $events->@*, qq{At least one event defined in subtest "$description" in $fn} );
}

sub test( $fn ) {
    my $data;
    try {
        $data = JSON::PP->new->decode( slurp( $fn ) );
    }
    catch( $e ) {
        ok( 0, "Decoding JSON in $fn : $e" );
        return;
    }

    ok( $data->{ description }, "Description present in $fn" );

    if ( ref $data->{ source } eq 'HASH' ) {
        ok( $data->{source}->{ name }, "Source is named in $fn" );
    }

    my @tests = $data->{ tests }->@*;
    ok( @tests, "At least one test in $fn" );

    validate_subtest( $fn, $_ ) for @tests;
}

sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    /^.*\.json\z/si
    && test( $File::Find::name );
}

