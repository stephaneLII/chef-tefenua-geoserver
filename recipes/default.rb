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
