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
# [*static_sites*]
#   Hash describing static sites to create.  See nginx::site::static for hash
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
# Copyright 2013 Andrew Leonard
#
class nginx::sites(
  $django_sites = {},
  $php_sites = {},
  $static_sites = {}
  ) {

  create_resources(nginx::site::django, $django_sites)

  create_resources(nginx::site::php, $php_sites)

  create_resources(nginx::site::static, $static_sites)

  # Construct listen configuration:
  if $nginx::php_listen == 'socket' {
    $listen_prefix = 'unix:'
  } else {
    $listen_prefix = ''
  }
  $upstream_path = "${listen_prefix}${nginx::php_listen_path}"

  $size = size(keys($php_sites))

  if size(keys($php_sites)) > 0 {
    file { '/etc/nginx/conf.d/php-fpm.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      content => template('nginx/php-fpm.conf.erb'),
      notify  => Service['nginx'],
      require => Package[$::nginx::pkg],
    }
  }

}
