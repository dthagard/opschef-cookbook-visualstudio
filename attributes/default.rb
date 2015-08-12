#
# Author:: Shawn Neal (<sneal@daptiv.com>)
# Cookbook Name:: visualstudio
# Attribute:: default
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

# Load the supported Visual Studio versions
include_attribute "visualstudio::vs2012"
include_attribute "visualstudio::vs2013"
include_attribute "visualstudio::vs2015"

default['visualstudio']['enable_nuget_package_restore'] = true

# Set this attribute to the version of visual studio you wish to install
default['visualstudio']['version'] = '2015'

# Set this attribute to the edition of visual studio you wish to install
default['visualstudio']['edition'] = 'enterprise' # or premium, professional, testprofessional, enterprise

# Set this attribute your self to the FQDN of the folder which contains the ISO
# default['visualstudio']['source'] = 'http://example.com:8080/visualstudio'

# Changing this may break the cookbook
default['visualstudio']['install_dir'] = node['visualstudio']['install_dir_' + node['visualstudio']['version']]
