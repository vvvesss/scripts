#!/usr/bin/perl
use strict;


#The purpose of this script is to dynamicaly create host records and ssh aliases from your GCE list.

#Requirements
#This script will work on unix like os (Linux, FreeBSD, MacOS, etc.)
#You need to have working gcloud command and access to instances list

#First check if this works for you:
#gcloud compute instances list --format="csv(NAME,ZONE,MACHINE_TYPE,PREEMPTIBLE,INTERNAL_IP,EXTERNAL_IP,STATUS)"

#Create this ssh function in your bash profile
#You may need to change this syntax if not using bash 
#sg () {
#  ip=${1}
#  ssh <your_gcp_user>@$ip
#}

#change your bash profile name and/or location
my $profile = "~/.bash_profile";

#After running the script you need to load your profile again. 
#You can do this with > source your_bash_profile_location 

#Voala! 
#Now hostnames are bound to your GCE internal ip's
#Now you can ssh to your remote compute instances just by using their Names
#If anything changes like ip or name, run this script again and it will replace faulty records


my $list = `gcloud compute instances list --format="csv(NAME,ZONE,MACHINE_TYPE,PREEMPTIBLE,INTERNAL_IP,EXTERNAL_IP,STATUS)"`;

my @gcplist = split('\n', $list);

shift @gcplist;

my $hosts_list = `cat /etc/hosts`;
my $alias_list = `cat $profile`;

foreach (@gcplist) {
    my @host = split(',',$_);

    #check and update hosts
    if ($hosts_list !~ /@host[4]/ && $hosts_list !~ /@host[0]/) {
        print "creating host record for missing host @host[0]\n";
        $hosts_list .= "@host[4]\t@host[0]\n";
    } elsif ($hosts_list !~ /\n@host[4]/) {
        print "replacing host record for missing ip @host[4] and existing name @host[0]\n";
        $hosts_list = $hosts_list =~ s/\n.*?\s+@host[0]\n/\n@host[4]\t@host[0]\n/r;
    } elsif ($hosts_list !~ /@host[0]/) {
        print "replacing host record for existing ip @host[4] and missing name @host[0]\n";
        $hosts_list = $hosts_list =~ s/\n@host[4]\s+.*?\n/\n@host[4]\t@host[0]\n/r;
    } else {
        print "host record for @host[4] exists!\n"
    }

    #check and update aliases
    if ($alias_list !~ /@host[4]/ && $alias_list !~ /@host[0]/) {
        print "creating alias record for missing host @host[0]\n";
        $alias_list .= "alias @host[0]='sg @host[4]'\n";
    } elsif ($alias_list !~ /@host[4]/) {
        print "replacing alias record for missing ip @host[4] and existing name @host[0]\n";
        $alias_list = $alias_list =~ s/\nalias\s+@host[0]='sg\s+.*?\n/\nalias @host[0]='sg @host[4]'\n/r;
    } elsif ($alias_list !~ /@host[0]/) {
        print "replacing alias record for existing ip @host[4] and missing name @host[0]\n";
        $alias_list = $alias_list =~ s/\nalias\s+.*?='sg\s+@host[4]'\n/\nalias @host[0]='sg @host[4]'\n/r;
    } else {
        print "alias record for @host[4] exists!\n"
    }
}

open (FH, ">", "/etc/hosts") or die "File /etc/hosts couldn't be opened";
print FH $hosts_list;
close FH or "couldn't close";

open (FH, ">", $profile) or die "File $profile couldn't be opened";
print FH $alias_list;
close FH or "couldn't close";


# print $hosts_list;
# print $alias_list;

