#!/usr/bin/env perl

use strict;
use warnings;

my $svg_path = shift // 'github-trophies.svg';
my $columns = 4;
my $cell_size = 110;

open my $input, '<', $svg_path or die "Unable to read $svg_path: $!\n";
local $/;
my $svg = <$input>;
close $input;

my $trophy_pattern = qr{
  (\n[ ]{8}<svg\n[ ]{10}x=")\d+("\n[ ]{10}y=")\d+("\n[ ]{10}width="110"\n[ ]{10}height="110"\n[ ]{10}viewBox="0[ ]0[ ]110[ ]110")
}x;

my $trophy_count = 0;
$trophy_count++ while $svg =~ /$trophy_pattern/g;
die "No trophy cells found in $svg_path\n" if $trophy_count == 0;

my $rows = int(($trophy_count + $columns - 1) / $columns);
my $canvas_width = $columns * $cell_size;
my $canvas_height = $rows * $cell_size;
my $last_row_count = $trophy_count % $columns || $columns;
my $last_row_offset = int(($columns - $last_row_count) * $cell_size / 2);
my $index = 0;

$svg =~ s{$trophy_pattern}{
  my ($prefix, $middle, $suffix) = ($1, $2, $3);
  my $row = int($index / $columns);
  my $column = $index % $columns;
  my $offset = $row == $rows - 1 ? $last_row_offset : 0;
  my $x = ($column * $cell_size) + $offset;
  my $y = $row * $cell_size;
  $index++;
  $prefix . $x . $middle . $y . $suffix;
}gex;

my $root_updated = $svg =~ s{
  (<svg\s+width=")\d+("\s+height=")\d+("\s+viewBox="0\s+0\s+)\d+\s+\d+(")
}{$1 . $canvas_width . $2 . $canvas_height . $3 . $canvas_width . ' ' . $canvas_height . $4}ex;

die "Unable to update the root SVG dimensions in $svg_path\n" if !$root_updated;

my $temporary_path = "$svg_path.layout.tmp";
open my $output, '>', $temporary_path or die "Unable to write $temporary_path: $!\n";
print {$output} $svg;
close $output;
rename $temporary_path, $svg_path or die "Unable to replace $svg_path: $!\n";

print "Arranged $trophy_count trophies in a ${columns}-column, ${rows}-row layout.\n";
