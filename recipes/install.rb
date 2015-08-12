#
# Author:: Shawn Neal <sneal@daptiv.com>
# Cookbook Name:: visualstudio
# Recipe:: install
#
# Copyright 2013, Daptiv Solutions, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Visualstudio::Helper)

vs_is_installed = is_vs_installed?()

# Ensure the installation ISO url has been set by the user
if !node['visualstudio']['source']
  raise 'visualstudio source attribute must be set before running this cookbook'
end

version = 'vs' + node['visualstudio']['version']
edition = node['visualstudio']['edition']

iso_url = File.join(node['visualstudio']['source'], node['visualstudio'][edition]['filename'])
iso_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], node['visualstudio'][edition]['filename']))

install_log_file = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'vsinstall.log'))

admin_deployment_xml_file = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'AdminDeployment.xml'))

remote_file iso_path do
  source iso_url
  checksum node['visualstudio'][edition]['checksum']
  not_if { File.exists?(iso_path)}
end

# Create installation config file
cookbook_file admin_deployment_xml_file do
  source version + '/AdminDeployment-' + edition + '.xml'
  action :create
  not_if { vs_is_installed }
end

#reboot 'Restart Computer' do
#  action :nothing
#end

# Install Visual Studio
powershell_script "Install #{node['visualstudio'][edition]['package_name']}" do
  code <<-EOH
    $ImagePath = "#{iso_path}"

    Mount-DiskImage -ImagePath $ImagePath
    $DriveLetter = (Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter

    $Command = "${DriveLetter}:\\#{node['visualstudio'][edition]['installer_file']}"
    $ArgList = "/Q /norestart /Log `"#{install_log_file}`" /AdminFile `"#{admin_deployment_xml_file}`""

    Start-Process -FilePath $Command -ArgumentList $ArgList -Wait

    Dismount-DiskImage -ImagePath $ImagePath

	Exit 0
  EOH
  returns [0, 1]
  guard_interpreter :powershell_script
  not_if { vs_is_installed }
  # notifies :reboot_now, 'reboot[Restart Computer]', :immediately
end
