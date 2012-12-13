# == Class: nginx::ufw
#
# Add Uncomplicated FireWall rules for nginx.  Requires
# seattle-biomed/puppet-nginx.
#
# === Parameters
#
# [*ensure*]
#   Whether rule is "present" or "absent".
#
# [*from*]
#   Source address for firewall rule, or "Anywhere".
#
# [*ip*]
#   Destination address for firewall rule.
#
# [*port*]
#   Port number for firewall rule - default 80.
#
# === Examples
#
# include nginx::ufw
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2012 Andrew Leonard, Seattle Biomedical Research Institute
#
class nginx::ufw (
  $ensure = 'present',
  $from = 'any',
  $ip = '',
  $port = 80
  ){

  ufw::allow { 'nginx':
    ensure => $ensure,
    from   => $from,
    ip     => $ip,
    port   => $port,
  }
}
