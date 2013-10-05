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
      auth_basic => {
        '/protected' => {
          'passwd' => '/srv/www/www.example.org/passwd',
          'realm'  => 'Password, please',
        }
      },
      root       => '/srv/www/www.example.org/htdocs'
    }
  }
}
