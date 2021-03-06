
package {"iptables":
	ensure => "purged"
}

exec {"get repository":
	command => "/usr/bin/rpm -iUvh http://ftp.astral.ro/mirrors/fedora/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm"
}

package {"proftpd":
	ensure => installed,
	require => Exec["get repository"]
}

service{"proftpd":
	ensure => running,
	enable => true,
	hasstatus => true,
	hasrestart => true,
	require => File["/etc/sysconfig/proftpd"]
}

file{"/etc/hosts":
	content => "192.168.33.40 informadusdb.informadus"
}

package {"postgresql-server":
	ensure => latest,
	require => File["/etc/hosts"]
}

exec {"initdb":
	command => "/usr/bin/initdb -D /var/lib/pgsql/data",
	user => "postgres",
	require => Package["postgresql-server"]
}

service{"postgresql":
	ensure => running,
	enable => true,
	hasstatus => true,
	hasrestart => true,
	require => File["/var/lib/pgsql/data/postgresql.conf"]
}

file{"/etc/sysconfig/proftpd":
	content => "PROFTPD_OPTIONS='-DANONYMOUS_FTP'",
	require => Package["proftpd"]
}

file{"/var/lib/pgsql/data/postgresql.conf":
	ensure => file,
	content => template("/vagrant/templates/postgresql.conf"),
	require => File["/var/lib/pgsql/data/pg_hba.conf"]
}

file{"/var/lib/pgsql/data/pg_hba.conf":
	ensure => file,
	content => template("/vagrant/templates/pg_hba.conf"),
	require => Exec["initdb"]
}


