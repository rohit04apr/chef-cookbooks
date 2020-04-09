#
# Cookbook Name:: hc_vault
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'
item = chef_vault_item("hc_vault", "root")
passwd = item["password"]
Chef::Log.info "decrypted password is #{passwd}"
#item = ChefVault::Item.load("hc_vault", "root")
#item = chef_vault_item("hc_vault", "root")
#passwd = item["password"]
#Chef::Log.info "decrypted password is #{passwd}"

