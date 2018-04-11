#!/usr/bin/perl -w

use strict;

use Spreadsheet::ParseExcel;



################################################################

# 定义模块名和文件名, 关键行/列号定义

################################################################



my $module_name  = "iomux";

my $file_name    = $module_name. ".v";



# Should Modified if necessary

my $portlist_gpio_row_max = 3;



my $assign_r_gpio_pu_col  = 6;

my $assign_r_gpio_pd_col  = 7;

my $assign_r_gpio_i_col   = 8;

my $assign_r_gpio_o_col   = 9;

my $assign_r_gpio_dir_col = 10;



my $assign_func_start_col = 11;



my $assign_bist_func      = 0;

my $assign_bist_i_col     = 11;

my $assign_bist_o_col     = 12;

my $assign_bist_dir_col   = 13;

my $assign_bist_ctl_col   = 14;



my $assign_scan_func      = 1;

my $assign_scan_i_col     = 15;

my $assign_scan_o_col     = 16;

my $assign_scan_dir_col   = 17;

my $assign_scan_ctl_col   = 18;



################################################################

# 依次打开iomux_mapping.xls文件，portlist表单，assign表单

################################################################

my $parser   = Spreadsheet::ParseExcel->new();



my $workbook = $parser->parse('iomux_mapping.xls');

if ( !defined $workbook ) {

    die $parser->error(), "file iomux_mapping.xls does not exist!\n";

}



my $portlist_sheet = $workbook->worksheet('portlist');

if ( !defined $portlist_sheet ) {

    die $parser->error(), "sheet 'portlist' does not exist!\n";

}



my $assign_sheet = $workbook->worksheet('assign');

if ( !defined $assign_sheet ) {

    die $parser->error(), "sheet 'assign' does not exist!\n";

}



################################################################

# 创建文件, 打印module头

################################################################

#use POSIX;

#my $file_bak = $module_name. ".". strftime("%Y%m%d%H%M%S", localtime()). ".v";

#system("mv $file_name $file_bak");

my $dir_tmp = "tmp";

if (! -d $dir_tmp) {

    mkdir $dir_tmp, 0755 or warn "Cannot make tmp directory: $!";

}

open (VLOG_FILE, ">$dir_tmp/$file_name");

print VLOG_FILE "module ", $module_name;





################################################################

# 打印portlist

################################################################

print VLOG_FILE " (\n";



my ( $portlist_row_min, $portlist_row_max ) = $portlist_sheet->row_range();

my ( $portlist_col_min, $portlist_col_max ) = $portlist_sheet->col_range();



for my $col ( 1 .. $portlist_col_max ) {

    my $cell_dir = $portlist_sheet->get_cell( 1, $col );

    for my $row ( 2 .. $portlist_row_max ) {

        my $cell_pin = $portlist_sheet->get_cell( $row, $col );

        if ( $cell_pin ) {

            if ( $cell_dir->unformatted() eq "INPUT" ) {

                print VLOG_FILE "output wire ", $cell_pin->unformatted(), ",\n";

            }

            else {

                print VLOG_FILE "input  wire ", $cell_pin->unformatted(), ",\n";

            }

        }

    }

}



for my $row ( 2 .. $portlist_gpio_row_max ) {

    my $cell_pin = $portlist_sheet ->get_cell( $row, 0 );

    if ( $cell_pin ) {

        if ( $row == $portlist_gpio_row_max ) {

            print VLOG_FILE "input  wire ", $cell_pin->unformatted(), "_in,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_out,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_oenb,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_ruen,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_rden\n";

        }

        else {

            print VLOG_FILE "input  wire ", $cell_pin->unformatted(), "_in,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_out,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_oenb,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_ruen,\n";

            print VLOG_FILE "output wire ", $cell_pin->unformatted(), "_rden,\n";

        }

    }

}



print VLOG_FILE ");\n\n";



################################################################

# 打印assign

################################################################

my ( $assign_row_min, $assign_row_max ) = $assign_sheet->row_range();

my ( $assign_col_min, $assign_col_max ) = $assign_sheet->col_range();



if ( ($assign_col_max-$assign_func_start_col+1)%4 != 0 ) {

    die $parser->error(), "assign sheet col num error! \n";

}

