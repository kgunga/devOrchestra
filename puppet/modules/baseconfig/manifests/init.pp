# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class baseconfig {
  exec { 'apt-get update':
    command => 'apt-get -y update',
    path    => ['/bin', '/usr/bin']
  }

  Exec["apt-get update"] -> Package <| |>

  package {
    'python-software-properties':
  }

  package {
    ['tree', 'unzip', 'tar', 'python', 'git', 'screen', 'inotify-tools', 'cutils', 'findutils', 'mawk']:
      ensure => present;

    ['curl','wget', 'figlet', 'build-essential', 'libssl-dev']:
      ensure => present;
  }

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  file {
    '/home/vagrant/.bashrc':  # set up terminal colors
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0644',
      source => 'puppet:///modules/baseconfig/bashrc';

    # autostart script
    '/home/vagrant/devOrchestra':
      ensure => directory,
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0666';

    '/home/vagrant/devOrchestra/scripts':
      ensure => directory,
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0666',
      require => File['/home/vagrant/devOrchestra'];

    '/etc/rc.local':
      source => 'puppet:///modules/baseconfig/rc.local',
      owner => 'root',
      group => 'root',
      mode => '0755';

    '/home/vagrant/devOrchestra/scripts/on-system-up.sh':
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0755',
      require => File['/home/vagrant/devOrchestra/scripts'],
      source => 'puppet:///modules/baseconfig/on-system-up.sh';

    '/home/vagrant/devOrchestra/scripts/log.sh':
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0755',
      require => File['/home/vagrant/devOrchestra/scripts'],
      source => 'puppet:///modules/baseconfig/log.sh';

    '/home/vagrant/devOrchestra/scripts/logs':
      ensure => directory,
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0666';
  }

  exec {
    "Get nvm":
      command => "git clone git://github.com/creationix/nvm.git /home/vagrant/.nvm",
      user => "vagrant",
      group => "vagrant",
      creates => "/home/vagrant/.nvm/nvm.sh",
      unless => 'ls -lah /home/vagrant/.nvm',
      path => ['/usr/bin','/bin'],
      require => Package["git"];

    # add to hosts devOrchestra DNS name
    'Add devOrchestra to hosts':
      command => "echo '127.0.0.1 devOrchestra' >> /etc/hosts",
      unless => 'grep -q "devOrchestra" /etc/hosts',
      user => root,
      path => ['/bin','/usr/bin'];

   'Install nvm':
      command => "echo 'source /home/vagrant/.nvm/nvm.sh' >> /home/vagrant/.bashrc",
      user => vagrant,
      require => Exec['Get nvm'],
      onlyif => "grep -q 'source /home/vagrant/.nvm/nvm.sh' /home/vagrant/.bashrc; test $? -eq 1",
      path => ['/usr/bin','/bin'];

    'Install nodejs':
      command => "bash -c 'source /home/vagrant/.nvm/nvm.sh && nvm install node'",
      user => vagrant,
      require => Exec['Install nvm'],
      path => ['/usr/local/bin','/usr/local/sbin','/usr/bin/','/usr/sbin','/bin','/sbin'];

    'Install angular-cli':
      command => "bash -c 'source /home/vagrant/.nvm/nvm.sh && npm install -g angular-cli'",
      user => vagrant,
      require => Exec['Install nodejs'],
      path => ['/usr/local/bin','/usr/local/sbin','/usr/bin/','/usr/sbin','/bin','/sbin'];

    'Install nodemon':
      command => "bash -c 'source /home/vagrant/.nvm/nvm.sh && npm install -g nodemon'",
      user => vagrant,
      require => Exec['Install nodejs'],
      path => ['/usr/local/bin','/usr/local/sbin','/usr/bin/','/usr/sbin','/bin','/sbin'];

    'Get wetty':
      command => "git clone https://github.com/krishnasrinivas/wetty",
      cwd => '/home/vagrant/devOrchestra',
      unless => 'ls -lah /home/vagrant/devOrchestra/wetty',
      user => "vagrant",
      group => "vagrant",
      creates => "/home/vagrant/devOrchestra/wetty",
      require => Package['git'],
      path => ['/usr/bin/','/bin'];

  }

}