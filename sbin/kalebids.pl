#!/usr/bin/perl
use strict;
use warnings;
use Log::Log4perl;
use Getopt::Long;
use Pod::Usage;
use Config::Simple;
use BerkeleyDB;
use POSIX qw(strftime);
my $help = 0;
my $debug = 0;
my ($config, $command, $app, $version) = ("", "", "", "");

Getopt::Long::Configure('bundling');
GetOptions(
  "c|config=s"     => \$config,
  "h|help"       => \$help,
  "d|debug"      => \$debug,
);

pod2usage( { -exitval=>1,  -verbose => 99, -sections =>[qw(SYNOPSIS OPTIONS)] } )  if ($help);

$config = defined($config) && $config ne "" ? $config : "/etc/buildctl/buildsrv.conf";

my $cfg = new Config::Simple();
$cfg->read($config);
my $log = $cfg->get_block("log");
our $cc = $cfg->get_block("config");

$log->{'loglevel'} = "DEBUG" if ($debug);
my $log_conf;
if ( $debug ) {
$log_conf = "
	log4perl.rootLogger=$log->{'loglevel'}, screen, Logfile
	log4perl.appender.screen = Log::Log4perl::Appender::Screen
	log4perl.appender.screen.stderr = 0
	log4perl.appender.screen.layout = PatternLayout
	log4perl.appender.screen.layout.ConversionPattern = %d %p> %F{1}:%L %M - %m%n

	log4perl.appender.Logfile=Log::Log4perl::Appender::File
  	log4perl.appender.Logfile.filename=$log->{'logfile'}
	log4perl.appender.Logfile.mode=append
	log4perl.appender.Logfile.layout=PatternLayout
	log4perl.appender.Logfile.layout.ConversionPattern=%d %-5p %c - %m%n
";
} else {
	$log_conf = "log4perl.rootLogger=$log->{'loglevel'}, Logfile
	log4perl.appender.Logfile=Log::Log4perl::Appender::File
  	log4perl.appender.Logfile.filename=$log->{'logfile'}
	log4perl.appender.Logfile.mode=append
	log4perl.appender.Logfile.layout=PatternLayout
	log4perl.appender.Logfile.layout.ConversionPattern=%d %-5p %c - %m%n
";
}

Log::Log4perl->init(\$log_conf);
our $ll = Log::Log4perl->get_logger();

my %h;
tie %h, 'BerkeleyDB::Btree',
                -Filename   => $cc->{'database'},
                -Flags      => DB_CREATE
		      or die "Cannot open $cc->{'database'}: $! $BerkeleyDB::Error\n";
untie %h;

__END__

=head1 SYNOPSIS

 kalebids.pl [-c <config] 
                    
=head1 DESCRIPTION

 kalebids.pl is a intrusion detection system

=head1 OPTIONS

=head2 GENERAL OPTIONS

=over 

=item B<-c, --config>

use config file