my $func_max = ($assign_col_max-$assign_func_start_col+1)/4;



my @multi_drv;



for my $row ( 2 .. $assign_row_max ) {

    my $cell_gpio_prefix = $assign_sheet->get_cell( $row, 0 );

    my $cell_gpio_index  = $assign_sheet->get_cell( $row, 1 );

    if ( $cell_gpio_prefix && $cell_gpio_index ) {

        ############################################################

        # 单独处理bist列,scan列

        print VLOG_FILE "    ////////////////////////////////////////\n";

        print VLOG_FILE "    // ", $cell_gpio_prefix->unformatted(), $cell_gpio_index->unformatted(), " related code\n";

        print VLOG_FILE "    // for - bist & scan\n";

        my $cell_bist_i   = $assign_sheet->get_cell ( $row, $assign_bist_i_col );

        my $cell_bist_dir = $assign_sheet->get_cell ( $row, $assign_bist_dir_col );

        my $cell_bist_ctl = $assign_sheet->get_cell ( $row, $assign_bist_ctl_col );

        if ( $cell_bist_dir ) {

            if ( $cell_bist_dir->unformatted() eq "i" ) {

                print VLOG_FILE "    assign ",

                                $cell_bist_i->unformatted(),

                                " = ",

                                $cell_bist_ctl->unformatted(),

                                " ? ",

                                $cell_gpio_prefix->unformatted(),

                                "_in",

                                $cell_gpio_index->unformatted(),

                                " : 1'b0;\n";

            }

        }



        my $cell_scan_i   = $assign_sheet->get_cell ( $row, $assign_scan_i_col   );

        my $cell_scan_dir = $assign_sheet->get_cell ( $row, $assign_scan_dir_col );

        my $cell_scan_ctl = $assign_sheet->get_cell ( $row, $assign_scan_ctl_col );

        if ( $cell_scan_dir ) {

            if ( $cell_scan_dir->unformatted() eq "i" ) {

                if ( $cell_scan_i->unformatted() ne "scan_null" ) {

                    print VLOG_FILE "    assign ",

                                    $cell_scan_i->unformatted(),

                                    " = ",

                                    $cell_scan_ctl->unformatted(),

                                    " ? ",

                                    $cell_gpio_prefix->unformatted(),

                                    "_in",

                                    $cell_gpio_index->unformatted(),

                                    " : 1'b0;\n";

                }

            }

        }



        ############################################################

        # 处理其他function列

        print VLOG_FILE "    // for - other funcs\n";

        # r_gpio_i

        my $r_gpio_i  = $assign_sheet->get_cell ( $row, $assign_r_gpio_i_col  );

        my $r_gpio_pu = $assign_sheet->get_cell ( $row, $assign_r_gpio_pu_col );

        my $r_gpio_pd = $assign_sheet->get_cell ( $row, $assign_r_gpio_pd_col );

        print VLOG_FILE "    assign ", 

                        $r_gpio_i->unformatted(), 

                        " = (scan_mode) ? ",

                        $r_gpio_pu->unformatted(),

                        " : ",

                        $cell_gpio_prefix->unformatted(),

                        "_in",

                        $cell_gpio_index->unformatted(),

                        ";\n";

        # ruen

        print VLOG_FILE "    assign ", 

                        $cell_gpio_prefix->unformatted(), 

                        "_ruen",

                        $cell_gpio_index->unformatted(),

                        " = (scan_mode) ? 1'b0 : ", 

                        $r_gpio_pu->unformatted(),

                        ";\n";

        # rden

        print VLOG_FILE "    assign ", 

                        $cell_gpio_prefix->unformatted(), 

                        "_rden",

                        $cell_gpio_index->unformatted(),

                        " = (scan_mode) ? 1'b1 : ", 

                        $r_gpio_pd->unformatted(),

                        ";\n";

        # in

        my @out_funcs;

        my $multi_drv_line;

        my $cmd_oenb = "";

        for my $func ( 0 .. ($func_max-1) ) {

            my $cell_nmi  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func*4)   );

            my $cell_nmo  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func*4+1) );

            my $cell_dir  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func*4+2) );

            my $cell_ctl  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func*4+3) );



            if ( $cell_dir && $cell_ctl && ($cell_dir->unformatted() ne "" )) {

                if ( $cell_dir->unformatted() eq "i" ) {

                    if ( $func > 1 ) {

                        if ( index($cell_nmi->unformatted(),'#') >= 0) {

                            $multi_drv_line  = "";

                            $multi_drv_line .= $cell_nmi->unformatted();

                            $multi_drv_line .= $r_gpio_pu->unformatted();

                            $multi_drv_line .= "#";

                            $multi_drv_line .= $cell_ctl->unformatted();

                            $multi_drv_line .= "#";

                            $multi_drv_line .= $cell_gpio_prefix->unformatted();

                            $multi_drv_line .= "#";

                            $multi_drv_line .= $cell_gpio_index->unformatted();

                            push @multi_drv, $multi_drv_line;

                        }

                        else {

                            print VLOG_FILE "    assign ", 

                                            $cell_nmi->unformatted(), 

                                            " = (scan_mode) ? ", 

                                            $r_gpio_pu->unformatted(), 

                                            " : ",

                                            $cell_ctl->unformatted(), 

                                            " ? ", 

                                            $cell_gpio_prefix->unformatted(),

                                            "_in",

                                            $cell_gpio_index->unformatted(),

                                            " : 1'b0;\n";

                        }

                    }

                }

                elsif ( $cell_dir->unformatted() eq "o" ) {

                    push @out_funcs, $func;

                }

                else {

                    if ( $func > 1 ) {

                        if ( index($cell_nmi->unformatted(),'#') >= 0) {

                            $multi_drv_line  = "";

                            $multi_drv_line .= $cell_nmi->unformatted();

                            $multi_drv_line .= $r_gpio_pu->unformatted();

                            $multi_drv_line .= "#";

                            $multi_drv_line .= $cell_ctl->unformatted();

                            $multi_drv_line .= "#";

                            $multi_drv_line .= $cell_gpio_prefix->unformatted();

                            $multi_drv_line .= "#";

                            $multi_drv_line .= $cell_gpio_index->unformatted();

                            push @multi_drv, $multi_drv_line;

                        }

                        else {

                            print VLOG_FILE "    assign ", 

                                            $cell_nmi->unformatted(), 

                                            " = (scan_mode) ? ", 

                                            $r_gpio_pu->unformatted(), 

                                            " : ",

                                            $cell_ctl->unformatted(), 

                                            " ? ",

                                            $cell_gpio_prefix->unformatted(), 

                                            "_in",

                                            $cell_gpio_index->unformatted(),

                                            ": 1'b0;\n";

                        }

                    }

                    push @out_funcs, $func;

                }

            }



            my $func_r = $func_max - 1 - $func;

            my $r_gpio_dir  = $assign_sheet->get_cell ( $row, $assign_r_gpio_dir_col );

            my $cell_nmi_r  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func_r*4) );

            my $cell_nmo_r  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func_r*4+1) );

            my $cell_dir_r  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func_r*4+2) );

            my $cell_ctl_r  = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$func_r*4+3) );



            if ( $cell_dir_r && $cell_ctl_r && ($cell_dir_r->unformatted() ne "" )) {

              if ( $cell_dir_r && $cell_ctl_r ) {

                  if ( $cell_dir_r->unformatted() eq "i" ) {

                      if ( $cmd_oenb eq "" ) {

                          $cmd_oenb = $cell_ctl_r->unformatted(). " ? 1'b1 :\n        ". $r_gpio_dir->unformatted();

                      }

                      else {

                          $cmd_oenb = $cell_ctl_r->unformatted(). " ? 1'b1 :\n        ". $cmd_oenb;

                      }

                  }

                  elsif ( $cell_dir_r->unformatted() eq "o" ) {

                      if ( $cmd_oenb eq "" ) {

                          $cmd_oenb = $cell_ctl_r->unformatted(). " ? 1'b0 :\n        ". $r_gpio_dir->unformatted();

                      }

                      else {

                          $cmd_oenb = $cell_ctl_r->unformatted(). " ? 1'b0 :\n        ". $cmd_oenb;

                      }

                  }

                  else {

                      if ( $cmd_oenb eq "" ) {

                          $cmd_oenb = $cell_ctl_r->unformatted(). " ? ". $cell_dir_r->unformatted(). " :\n        ". $r_gpio_dir->unformatted();

                      }

                      else {

                          $cmd_oenb = $cell_ctl_r->unformatted(). " ? ". $cell_dir_r->unformatted(). " :\n        ". $cmd_oenb;

                      }

                  }

              }

           }

        }



        if ( $cmd_oenb ne "" ) {

            print VLOG_FILE "    assign ", $cell_gpio_prefix->unformatted(), "_oenb", $cell_gpio_index->unformatted(), " =\n        ", $cmd_oenb, ";\n";

        }



        my $cmd_out = "";

        while ( @out_funcs ) {

            my $out_func  = pop ( @out_funcs );

            my $r_gpio_out = $assign_sheet->get_cell ( $row, $assign_r_gpio_o_col );

            my $cell_nmi   = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$out_func*4) );

            my $cell_nmo   = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$out_func*4+1) );

            my $cell_dir   = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$out_func*4+2) );

            my $cell_ctl   = $assign_sheet->get_cell ( $row, ($assign_func_start_col+$out_func*4+3) );

            if ( $cmd_out eq "" ) {

                $cmd_out = $cell_ctl->unformatted(). " ? ". $cell_nmo->unformatted(). " :\n        ". $r_gpio_out->unformatted(); 

            }

            else {

                $cmd_out = $cell_ctl->unformatted(). " ? ". $cell_nmo->unformatted(). " :\n        ". $cmd_out;

            }

        }



        if ( $cmd_out ne "" ) {

            print VLOG_FILE "    assign ", $cell_gpio_prefix->unformatted(), "_out", $cell_gpio_index->unformatted(), " =\n        ", $cmd_out, ";\n";

        }



        # blank line

        print VLOG_FILE "\n";



    }

}



