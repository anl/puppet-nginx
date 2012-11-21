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
  $php = 'absent'
) {

  case $::operatingsystem {
    ubuntu: {
      $pkg = 'nginx'
      $php_pkg = 'php5-fpm'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # Install base web server and configuration

  package { $pkg: ensure => present }

  file { '/etc/nginx/nginx.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('nginx/nginx.conf.erb'),
    require => Package[$pkg],
  }

  # Install and configure PHP as appropriate:
  package { $php_pkg:
    ensure => $php,
  }

  # Manage service:
  service { 'nginx':
    enable => true,
  }
}
