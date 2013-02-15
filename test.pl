#!/usr/bin/perl
# -*- coding: utf-8 -*-


use 5.14.2;
use strict;
use warnings;
use utf8;
use open qw( :std :utf8 );

use lib qw( lib );

use Stemmer;


sub main {
    
    foreach my $line ( <STDIN> ) {
        chomp $line;
        
        foreach my $word ( split /\s+/, $line ) {
            print stem($word), "\n";
        }
    }
    
    return 0;
    
}


exit main();


__END__
