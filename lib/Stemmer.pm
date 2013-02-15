# -*- coding: utf-8 -*-


package Stemmer;


use 5.14.2;
use strict;
use warnings;
use utf8;
use base qw( Exporter );
use vars qw( @EXPORT );


@EXPORT = qw( &stem );


my $vowel             = qr{[аеиоуыэюя]};
my $consonant         = qr{[бвгджзйклмнпрстфхцчшщъь]};

my $perfective_gerund = qr{(?:(?<=[ая])(?:вшись|вши|в)|(?:ывшись|ившись|ывши|ивши|ыв|ив))};
my $reflexive         = qr{(?:ся|сь)};
my $participle        = qr{(?:(?<=[ая])(?:ющ|нн|ем|вш|щ)|(?:ывш|ующ|ивш))};
my $adjective         = qr{(?:ыми|ому|ого|ими|ему|его|яя|юю|ых|ым|ый|ые|ую|ою|ом|ой|ое|их|им|ий|ие|ею|ем|ей|ее|ая)};
my $adjectival        = qr{$participle?$adjective};
my $verb              = qr{(?:(?<=[ая])(?:нно|йте|ешь|ете|ют|ть|ны|но|на|ло|ли|ла|ет|ем|н|л|й)|(?:уйте|ейте|ыть|ыло|ыли|ыла|уют|ует|ишь|ить|ите|ило|или|ила|ены|ено|ена|ят|ыт|ым|ыл|ую|уй|ит|им|ил|ен|ей|ю))};
my $noun              = qr{(?:иями|ями|иях|иям|ием|ией|ами|ях|ям|ья|ью|ье|ом|ой|ов|ия|ию|ий|ии|ие|ем|ей|еи|ев|ах|ам|я|ю|ь|ы|у|о|й|и|е|а)};
my $derivational      = qr{(?:ость|ост)};
my $superlative       = qr{(?:ейше|ейш)};


sub stem {
    
    # http://snowball.tartarus.org/algorithms/russian/stemmer.html
    #
    # Step 1: Search for a PERFECTIVE GERUND ending. If one is found remove it,
    # and that is then the end of step 1. Otherwise try and remove a REFLEXIVE
    # ending, and then search in turn for (1) an ADJECTIVAL, (2) a VERB or (3) a
    # NOUN ending. As soon as one of the endings (1) to (3) is found remove it,
    # and terminate step 1.
    #
    # Step 2: If the word ends with и (i), remove it.
    #
    # Step 3: Search for a DERIVATIONAL ending in R2 (i.e. the entire ending
    # must lie in R2), and if one is found, remove it.
    #
    # Step 4: (1) Undouble н (n), or, (2) if the word ends with a SUPERLATIVE
    # ending, remove it and undouble н (n), or (3) if the word ends ь (') (soft
    # sign) remove it.
    
    my ( $word ) = @_;
    
    $word =~ s{ё}{е}gi;
    
    # In any word, RV is the region after the first vowel, or the end of the
    # word if it contains no vowel. 
    #
    # R1 is the region after the first non-vowel following a vowel, or the end
    # of the word if there is no such non-vowel. 
    #
    # R2 is the region after the first non-vowel following a vowel in R1, or the
    # end of the word if there is no such non-vowel.
    #
    # p r o t i v o e s t e s t v e n n o m
    #      |<------       RV        ------>|
    #        |<-----       R1       ------>|
    #            |<-----     R2     ------>|
    
    my ( $rv, $rv_begin ) = ( $word                    =~ m{((?<=$vowel).+|$)}osi,           $-[1] );
    my ( $r1, $r1_begin ) = ( substr($word, $rv_begin) =~ m{((?<=$consonant)$vowel.+|$)}osi, $-[1] + $rv_begin );
    my ( $r2, $r2_begin ) = ( substr($word, $r1_begin) =~ m{((?<=$consonant)$vowel.+|$)}osi, $-[1] + $r1_begin );
    
    if ( not $rv ) {
        return $word;
    }
    
    # Step 1
    if ( not substr($word, $rv_begin) =~ s{$perfective_gerund$}{}osi ) {
        substr($word, $rv_begin) =~ s{$reflexive$}{}osi;
        
        substr($word, $rv_begin) =~ s{$adjectival$}{}osi or
        substr($word, $rv_begin) =~ s{$verb$}{}osi or
        substr($word, $rv_begin) =~ s{$noun$}{}osi;
    }
    
    # Step 2
    substr($word, $rv_begin) =~ s{и$}{}si;
    
    # Step 3
    if ( length $word >= $r2_begin ) {
        substr($word, $r2_begin) =~ s{$derivational$}{}osi;
    }
    
    # Step 4
    substr($word, $rv_begin) =~ s{нн$}{н}si or
    ( substr($word, $rv_begin) =~ s{$superlative$}{}osi and substr($word, $rv_begin) =~ s{нн$}{н}si ) or
    substr($word, $rv_begin) =~ s{ь$}{}si;
    
    return $word;
    
}


1;
