package MySQL::Diff;

use strict;

use base qw(Exporter);
use vars qw(@EXPORT_OK);
@EXPORT_OK = qw(parse_arg diff_dbs);

use MySQL::Database;
use MySQL::Utils qw(parse_arg debug);

our $VERSION = '0.30';

sub diff_dbs {
  my ($opts, @db) = @_;

  my %opts = %$opts;
  my $table_re = $opts{'table-re'};

  debug(1, "comparing databases\n");

  my @changes = ();

  foreach my $table1 ($db[0]->tables()) {
    my $name = $table1->name();
    if ($table_re && $name !~ $table_re) {
      debug(2, "  table `$name' didn't match /$table_re/; ignoring\n");
      next;
    }
    debug(2, "  looking at tables called `$name'\n");
    if (my $table2 = $db[1]->table_by_name($name)) {
      debug(4, "    comparing tables called `$name'\n");
      push @changes, diff_tables($opts, $table1, $table2);
    }
    else {
      debug(3, "    table `$name' dropped\n");
      push @changes, "DROP TABLE $name;\n\n"
        unless $opts{'only-both'} || $opts{'keep-old-tables'};
    }
  }

  foreach my $table2 ($db[1]->tables()) {
    my $name = $table2->name();
    if ($table_re && $name !~ $table_re) {
      debug(2, "  table `$name' matched $opts{'table-re'}; ignoring\n");
      next;
    }
    if (! $db[0]->table_by_name($name)) {
      debug(3, "  table `$name' added\n");
      push @changes, $table2->def() . "\n"
        unless $opts{'only-both'};
    }
  }

  my $out = '';
  if (@changes) {
    $out .= diff_banner(@db);
    $out .= join '', @changes;
  }
  return $out;
}

sub diff_banner {
  my @db = @_;

  my $summary1 = $db[0]->summary();
  my $summary2 = $db[1]->summary();

  my $now = scalar localtime();
  return <<EOF;
## mysqldiff $VERSION
## 
## run on $now
##
## --- $summary1
## +++ $summary2

EOF
}

sub diff_tables {
  my @changes = (diff_fields(@_),
                 diff_indices(@_),
                 diff_primary_key(@_),
                 diff_options(@_));
  if (@changes) {
    $changes[-1] =~ s/\n*$/\n/;
  }
  return @changes;
}

sub diff_fields {
  my ($opts, $table1, $table2) = @_;

  my %opts = %$opts;
  my $name1 = $table1->name();

  my %fields1 = $table1->fields;
  my %fields2 = $table2->fields;

  my @changes = ();
  
  foreach my $field (keys %fields1) {
    debug(5, "      table1 had field `$field'\n");
    my $f1 = $fields1{$field};
    if (my $f2 = $fields2{$field}) {
      if ($f1 ne $f2) {
        if (not $opts{tolerant} or (($f1 !~ m/$f2\(\d+,\d+\)/)         and
                                    ($f1 ne "$f2 DEFAULT '' NOT NULL") and
                                    ($f1 ne "$f2 NOT NULL")
                                   ))
        {
          debug(4, "      field `$field' changed\n");

          my $change = "ALTER TABLE $name1 CHANGE COLUMN $field $field $f2;";
          $change .= " # was $f1" unless $opts{'no-old-defs'};
          $change .= "\n";
          push @changes, $change;
        }
      }
    }
    else {
      debug(4, "      field `$field' removed\n");
      my $change = "ALTER TABLE $name1 DROP COLUMN $field;";
      $change .= " # was $fields1{$field}" unless $opts{'no-old-defs'};
      $change .= "\n";
      push @changes, $change;
    }
  }

  foreach my $field (keys %fields2) {
    if (! $fields1{$field}) {
      debug(4, "      field `$field' added\n");
      push @changes, "ALTER TABLE $name1 ADD COLUMN $field $fields2{$field};\n";
    }
  }

  return @changes;
}

sub diff_indices {
  my ($opts, $table1, $table2) = @_;

  my %opts = %$opts;
  my $name1 = $table1->name();

  my %indices1 = %{ $table1->indices() };
  my %indices2 = %{ $table2->indices() };

  my @changes = ();

  foreach my $index ($table1->indices_keys) {
    my $old_type = $table1->unique_index($index) ? 'UNIQUE' : 'INDEX';

    if ($indices2{$index}) {
      if ($indices1{$index} ne $indices2{$index} ||
          ($table1->unique_index($index)
             xor
           $table2->unique_index($index)))
      {
        debug(4, "      index `$index' changed\n");
        my $new_type = $table2->unique_index($index) ? 'UNIQUE' : 'INDEX';

        my $changes = '';
        if ($indices1{$index}) {
          $changes .= "ALTER TABLE $name1 DROP INDEX $index;";
          $changes .= " # was $old_type ($indices1{$index})"
            unless $opts{'no-old-defs'};
          $changes .= "\n";
        }

        $changes .= <<EOF;
ALTER TABLE $name1 ADD $new_type $index ($indices2{$index});
EOF
        push @changes, $changes;
      }
    }
    else {
      debug(4, "      index `$index' removed\n");
      my $change = "ALTER TABLE $name1 DROP INDEX $index;";
      $change .= " # was $old_type ($indices1{$index})"
        unless $opts{'no-old-defs'};
      $change .= "\n";
      push @changes, $change;
    }
  }

  foreach my $index (keys %indices2) {
    if (! $indices1{$index}) {
      debug(4, "      index `$index' added\n");
      push @changes,
           "ALTER TABLE $name1 ADD INDEX $index ($indices2{$index});\n";
    }
  }

  return @changes;
}

sub diff_primary_key {
  my ($opts, $table1, $table2) = @_;

  my %opts = %$opts;
  my $name1 = $table1->name();

  my $primary1 = $table1->primary_key();
  my $primary2 = $table2->primary_key();

  return () unless $primary1 || $primary2;

  my @changes = ();
  
  if ($primary1 && ! $primary2) {
    debug(4, "      primary key `$primary1' dropped\n");
    my $change = "ALTER TABLE $name1 DROP PRIMARY KEY;";
    $change .= " # was $primary1" unless $opts{'no-old-defs'};
    return ( "$change\n" );
  }

  if (! $primary1 && $primary2) {
    debug(4, "      primary key `$primary2' added\n");
    return ("ALTER TABLE $name1 ADD PRIMARY KEY $primary2;\n");
  }

  if ($primary1 ne $primary2) {
    debug(4, "      primary key changed\n");
    my $change = "ALTER TABLE $name1 DROP PRIMARY KEY;";
    $change .= " # was $primary1" unless $opts{'no-old-defs'};
    $change .= <<EOF;

ALTER TABLE $name1 ADD PRIMARY KEY $primary2;
EOF
    push @changes, $change;
  }

  return @changes;
}

sub diff_options {
  my ($opts, $table1, $table2) = @_;

  my %opts = %$opts;
  my $options1 = $table1->options();
  my $options2 = $table2->options();
  my $name     = $table1->name();

  my @changes = ();
  
  if ($options1 ne $options2) {
    my $change = "ALTER TABLE $name $options2;";
    $change .= " # was " . ($options1 || 'blank') unless $opts{'no-old-defs'};
    $change .= "\n";
    push @changes, $change;
  }

  return @changes;
}

1;
