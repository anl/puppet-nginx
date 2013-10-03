# == Class: nginx::sites
#
# Configure an nginx virtual host.  Written for use with Hiera.
#
# Developed for Ubuntu; tested on 12.04.
#
# === Parameters
#
# [*django_sites*]
#   Hash describing django sites to create.  See nginx::site::django for hash
#   keys.
#
# [*php_sites*]
#   Hash describing PHP sites to create.  See nginx::site::php for hash keys.
#
# === Examples
#
# include nginx::sites
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2012 Andrew Leonard, Seattle Biomedical Research Institute
# Copyright 2013 Andrew Leonard
#
class nginx::sites($django_sites = {}, $php_sites = {}) {

  create_resources(nginx::site::django, $django_sites)

  create_resources(nginx::site::php, $php_sites)
}
