# == Class: nginx
#
# Module to deploy Nginx.
#
# Supports Ubuntu 12.04.
#
# === Parameters
#
# [*php*]
#   Ensure if php support is present or absent.
#
# [*server_name*]
#   server_name value for Nginx configuration; set to the fqdn fact by default.
#
# === Examples
#
#  include nginx
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2012 Andrew Leonard, Seattle Biomedical Research Institute
#
class nginx (
  $php = 'absent',
  $server_name = $::fqdn
) {

  # Validate parameters
  validate_re($php, [ 'absent', 'present' ])
  validate_re($server_name, '(?=^.{1,254}$)(^(?:(?!\d|-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)') # ref. http://blog.gnukai.com/2010/06/fqdn-regular-expression/

  case $::operatingsystem {
    ubuntu: {
      $pkg = 'nginx'
      $php_pkg = 'php5-fpm'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # Install packages and configuration
  ensure_packages([$pkg])

  if $php == 'present' {
    ensure_packages([$php_pkg])
  }

  file { '/etc/nginx/nginx.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('nginx/nginx.conf.erb'),
    require => Package[$pkg],
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => 'absent',
    require => Package[$pkg],
  }

  # Manage service:
  service { 'nginx':
    enable => true,
  }
}
