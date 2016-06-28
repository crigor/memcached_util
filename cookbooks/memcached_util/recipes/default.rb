#
# Cookbook Name:: memcached_util
# Recipe:: default
#

if ['util'].include?(node[:instance_role]) && node[:name] == node[:memcached][:utility_name]
  enable_package "net-misc/memcached" do
    version node[:memcached][:version]
  end

  package "net-misc/memcached" do
    version node[:memcached][:version]
  end

  template "/etc/conf.d/memcached" do
    owner 'root'
    group 'root'
    mode 0644
    source "memcached.erb"
    variables({
      :memusage => node[:memcached][:memusage],
      :pidbase  => node[:memcached][:pidbase],
      :port     => 11211
    })
  end

  execute "monit reload" do
    action :nothing
  end

  template "/data/monit.d/memcached.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "memcached.monitrc.erb"
    variables({
      :pidfile => node[:memcached][:pidfile],
    })
    notifies :run, resources(:execute => "monit reload"), :delayed
  end
end

if ['solo', 'app', 'app_master', 'util'].include?(node[:instance_role])
  instances = node[:engineyard][:environment][:instances]
  memcached_instance = (node[:instance_role][/solo/] && instances.length == 1) ? instances[0] : instances.find{|i| i[:name] == node[:memcached][:utility_name]}

  if memcached_instance.nil?
    raise "Memcached instance named '#{node[:memcached][:utility_name]}' does not exist. Please fix the memcached_util recipe."
  end

  node[:engineyard][:environment][:apps].each do |app|
    directory "/data/#{app[:name]}/shared/config" do
      recursive true
      owner node[:owner_name]
      group node[:owner_name]
      mode 0755
    end

    template "/data/#{app[:name]}/shared/config/memcached_util.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "memcached_util.yml.erb"
      variables({
        :environment => node[:environment][:framework_env],
        :hostname => memcached_instance[:private_hostname]
      })
    end
  end
end

