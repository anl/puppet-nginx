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

  # Install base web server
  package { $pkg: ensure => present }

  # Install and configure PHP:
  package { $php_pkg:
    ensure => $php,
  }
}
