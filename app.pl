#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use DBI;
use Try;

our @ID = (
  "f6azxsgdyf2kunj9p4ce8x2f",
  "bbwpjrn242zgzwum728wuemz",
  "9q7q4bqq89z9kje3tkechxqx",
  "rcssye5qan69tgwzazz9yna6",
  "cv72bfkfxtfgc2jrdku3se2w",
  "38dtc4ymykw69r2h4asvqjzm",
  "b6fet4r8ddpuhsabx37qrpc9",
  "nhepurdcj2vjkjjmmj96yzcm",
  "hrh5sfmzrsw67vqxeur55w6a",
  "nqe7w6zkj8uprvgcxnk5f4da",
  "c5d8suqfbyy9zt49kqjkkbkj",
  "mq8tvd6ewbwszv58kpngx5rv",
);


our @USED;

my $dbh;

my $DEBUG = 1;
my $DBname='walmart';
my $DBhost='127.0.0.1';
my $DBuser='root';
my $DBpassword='yfhbtkm';
        
my $i = 30000165; ###new number        
#my $i = 3955418;
my $f = 1;
my $id = getID();

# TODO: Зачем надо каждый раз заново коннект делать было?
unless ( $DEBUG == 0 ){
  $dbh=DBI->connect("DBI:mysql:$DBname:$DBhost",$DBuser,$DBpassword, , { RaiseError => 1 }) || die($!);
  $dbh->do("SET NAMES UTF8");
}

my $data;

my $ua = LWP::UserAgent->new();

while ( $i<= 499999999 ) {

  my $url = "http://api.walmartlabs.com/v1/items/$i?format=json&apiKey=$id";
  print "=== [$url]";
  my $res = $ua->get($url);
  my $html = $res->decoded_content;
  eval { $data = decode_json($res->decoded_content); };
  #print Dumper $data;
  #next;

  $i++;

  print "DATA: $data\n";
  
  print ">>> $data->{errors}[0]->{message}\n\n";
  
  print Dumper @ID;
  
  if ( $html =~ m/errors/sgi  ) {
  
  #Ну тупо нет такого товара
  if ( $data->{errors}[0]->{message} eq "Invalid itemId" ) {
    print "!!!ОШИБКА НЕТ ТОВАРА\n\n";
    #print Dumper $data;
    next;
  }
  elsif ( $data->{errors}[0]->{message} eq "Account Inactive" || "Account Over Rate Limit" ) {
     $id = getID();
     #next;
  }
  }

  print "========================================================\n";
  print "=== ПОШЛИ ДАННЫЕ\n\n";
  $f++;

  #print Dumper $data;
  if ( !$data->{upc} ) {
    $data->{upc} = 0;
  }
  
  #print "itemID: ".$data->{itemId};
  #exit;


  if ( $data->{name} ) {

  eval { 

$dbh=DBI->connect("DBI:mysql:$DBname:$DBhost",$DBuser,$DBpassword, , { RaiseError => 1 }) || die($!);
  $dbh->do("SET NAMES UTF8");
  $dbh->do("SET CHARACTER SET utf8");

#  my $sth = $dbh->prepare( "insert into good ( itemId, name,msrp,categoryPath,shortDescription,longDescription,brandName,color,modelNumber,productUrl,customerRating,numReviews,customerRatingImage, stock, offerType" ) values ( ?,?,?,?,?,?,?,?,?,?,?,?,?,?,? );
#     $sth->execute( $data->{itemId}, $data->{name},$data->{msrp},$data->{categoryPath},$data->{shortDescriptio},$data->{longDescription},$data->{brandName},$data->{color},$data->{modelNumber},$data->{productUrl},$data->{customerRating},$data->{numReviews},$data->{customerRatingImage},$data->{stock},$data->{offerType} ) || die $dbh->errstr;
     
  my @cols = qw/name itemId salePrice upc msrp categoryPath thumbnailImage shortDescription longDescription brandName color modelNumber productUrl customerRating numReviews customerRatingImage stock offerType/;
  my $sql = "INSERT INTO good (".join(',',@cols).") VALUES (". join(',',map { '?' } @cols).")";
  my @bind = map { $data->{$_} } @cols;

#  print "BIND:".Dumper @bind;

  unless ( $DEBUG == 0 ) {
    $dbh->do($sql,undef,@bind);    
    print "GOOD NUMBER $f\n";
  }
  
  print "LAST INSERT ID ".$dbh->last_insert_id();
      };
 }
 else { next; }
}


sub getID {
  my $num = scalar(@ID);
  @USED = ( @USED, pop @ID );

  my $id = $USED[-1];
  return $id if $id;
  
  if ( $num == 0 ) {

    # Зачем только это?
    print "================================\n\n";
    print "ТЕХНИЧЕСКИЙ ПЕРЕРЫВ 7 ЧАСОВ\n";
    print "=================================\n\n";
    sleep(10000);
    @ID = @USED;
    @USED = ();
  
our @ID = (
  "f6azxsgdyf2kunj9p4ce8x2f",
  "bbwpjrn242zgzwum728wuemz",
  "9q7q4bqq89z9kje3tkechxqx",
  "rcssye5qan69tgwzazz9yna6",
  "cv72bfkfxtfgc2jrdku3se2w",
  "38dtc4ymykw69r2h4asvqjzm",
  "b6fet4r8ddpuhsabx37qrpc9",
  "nhepurdcj2vjkjjmmj96yzcm",
  "hrh5sfmzrsw67vqxeur55w6a",
  "nqe7w6zkj8uprvgcxnk5f4da",
  "c5d8suqfbyy9zt49kqjkkbkj",
  "mq8tvd6ewbwszv58kpngx5rv",
);

   
  }  
  else {
  return 0;
  }
}
