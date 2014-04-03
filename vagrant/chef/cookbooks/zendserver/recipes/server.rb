execute "install zend key" do
  command "wget http://repos.zend.com/zend.key -O- |apt-key add -"
  not_if "apt-key list| grep -c zend"
end

execute "install zend repo" do
  command "echo 'deb http://repos.zend.com/zend-server/6.0/deb_ssl1.0 server non-free' >> /etc/apt/sources.list"
  not_if "grep 'http://repos.zend.com/zend-server/6.0/deb_ssl1.0' -c /etc/apt/sources.list"
end

execute "update apt" do
  command "apt-get update -q -y"
end

package "zend-server-php-5.4"
package "apache2-mpm-itk"
package "curl"

execute "install composer" do
  command "curl -sS https://getcomposer.org/installer | /usr/local/zend/bin/php -- --install-dir=/usr/local/bin"
end

execute "create composer symlink" do
  command "ln -s /usr/local/bin/composer.phar /usr/local/bin/composer"
  only_if "test -f /usr/local/bin/composer.phar"
  not_if "test -L /usr/local/bin/composer"
end

cookbook_file "/etc/profile.d/zend-server.sh" do
  source "zend-server.sh"
  group "root"
  owner "root"
  mode "0644"
end

cookbook_file "/etc/apache2/sites-available/vagrant-apache.conf" do
  source "vagrant-apache.conf"
  group "root"
  owner "root"
end

execute "disable default site" do
  command "a2dissite default"
end

execute "enable app site" do
  command "a2ensite vagrant-apache.conf"
end


# set-up https
execute "add mod ssl" do
  command "a2enmod ssl"
end

FileUtils.mkdir_p '/etc/apache2/ssl'

execute "create cert" do
  command "openssl req -new -x509 -subj \"/C=/ST=/L=/O=/CN=/L=/\" -days 365 -nodes -out /etc/apache2/ssl/apache.pem -keyout /etc/apache2/ssl/apache.key"
end 

# install PHPUnit
execute "config pear" do
  command "/usr/local/zend/bin/pear config-set auto_discover 1"
end

execute "install PHPUnit" do  
  command "/usr/local/zend/bin/pear install --alldeps pear.phpunit.de/PHPUnit-3.7.27"
  not_if "phpunit --version | grep PHPUnit"
end

# edit pcntl.ini (required for PHPUnit)
template "/usr/local/zend/etc/conf.d/pcntl.ini" do
  source "pcntl.ini.erb"
  owner "root"
  group "zend"
  mode "0644"
end

# install invoker
execute "install PHPUnit Invoker" do  
  command "/usr/local/zend/bin/pear install pear install phpunit/PHP_Invoker"
  not_if "pear list -c phpunit | grep PHP_Invoker"
end

# install selenium
execute "install PHPUnit Selenium" do  
  command "/usr/local/zend/bin/pear install pear install phpunit/PHPUnit_Selenium"
  not_if "pear list -c phpunit | grep PHPUnit_Selenium"
end

# install story test case 
execute "install PHPUnit Story" do  
  command "/usr/local/zend/bin/pear install pear install phpunit/PHPUnit_Story"
  not_if "pear list -c phpunit | grep PHPUnit_Story"
end

# install dbunit 
execute "install DbUnit" do  
  command "/usr/local/zend/bin/pear install phpunit/DbUnit"
    not_if "pear list -c phpunit | grep DbUnit"
end

# update freetds
template "/etc/freetds/freetds.conf" do
  source "freetds.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :version => node[:freetds][:version],
    :client_charset => node[:freetds][:client_charset]
  })
end


# edit php.ini
template "/usr/local/zend/etc/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
end


# edit mssql.ini
template "/usr/local/zend/etc/conf.d/mssql.ini" do
  source "mssql.ini.erb"
  owner "root"
  group "zend"
  mode "0644"
end


# getting ZF 1.10.5 (ZF 1.12 not backwards compatible for ZendForms)
remote_file "/tmp/ZendFramework-1.10.5.tar.gz" do
  user "vagrant"
  source "https://packages.zendframework.com/releases/ZendFramework-1.10.5/ZendFramework-1.10.5.tar.gz"
  not_if "ls -la /tmp | grep ZendFramework-1.10.5.tar.gz"
end

execute "extract" do
  command "tar zxf /tmp/ZendFramework-1.10.5.tar.gz"
  cwd "/tmp"
end

execute "move" do
  command "mv /tmp/ZendFramework-1.10.5 /usr/local/zend/share"
  not_if "ls -la /usr/local/zend/share | grep ZendFramework-1.10.5"
end


service "apache2" do
  action :restart
end
