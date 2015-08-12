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

install_path = "C:\\VisualStudioInstall"
install_log_file = win_friendly_path(File.join(node['visualstudio']['install_dir'], 'vsinstall.log'))

setup_exe_path = win_friendly_path(File.join(install_path, node['visualstudio'][edition]['installer_file']))
admin_deployment_xml_file = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'AdminDeployment.xml'))

remote_file iso_path do
  source iso_url
  not_if { vs_is_installed }
end

powershell_script 'Mount ISO' do
  guard_interpreter :powershell_script
	code  <<-EOH
		$Image = Mount-DiskImage -ImagePath "#{iso_path}" -NoDriveLetter -PassThru
    $Vol = Get-Volume -DiskImage $Image
    $Drive = Get-WmiObject win32_volume -Filter "Label = '$($Vol.FileSystemLabel)'" -ErrorAction Stop
    $Drive.AddMountPoint("C:\\VisualStudioInstall")
	EOH
  not_if { vs_is_installed }
end

# Create installation config file
cookbook_file admin_deployment_xml_file do
  source version + '/AdminDeployment-' + edition + '.xml'
  action :create
  not_if { vs_is_installed }
end

# Install Visual Studio
windows_package node['visualstudio'][edition]['package_name'] do
  source setup_exe_path
  installer_type :custom
  options "/Q /norestart /Log \"#{install_log_file}\" /AdminFile \"#{admin_deployment_xml_file}\""
  timeout 3600 # 1hour
  success_codes [0, 42, 127, 3010] # 3010 - reboot required
  not_if { vs_is_installed }
end
