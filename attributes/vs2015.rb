#
# Cookbook Name:: visualstudio
# Attribute:: vs2015
#

# Installation directory
default['visualstudio']['install_dir_2015'] = (ENV['ProgramFiles(x86)'] || 'C:\Program Files (x86)') + '\Microsoft Visual Studio 14.0'

# Visual Studio 2015 Enterprise
default['visualstudio']['enterprise']['installer_file'] = 'vs_enterprise.exe'
default['visualstudio']['enterprise']['filename'] = 'en_visual_studio_enterprise_2015_x86_x64_dvd_6850497.iso'
default['visualstudio']['enterprise']['package_name'] = 'Microsoft Visual Studio Enterprise 2015'
default['visualstudio']['enterprise']['checksum'] = '12db74d1e6243924c187069ad95cee58b687dcb9ba2d302fc6ae889fb4ae7694'
