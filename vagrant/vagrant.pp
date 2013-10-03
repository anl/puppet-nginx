# Include this module
class { 'nginx':
  php        => 'present',
  php_listen => 'socket',
}

class { 'nginx::sites':
  django_sites => {
    'www.example.com' => {
      root => '/srv/www/www.example.com'
    }
  },
  php_sites    => {
    'www.example.org' => {
      root => '/srv/www/www.example.org'
    }
  }
}
