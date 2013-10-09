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
# [*additional_names*]
#   Array of additional server_name values for vhost. Default: []
#
# [*auth_basic*]
#   Hash to configure basic authentication for an arbitrary collection of
#   directories.  Keys are locations, values are a hash containing the
#   following keys:
#   - passwd: Path to password file
#   - realm: String defining "protection space" (RFC 1945, 2617); *Double
#            quotes must be escaped!*
#   Default: {}
#
# [*ipv6*]
#   Boolean indicating whether IPv6 should be enabled.  Default: false
#
# [*logdir*]
#   Path to vhost log directory.
#
# [*port*]
#   Port to listen on.  Default: 80
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
  $logdir,
  $root,
  $activate = true,
  $additional_names = [],
  $auth_basic = {},
  $ipv6 = false,
  $port = 80,
  $site_config = 'present'
  ){

  validate_absolute_path($logdir)
  validate_absolute_path($root)
  validate_array($additional_names)
  validate_bool($ipv6)

  # Construct listen configuration:
  if $nginx::php_listen == 'socket' {
    $listen_prefix = 'unix:'
  } else {
    $listen_prefix = ''
  }
  $upstream_path = "${listen_prefix}${nginx::php_listen_path}"

  $server_name = $name

  file { "/etc/nginx/sites-available/${server_name}":
    ensure  => $site_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('nginx/php.conf.erb'),
    notify  => Service['nginx'],
    require => Package['nginx'],
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
