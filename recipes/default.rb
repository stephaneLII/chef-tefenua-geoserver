#
# Cookbook Name:: chef-tefenua-geoserver
# Recipe:: default
#
# Copyright (C) 2015 Stephane LII
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt::default"
include_recipe 'chef-tefenua-geoserver::_tomcat'

package 'unzip' do
   action :install
end

package 'subversion' do
   action :install
end

package 'fontconfig' do
   action :install
end

delete_dir_fonts = "rm -rf #{node['chef-tefenua-geoserver']['fonts_dir']}" + "/*"
delete2_dir_fonts = "rm -rf #{node['chef-tefenua-geoserver']['fonts_dir']}" + "/.svn"

bash 'delete-fonts' do
  user 'root'
  code <<-EOH
   #{delete_dir_fonts}
   #{delete2_dir_fonts}
  EOH
end

subversion "fonts" do
  repository "#{node['chef-tefenua-geoserver']['fonts_svn_link']}"
  revision "HEAD"
  destination "#{node['chef-tefenua-geoserver']['fonts_dir']}"
  svn_username "#{node['chef-tefenua-geoserver']['user_svn']}"
  svn_password "#{node['chef-tefenua-geoserver']['passwd_svn']}"
  action :sync
end

bash 'configure-fonts' do
  user 'root'
  code <<-EOH
   fc-cache -f
  EOH
end

# Installing specific JARS in the jvm
#####################################

directory node['chef-tefenua-geoserver']['jar_dir'] do
   owner "root"
   group "root"
   mode '0755'
   action :create
   recursive true
end

subversion "jar" do
  repository "#{node['chef-tefenua-geoserver']['jar_svn_link']}"
  revision "HEAD"
  destination "#{node['chef-tefenua-geoserver']['jar_dir']}"
  svn_username "#{node['chef-tefenua-geoserver']['user_svn']}"
  svn_password "#{node['chef-tefenua-geoserver']['passwd_svn']}"
  action :sync
end

extract_jars = "ls #{node['chef-tefenua-geoserver']['jar_dir']}/*.tgz | while read f ; do tar -xzf $f ; done"

bash 'extract_jar' do
  user 'root'
  cwd "#{node['java']['java_home']}"
  code <<-EOH
   #{extract_jars}
  EOH
end

directory node['tomcat']['webapp_dir'] + '/geoserver' do
   owner "#{node['tomcat']['user']}"
   group "#{node['tomcat']['group']}"
   mode '0755'
   action :create
   recursive true
end

subversion "geoserverconf" do
  repository "#{node['chef-tefenua-geoserver']['geoserver_svn_link']}"
  revision "HEAD"
  destination "#{node['tomcat']['webapp_dir']}" + "/" + "geoserver"
  svn_username "#{node['chef-tefenua-geoserver']['user_svn']}"
  svn_password "#{node['chef-tefenua-geoserver']['passwd_svn']}"
  action :sync
end

chmod = "chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['tomcat']['webapp_dir']}" + "/geoserver"

bash 'chown_geoserver_directory' do
  user 'root'
  cwd "#{node['tomcat']['webapp_dir']}" + "/" + "geoserver"
  code <<-EOH
   #{chmod}
  EOH
  notifies :restart, 'service[tomcat7]'
end
