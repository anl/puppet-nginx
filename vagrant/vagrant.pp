# Include this module
class { 'nginx':
  ipv6       => true,
  php        => 'present',
  php_listen => 'socket',
}

class { 'nginx::sites':
  django_sites => {
    'www.example.com'  => {
      logdir => '/srv/logs/www.example.com',
      root   => '/srv/www/www.example.com',
    },
    'test.example.com' => {
      activate    => false,
      logdir      => '/srv/logs/test.example.com',
      root        => '/srv/www/www.example.com',
      site_config => 'present',
    }
  },
  php_sites    => {
    'www.example.org'  => {
      additional_names => [ 'www2.example.org', 'www3.example.org' ],
      auth_basic       => {
        '/protected' => {
          'passwd' => '/srv/www/www.example.org/passwd',
          'realm'  => 'Password, please',
        }
      },
      ipv6             => true,
      logdir           => '/srv/logs/www.example.org',
      root             => '/srv/www/www.example.org/htdocs'
    },
    'www.example.net'  => {
      ipv6   => true,
      logdir => '/srv/logs/www.example.net',
      root   => '/srv/www/www.example.net/htdocs'
    },
    'www2.example.org' => {
      activate    => false,
      site_config => 'absent'
    }
  },
  static_sites =>   {
    'static.example.com' => {
      ipv6   => true,
      logdir => '/srv/logs/static.example.com',
      root   => '/srv/www/static.example.com/htdocs'
    }
  }
}
