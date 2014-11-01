#!/usr/bin/env perl
use Getopt::Long;
use warnings;
use strict;

my $steamdir="/home/unreal/Steam";
my $steamcmd="/home/unreal/steamcmd/steamcmd.sh";
my $killingfloordir="/home/unreal/killingfloor";
my $killingfloorsystemdir=$killingfloordir."/System";
my $killingfloormapsdir=$killingfloordir."/Maps";
my $updatescript="/home/unreal/scripts/update_kf_ds.txt";
my $vac="true";
my $slots="8";
my $log="/home/unreal/killingfloor/server.log";

sub killservers {
	print( "Killing Current Server(s)\n");
	system("killall ucc-bin-real");
	system("killall ucc-bin");
}

sub update_killingfloor {
	system($steamcmd." +runscript ".$updatescript); 
}

sub startserver {
	my $level = shift;
	my $adminuser = shift;
	my $adminpassword = shift;
	print ("Starting KF Server on level " . $level . "...\n");
	if(defined($level)) {
		my $servercommand=$killingfloorsystemdir."/ucc-bin server ".$level;
		$servercommand.="?game=KFmod.KFGameType";
		$servercommand.="?VACSecured=".$vac;
		$servercommand.="?MaxPlayers=".$slots;
		# admin options
		if(defined($adminuser) && defined($adminpassword) ) {
			$servercommand.="?AdminName=".$adminuser."?AdminPassword=".$adminpassword;	
		}
		# logging options
		$servercommand.="? -nohomedir ini=KillingFloor.ini LOG=".$log;
		print $servercommand."\n";
		# start teh server
		chdir($killingfloorsystemdir);
		system($servercommand);
	}
	else {
		print STDERR "No level specified!\n";
	}
}


# gets the contents of $killingfloormapsdir and returns it as an array
sub getLevelList {
	my @levels;
	opendir (DIR, $killingfloormapsdir) or die $!;
	while (my $file = readdir(DIR)) {
		if( $file ne "." && $file ne ".." ) {
			push(@levels, $file);
		}
	}
	closedir(DIR);
	return @levels;
}

sub getLevel {
	my @levels = getLevelList();
	my $level = "";
	array_print(\@levels);
	print("\n");
	do { 
		print ("Select a level:\n");
		$level = <STDIN>;
		chomp $level;
	} while (array_contains_string(\@levels,$level)==0);
	return $level;
}

# checks to see if an array contains a specified value
# 1 = true 
# 0 = false
sub array_contains_string {
	my ($array_ref,$level) = @_;
	my @array = @{$array_ref};
	foreach(@array) {
		if ($level eq $_) {
			return 1;
		}
	}
	return 0;
}


# print the contents of an array reference
sub array_print {
	my $array_ref = shift; 
	my @array = @{$array_ref};
	foreach(@array) {
		print ($_."\n");
	}
}


########## MAIN ##############################
#
# GetOpts
#
my $level;
my $start;
my $stop;
my @admin;
my $levellist;
GetOptions('level=s' => \$level, 
	'start' => \$start, 
	'stop' => \$stop, 
	'levellist' => \$levellist,
	'admin=s{2}' => \@admin);
if ($levellist) {
	print("LevelList...\n");	
	my @levels = getLevelList();
	array_print(\@levels);
} else {
	if ($stop || $start ) {
		killservers();
	}
	if ($start) {
		if(!defined($level)) {
			$level = getLevel();
		}
		# update_killingfloor();
		startserver($level, @admin);
	}
}

