# Include this module
class { 'nginx':
  php        => 'present',
  php_listen => 'socket',
}
