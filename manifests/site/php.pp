# == Define: nginx::site::php
#
# Configure nginx for a PHP site.
#
# Intended to be appropriate for off-the-shelf open source PHP sites, such
# as Wordpress and Gallery.
#
# === Parameters
#
# [*activate*]
#   Set to "true" or "link" to place a symlink in /etc/nginx/sites-available.
#
# [*root*]
#   Document root for requests.
#
# [*site_config*]
#   Set to 'absent' to remove the site configuration.
#
# === Examples
#
# nginx::site::php { 'www.example.org':
#   root => '/srv/www/example.org',
# }
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
define nginx::site::php(
  $activate = true,
  $root = undef,
  $site_config = 'present'
  ){

  if $root == undef {
    fail('Nginx site document root must be specified.')
  }

  $server_name = $name

  file { "/etc/nginx/sites-available/${server_name}":
    ensure  => $site_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('nginx/php.conf.erb'),
    notify  => Service['nginx'],
  }

  if $activate == true {
    $symlink_state = 'link'
  } else {
    $symlink_state = $activate
  }

  file { "/etc/nginx/sites-enabled/${server_name}":
    ensure  => $symlink_state,
    target  => "/etc/nginx/sites-available/${server_name}",
    notify  => Service['nginx'],
    require => File["/etc/nginx/sites-available/${server_name}"],
  }

}
