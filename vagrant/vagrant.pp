# Include this module
class { 'nginx':
  php        => 'present',
  php_listen => 'socket',
}

nginx::site::django { 'www.example.com':
  root => '/srv/www/www.example.com',
}

nginx::site::php { 'www.example.org':
  root => '/srv/www/www.example.org',
}
