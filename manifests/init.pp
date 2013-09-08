# == Class: nginx
#
# Module to deploy Nginx.
#
# Supports Ubuntu 12.04.
#
# === Parameters
#
# [*nginx_service*]
#   Boolean - enable nginx service?
#
# [*php*]
#   Ensure if php support is present or absent.
#
# [*php_listen*]
#   Where php-fpm should listen - 'port' or 'socket'
#
# [*php_service*]
#   Boolean - enable php5-fpm service?
#
# [*server_name*]
#   server_name value for Nginx configuration; set to the fqdn fact by default.
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
  $nginx_service = true,
  $php = 'absent',
  $php_listen = 'port',
  $php_service = true,
  $server_name = $::fqdn
) {

  validate_re($php, [ 'absent', 'present' ])
  validate_re($php_listen, [ 'port', 'socket' ])
  validate_re($server_name, '(?=^.{1,254}$)(^(?:(?!\d|-)[a-zA-Z0-9\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)') # ref. http://blog.gnukai.com/2010/06/fqdn-regular-expression/

  case $::operatingsystem {
    ubuntu: {
      $nginx_svc_name = 'nginx'
      $pkg = 'nginx'
      $php_pkg = 'php5-fpm'
      $php_svc_name = 'php5-fpm'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # Install packages and configuration
  ensure_packages([$pkg])

  if $php == 'present' {
    ensure_packages([$php_pkg])

    if $php_listen == 'port' {
      $php_listen_path = '127.0.0.1:9000'
    } else {
      $php_listen_path = '/var/run/php5-fpm.sock'
    }

    file { '/etc/php5/fpm/pool.d/www.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('nginx/www.conf.erb'),
      require => Package[$php_pkg],
      notify  => Service[$php_svc_name],
    }

    ensure_resource('service', $php_svc_name, { 'enable' => $php_service })

  }

  file { '/etc/nginx/nginx.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('nginx/nginx.conf.erb'),
    require => Package[$pkg],
    notify  => Service[$nginx_svc_name]
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => 'absent',
    require => Package[$pkg],
    notify  => Service[$nginx_svc_name],
  }

  # Manage Nginx service?:
  ensure_resource('service', $nginx_svc_name, { 'enable' => $nginx_service })
}
