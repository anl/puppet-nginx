# == Define: nginx::site::static
#
# Configure nginx for a static site.
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
#   Boolean indicating whether IPv6 should be enabled for a given
#   vhost; see also $ipv6 in init.pp.  Default: false
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
# nginx::site::static { 'www.example.org':
#   root => '/srv/www/example.org',
# }
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2013 Andrew Leonard
#
define nginx::site::static(
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

  $server_name = $name

  file { "/etc/nginx/sites-available/${server_name}":
    ensure  => $site_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('nginx/static.conf.erb'),
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
