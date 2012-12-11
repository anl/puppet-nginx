# == Class: nginx::sites
#
# Configure an nginx virtual host.  Written for use with Hiera.
#
# Developed for Ubuntu; tested on 12.04.
#
# === Parameters
#
# [*django_sites*]
#   Hash describing django sites to create.  See nginx::sites::django for hash
#   keys.
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
#
class nginx::sites($django_sites = {}) {

  create_resources(nginx::sites::django, $django_sites)

}
