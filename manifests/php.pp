# == Class: nginx::php
#
# This clas is intended to add PHP support to Nginx.
#
# Tested on Ubuntu 12.04.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Examples
#
#  include nginx::php
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2012 Andrew Leonard, Seattle Biomedical Research Institute
#
class nginx::php {

  case $::operatingsystem {
    ubuntu: {
      $pkg = 'php5-fpm'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  package { $pkg: ensure => present }

}
