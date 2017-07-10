ifndef _ARCH
  _distro := $(shell lsb_release -i | cut -f2)
  export _distro
endif

prepare:
ifeq ($(_distro),Debian)
	apt-get -y install libgetopt-long-descriptive-perl libconfig-simple-perl liblog-log4perl-perl libberkeleydb-perl
endif
ifeq ($(_distro),$(filter $(_distro), CentOS Fedora RedHat))
	yum -y install perl-Getopt-Long-Descriptive perl-Config-Simple perl-Log-Log4perl perl-BerkeleyDB
endif

install:

update:

update_apps:

clean:

test:
#	perl tests/test.t
#	perl tests/srv.t