# multi drive process

print VLOG_FILE "    // multi-driven proc\n";

my @sorted_multi_drv     = sort @multi_drv;

my $sorted_multi_drv_len = @sorted_multi_drv;



my $pre_cell_nmi     = "";

my $multi_drv_cmd    = "";

my @multi_drv_line   = "";

my $cell_nmi         = "";

my $r_gpio_pu        = "";

my $cell_ctl         = "";

my $cell_gpio_prefix = "";

my $cell_gpio_index  = "";



for my $i ( 0 .. $sorted_multi_drv_len-1 ) {

    @multi_drv_line = split ('#', $sorted_multi_drv[$i]);

    $cell_nmi         = $multi_drv_line[0];

    $r_gpio_pu        = $multi_drv_line[1];

    $cell_ctl         = $multi_drv_line[2];

    $cell_gpio_prefix = $multi_drv_line[3];

    $cell_gpio_index  = $multi_drv_line[4];

    if ( $cell_nmi eq $pre_cell_nmi ) {

        $multi_drv_cmd = $multi_drv_cmd.

                         $cell_ctl.

                         " ? ".

                         $cell_gpio_prefix.

                         "_in".

                         $cell_gpio_index.

                         " : \n        ";

        if ( $i == $sorted_multi_drv_len-1 ) {

            $multi_drv_cmd = $multi_drv_cmd.

                             "1'b0;\n";

            print VLOG_FILE $multi_drv_cmd;

        }

    }

    else {

        if ($i > 0) {

            $multi_drv_cmd = $multi_drv_cmd.

                             "1'b0;\n";

            print VLOG_FILE $multi_drv_cmd;

        }

        $pre_cell_nmi  = $cell_nmi;

        $multi_drv_cmd = "    assign ". 

                         $cell_nmi.

                         " = (scan_mode) ? ".

                         $r_gpio_pu.

                         " : \n        ".

                         $cell_ctl.

                         " ? ".

                         $cell_gpio_prefix.

                         "_in".

                         $cell_gpio_index.

                         " : \n        ";

    }

}

print VLOG_FILE "\n";

################################################################

# 打印module尾，关闭文件

################################################################

print VLOG_FILE "endmodule\n";

close (VLOG_FILE);



print " - Done. Generated: $dir_tmp/$file_name . \n";
