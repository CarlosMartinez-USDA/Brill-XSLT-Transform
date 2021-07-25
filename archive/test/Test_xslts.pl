#!/usr/local/bin/perl -w
use strict;
use warnings;
use XML::LibXML;
use XML::XSLT;
use Try::Tiny;
use IPC::System::Simple qw(capturex runx );
use File::Slurp;
use Carp;

=cut
Name:           test_xslt.pl
Description:    Program used to validate XSLT output against MODS schema
Author:         Chuck Schoppet
Date:           May 13, 2014
=cut

my $SYNTAX = <<"EOD";

Syntax:         ./test_xlt.pl config.ini

config.ini format:
------------------------------------------------------------

[SCHEMA]
mods      = ../LibraryOfCongress/mods-3-5.xsd

[elsevier]
xslt     = ../pubmed_to_mods.xsl
source   = ../sampleXML/Elsevier_pubmed.xml
target   = ../sampleXML/Elsevier_mods.xml

-------------------------------------------------------------
EOD

my $CONFIG_FILE = $ARGV[0];
my $PARSER = XML::LibXML->new;

my $SCHEMA; # set by config.ini in setup routine.
            # XML::LibXML::Schema->new(location => $schema_file);

main();

sub main {

    my %test_data;

    read_ini( $CONFIG_FILE, \%test_data );
    setup( \%test_data );

    my @list_of_publisher = sort keys %test_data;

    foreach my $publisher ( @list_of_publisher ) {
        print "\n\nTest transformation for $publisher:\n\n";
        my $hash = $test_data{$publisher};
        if ( check_file( $hash ) ) {
            translate( $hash );
            validate( $hash );
        }
    }

    return;
}

sub read_ini {
    my $config_file = shift;
    my $h_config    = shift;

    if ( not -f $config_file ) {
        carp "Missing config file:\n" . $SYNTAX;
        exit;
    }

    my @lines = read_file( $config_file );

    my $top_level = 'top';

    foreach my $line ( @lines ) {
        chomp $line;
        $line =~ s{\s*#.*}{}xms; # remove comments

        if ( $line =~ m{\[(.*?)\]}xms ) {
            $top_level = $1;    # set top level
        }
        elsif ( $line =~ m{(.*?)\s*=\s*(.*)}xms ) {
            my $key = $1;
            my $value = $2;
            $h_config->{$top_level}->{$key} = $value;
        }
    }
    return;
}



sub setup{
    my $h_test_data = shift;

    if ( not exists $h_test_data->{SCHEMA}->{mods} ) {
        carp "Missing schema section:\n" . $SYNTAX;
        exit;
    }

    my $schema_file = $h_test_data->{SCHEMA}->{mods};

    if (not -f $schema_file ) {
        carp "Can't find schema at $schema_file";
        exit;
    }

    $SCHEMA = XML::LibXML::Schema->new(location => $schema_file);

    delete $h_test_data->{SCHEMA}; # Done with schedule, leave on test data.

    return;

}


sub check_file {
    my $hash_file = shift;
    my $flag = 1;

    my @file_types = ( 'source', 'target', 'xslt' );

    foreach my $file_type ( @file_types ) {
        if ( not exists $hash_file->{$file_type} ) {
            print "missing element for $file_type\n";
            $flag = 0;
        }
        elsif( $file_type ne 'target' and not -f $hash_file->{$file_type} ) {
            print "missing file $hash_file->{$file_type} for $file_type\n";
            $flag = 0;
        }
    }

    return $flag;
}

sub translate {
    my $hash = shift;

    my $error;

    try {
        runx( 'xsltproc',
                            '--stringparam', 'vendorName', $hash->{publisher},
                            '--stringparam', 'archiveFile', $hash->{source},
                            '--output', $hash->{target},
                            $hash->{xslt}, $hash->{source}  );
    }
    catch {
        $error = 1;
        foreach my $line ( $@ ) {
            print ( $line );
        }
        print "### TRANSFORM FAILED ###\n";
    };

    if ( not $error ) {
        print "### TRANSLATE PASSED ###\n";
    }

=cut
    if ( my $text = system( 'xsltproc', '--output', $hash->{target}, $hash->{xslt}, $hash->{source}  ) ) {
        my $error = "Transform error: $text";
        print "$error\n";
    }
=cut

=cut
    if ( my $text = system( 'java', '-Dhttp.proxyHost=nal-cache.nal.usda.gov', '-Dhttp.proxyPort=3128', '-cp', 'saxon9he.jar', 'net.sf.saxon.Transform',
                           "-s:$source_file", "-xsl:$xsl_file",
                           "-o:$mods_file", "-warnings:silent" ) ) {
        print "$source_file: $text\n";
    }
=cut
    return;
}


sub validate {
    my $hash = shift;

    my $doc = $PARSER->parse_file($hash->{target} );

#    $SCHEMA->validate( $doc );

    eval{
        $SCHEMA->validate( $doc );
    };
    if ( $@ ) {
        print $@;
        print "### VALIDATE FAILED ###\n";
    }
    else {
        print "### VALIDATE PASSED ###\n";
    }

    return;
}
