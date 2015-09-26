#! /usr/bin/perl

use Modern::Perl;
use C4::Context;
use Koha::Database;
use YAML::Syck;
use Getopt::Long;
use Pod::Usage;

my $schema = Koha::Database->new()->schema();

my $dump_file='Koha.yaml';
my $load_file='Koha_load.yaml';

# $koha_data is a dump of the output from Koha::Database->new()->schema()->resultset('$koha_result') 
# Where $koha_result is in Koha/Schema/Result/${koha_result}.pm

my $koha_data={};
my $load_fh;
my $help_flag = '';

GetOptions (
    'dump_file=s' => \$dump_file
   ,'load_file=s' => \$load_file
   ,'h|help'      => \$help_flag
);

if( -f $load_file ) {
    open( $load_fh, "<:encoding(UTF-8)", $load_file ) 
        or die "Could not open '$load_file' for input: " . $! ;
    $koha_data = LoadFile( $load_fh );
    # Load $koha_data into $schema here.
    my ( @tables ) = 
       grep { $schema->{class_mappings}->{"Koha::Schema::Result::$_"} } keys %{$koha_data};
    for my $table ( @tables ) {
        for my $row ( @{$koha_data->{$table}} ) {
            $schema->resultset($table)->create( $row );
        }
    }    
}

pod2usage( {
    -exitval => 0
  , -verbose => 1

} ) if $help_flag;

my @tables = values %{$schema->{class_mappings}};

for my $table ( @tables ) {
    say "$table";
    if( eval { $schema->resultset($table)->count } ) {
        my @all_data = map { $_->{_column_data} } $schema->resultset($table)->all;
        $koha_data->{$table} = [ @all_data ] ;
    }
}

DumpFile( $dump_file, $koha_data );

say join "\n" , @tables;

# vim: ts=4 shiftwidth=4 softtabstop=4 expandtab

__END__

=head1 NAME

koha_yaml.pl -- import and export Koha data using YAML files.

=head1 SYNOPSIS

    koha_yaml.pl --dump_file DUMP.yaml

    koha_yaml.pl --load_file LOAD.yaml

    koha_yaml.pl [-h | --help ]

The default dump file will be B<Koha.yaml>. The default load file will
be B<Koha_load.yaml>

As written, the script has very little control over what it imported
and exported -- any data in the load file will be imported in to Koha,
and all data in the Koha database will be exported to the dump file,
even if I<--dump_file> is not specified.

=cut
