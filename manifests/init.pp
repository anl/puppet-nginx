# == Class: nginx
#
# Module to deploy Nginx.
#
# Supports Ubuntu 12.04.
#
# === Parameters
#
# [*ipv6*]
#   Boolean indicating whether IPv6 should be enabled server-wide;
#   IPv6 must be enabled or not for each given "server" (vhost).
#   Default: false
#
# [*nginx_service*]
#   Boolean - enable nginx service?
#
# [*php*]
#   Ensure if php support is present or absent.
#
# [*php_apc*]
#   Install Alternative PHP Cache with PHP?  Default: true.
#
# [*php_apc_shm_size*]
#   Alternative PHP Cache shared memory segment size; format is an integer
#   followed by 'M' for megabytes.  Default: 32M
#
# [*php_gd*]
#   Install PHP GD with PHP?  Default: true.
#
# [*php_suhosin*]
#   Install PHP Suhosin security patch with PHP?  Default: true.
#
# [*php_listen*]
#   Where php-fpm should listen - 'port' or 'socket'
#
# [*php_service*]
#   Boolean - enable php5-fpm service?
#
# [*port*]
#   Port to listen on.  Default: 80
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
  $ipv6 = false,
  $nginx_service = true,
  $php = 'absent',
  $php_listen = 'port',
  $php_service = true,
  $php_apc = true,
  $php_apc_shm_size = '32M',
  $php_gd = true,
  $php_suhosin = true,
  $port = 80,
  $server_name = $::fqdn
) {

  validate_bool($ipv6)
  validate_bool($nginx_service, $php_apc, $php_gd, $php_suhosin, $php_service)
  validate_string($server_name)

  validate_re($php, [ 'absent', 'present' ])
  validate_re($php_listen, [ 'port', 'socket' ])
  validate_re($php_apc_shm_size, '^\d+M$')

  case $::operatingsystem {
    ubuntu: {
      $nginx_svc_name = 'nginx'
      $pkg = 'nginx'
      $php_pkg = 'php5-fpm'
      $php_svc_name = 'php5-fpm'

      $apc_pkg = 'php-apc'
      $gd_pkg = 'php5-gd'
      $suhosin_pkg = 'php5-suhosin'

    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }

  # Install packages and configuration
  ensure_packages([$pkg])

  if $php == 'present' {
    ensure_packages([$php_pkg])

    if $php_apc {
      ensure_packages([$apc_pkg])

      file { '/etc/php5/conf.d/apc.ini':
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('nginx/apc.ini.erb'),
        require => Package[$apc_pkg],
        notify  => Service[$php_svc_name],
      }
    }

    if $php_gd {
      ensure_packages([$gd_pkg])
    }

    if $php_suhosin {
      ensure_packages([$suhosin_pkg])
    }

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

    file { '/etc/php5/fpm/php.ini':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/nginx/php.ini',
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
