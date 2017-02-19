#!/usr/bin/env perl
# This program will demonstrate crud operation on sqllite db
# prerequisite
# $ sudo perl -MCPAN -e shell
# cpan> install DBI
# cpan[2]> install DBD::SQLite
# Strict and warnings are recommended.
use strict;
use warnings;
use DBI;
my $dbfile   = "sample.db";
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";
my $dbh      = DBI->connect(
  $dsn, $user,
  $password,
  {
    PrintError       => 0,
    RaiseError       => 1,
    AutoCommit       => 1,
    FetchHashKeyName => 'NAME_lc',
  }
);

# Drop table 'people'. This may fail, if 'people' doesn't exist
# Thus we put an eval around it.
eval { $dbh->do("DROP TABLE people") };
print "Dropping people failed: $@\n" if $@;
my $sql = <<'END_SQL';
CREATE TABLE people (
  id       INTEGER PRIMARY KEY,
  fname    VARCHAR(100),
  lname    VARCHAR(100),
  email    VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(20)
)
END_SQL
$dbh->do($sql);

# INSERT some data into 'people'.
my $fname = 'Foo';
my $lname = 'Bar', my $email = 'foo@bar.com';
$dbh->do( 'INSERT INTO people (fname, lname, email) VALUES (?, ?, ?)',
  undef, $fname, $lname, $email );

# Update some data into 'people'.
$password = 'hush hush';
my $id = 1;
$dbh->do( 'UPDATE people SET password = ? WHERE id = ?', undef, $password,
  $id );

# now retrieve data from the table.
$sql = 'SELECT fname, lname FROM people WHERE id >= ? AND id < ?';
my $sth = $dbh->prepare($sql);
$sth->execute( 1, 10 );
while ( my @row = $sth->fetchrow_array ) {
  print "fname: $row[0]  lname: $row[1]\n";
}
$sth->execute( 12, 17 );
while ( my $row = $sth->fetchrow_hashref ) {
  print "fname: $row->{fname}  lname: $row->{lname}\n";
}
$sth->finish();

# Disconnect from the database.
$dbh->disconnect;
