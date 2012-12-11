# == Define: nginx::sites::django
#
# Configure nginx for back-proxy to a Django/Gunicorn site.
#
# === Parameters
#
# [*activate*]
#   Set to "true" or "link" to place a symlink in /etc/nginx/sites-available.
#
# [*addl_media*]
#   Hash of media folders outside of root, with the URI as the key and the
#   file system path as the value.
#
# [*error_codes*]
#   HTTP error codes for which to show error_page (below).
#
# [*error_page*]
#   URI to display when server returns one of error_codes (above).
#
# [*proxy_host*]
#   Hostname or IP address to backproxy to.
#
# [*proxy_port*]
#   Port number to backproxy to; default 8000.
#
# [*root*]
#   Document root for requests.
#
# [*site_config*]
#   Set to 'absent' to remove the site configuration.
#
# === Examples
#
# nginx::sites::django { 'www.example.org':
#   root => '/opt/django-sites/example.org',
# }
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2012 Andrew Leonard, Seattle Biomedical Research Institute
#
define nginx::sites::django(
  $activate = true,
  $addl_media = {},
  $error_codes = [ 500, 502, 503, 504 ],
  $error_page = false,
  $proxy_host = 'localhost',
  $proxy_port = 8000,
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
    content => template('nginx/gunicorn.conf.erb'),
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
    require => File["/etc/nginx/sites-available/${server_name}"],
  }

}
