#!/usr/bin/perl
# Generate memories with ./memlist from memory compiler
# 2015-05-26, by Lilin

use strict;
use warnings;

open(MEMLIST,"<./memlist") or die("Cannot open: ./memlist");

my($name, $words, $bits, $mux, $freq, $writemask);
my $i = 0;

while(<MEMLIST>) {
    chomp;
    s/\s*$//g;
    $i++;

    if(/^\s*$/) {                                          # blank line
        #print "line $i: blank line\n";
        next;
    }elsif(/^\/\//) {                                      # comment line
        #print "line $i: comment line\n";
        next;
    }else {
        ($name, $words, $bits, $mux, $freq, $writemask) = split;
        #print "line $i: $name\n";
        #print "line $i: $words\n";
        #print "line $i: $bits\n";
        #print "line $i: $mux\n";
        #print "line $i: $freq\n";
        #print "line $i: $writemask\n";
        if( (!defined($writemask)) ) {
            print "ERROR: line $i is incomplete line!\n";
            next;
        }
    }

    if($name =~ /NAME/i) {                                 # HEAD line
        #print "line $i: HEAD line\n";
        next;
    }elsif($name =~ /sram_sp_hde/i) {                      # sram_sp_hde_rvt_rvt
        chdir "../" or warn "Cannot chdir to directory memory: $!";
        system "rm -rf $name";
        mkdir "$name", 0755 or warn "Cannot make directory $name: $!";
        chdir "$name" or warn "Cannot chdir to directory $name: $!";
        system "cp ../genmem/sram_sp_hde_example.spec $name.spec";
        system "sed -i 's/\$name/$name/g' $name.spec";
        system "sed -i 's/\$words/$words/g' $name.spec";
        system "sed -i 's/\$bits/$bits/g' $name.spec";
        system "sed -i 's/\$mux/$mux/g' $name.spec";
        system "sed -i 's/\$freq/$freq/g' $name.spec";
        system "sed -i 's/\$writemask/$writemask/g' $name.spec";
        system "/home/bt/040n/lib/arm_smic/logic0040ll/sram_sp_hde_rvt_rvt/r1p2/bin/sram_sp_hde_rvt_rvt all -spec $name.spec"; 
        chdir "../genmem/" or warn "Cannot chdir to directory genmem: $!";
    }elsif($name =~ /rf_sp_hdf/i) {                      # rf_sp_hdf_rvt_rvt
        chdir "../" or warn "Cannot chdir to directory memory: $!";
        system "rm -rf $name";
        mkdir "$name", 0755 or warn "Cannot make directory $name: $!";
        chdir "$name" or warn "Cannot chdir to directory $name: $!";
        system "cp ../genmem/rf_sp_hdf_example.spec $name.spec";
        system "sed -i 's/\$name/$name/g' $name.spec";
        system "sed -i 's/\$words/$words/g' $name.spec";
        system "sed -i 's/\$bits/$bits/g' $name.spec";
        system "sed -i 's/\$mux/$mux/g' $name.spec";
        system "sed -i 's/\$freq/$freq/g' $name.spec";
        system "sed -i 's/\$writemask/$writemask/g' $name.spec";
        system "/home/bt/040n/lib/arm_smic/logic0040ll/rf_sp_hdf_rvt_rvt/r1p1/bin/rf_sp_hdf_rvt_rvt all -spec $name.spec"; 
        chdir "../genmem/" or warn "Cannot chdir to directory genmem: $!";
    }elsif($name =~ /rom_via/i) {                      # rom_via_hdd_rvt_rvt
        chdir "../" or warn "Cannot chdir to directory memory: $!";
        system "rm -rf $name";
        mkdir "$name", 0755 or warn "Cannot make directory $name: $!";
        chdir "$name" or warn "Cannot chdir to directory $name: $!";
        system "cp ../genmem/rom_via_example.spec $name.spec";
        system "sed -i 's/\$name/$name/g' $name.spec";
        system "sed -i 's/\$words/$words/g' $name.spec";
        system "sed -i 's/\$bits/$bits/g' $name.spec";
        system "sed -i 's/\$mux/$mux/g' $name.spec";
        system "sed -i 's/\$freq/$freq/g' $name.spec";
        ## Generate rom views without rcf
        system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt testcode -spec $name.spec"; 
        system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt all -spec $name.spec"; 
        ## Generate rom views with rcf
        #system "cp ../genmem/$name.rcf $name.rcf";
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt ascii -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt bitmap -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt ctl -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt fastscan -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt gds2 -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt lef-fp -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt liberty -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt lvs -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt memorybist -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt postscript -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt tmax -spec $name.spec"; 
        #system "/home/bt/040n/lib/arm_smic/logic0040ll/rom_via_hdd_rvt_rvt/r1p1/bin/rom_via_hdd_rvt_rvt verilog -spec $name.spec"; 
        chdir "../genmem/" or warn "Cannot chdir to directory genmem: $!";
    }else {
        print "ERROR: line $i is strange line!\n";
    }
}

close( MEMLIST ) or die( "Cannot close: ./memlist" );
