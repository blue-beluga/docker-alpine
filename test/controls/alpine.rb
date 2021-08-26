# encoding: UTF-8
#
# Author: Stefano Harding <riddopic@gmail.com>
# Copyright (C) 2016 Stefano Harding
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

title 'Alpine Linux release'

alpine_version = input('alpine_version')
alpine_version_id = input('alpine_version_id')

control 'alpine-01' do
  impact 1.0
  title 'Check the Alpine Linux release'
  desc 'Ensure that the correct release of Alpine Linux is used.'

  describe os.name do
    it { should eq 'alpine' }
  end

  describe os.family do
    it { should eq 'linux' }
  end

  describe os.release do
    it { should eq alpine_version_id }
  end
end

# control 'alpine-02' do
#   impact 0.5
#   title 'Check the system is using a 64-bit kernel'
#   desc 'Ensure that Alpine Linux is running with a 64-bit kernel.'
#
#   describe os.arch do
#     it { should eq 'x86_64' }
#   end
#
#   describe command('uname -a | grep -o x86_64') do
#     its('exit_status') { should eq 0 }
#     its('stdout') { should match /^x86_64$/ }
#     its('stderr') { should eq '' }
#   end
# end

control 'alpine-03' do
  impact 1.0
  title 'The /etc/os-release file must exist'
  desc 'Check periodically the owner and permissions for /etc/os-release.'

  describe file('/etc/os-release') do
    it { should exist }
  end
end

control 'alpine-04' do
  impact 1.0
  title 'The /etc/os-release file must be the correct type'
  desc 'Check periodically the owner and permissions for /etc/os-release.'

  describe file('/etc/os-release') do
    it { should be_file }
  end

  describe file('/etc/os-release') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'alpine-05' do
  impact 1.0
  title 'The /etc/os-release file must be owned by root'
  desc 'Ensure the owner of /etc/os-release is correctly set to root.'

  describe file('/etc/os-release') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'alpine-06' do
  impact 1.0
  title 'The /etc/os-release file must be group-owned by root'
  desc 'Ensure the group of /etc/os-release is correctly set to root.'

  describe file('/etc/os-release') do
    its('group') { should eq 'root' }
  end
end

control 'alpine-07' do
  impact 1.0
  title 'The /etc/os-release file must have mode 0644 or less permissive'
  desc 'Check periodically the owner and permissions for /etc/os-release.'

  describe file('/etc/os-release') do
    it { should be_writable.by 'owner' }
    it { should be_readable.by 'owner' }
    it { should be_readable.by 'group' }
    it { should be_readable.by 'other' }
    it { should_not be_writable.by 'group' }
    it { should_not be_writable.by 'other' }
    it { should_not be_executable.by 'owner' }
    it { should_not be_executable.by 'group' }
    it { should_not be_executable.by 'other' }
    its('mode') { should cmp '0644' }
  end
end

control 'alpine-08' do
  impact 1.0
  title 'The /etc/os-release file must contain the correct release'
  desc 'Check for the correct version of Alpine Linux from /etc/os-release.'

  describe file('/etc/os-release') do
    its('content') { should match /^NAME="Alpine Linux"$/ }
    its('content') { should match /^ID=alpine$/ }
    its('content') { should match /^VERSION_ID=#{alpine_version_id}$/ }
    its('content') { should match /^PRETTY_NAME="Alpine Linux v#{alpine_version}"$/ }
  end
end

control 'alpine-09' do
  impact 1.0
  title 'The /etc/alpine-release file must exist'
  desc 'Ensure that the correct release of Alpine Linux is used.'

  describe file('/etc/alpine-release') do
    it { should exist }
  end
end

control 'alpine-10' do
  impact 1.0
  title 'The /etc/alpine-release file must be the correct type'
  desc 'Ensure that the correct release of Alpine Linux is used.'

  describe file('/etc/alpine-release') do
    it { should be_file }
  end

  describe file('/etc/alpine-release') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'alpine-11' do
  impact 1.0
  title 'The /etc/alpine-release file must be owned by root'
  desc 'Ensure the owner of /etc/alpine-release is correctly set to root.'

  describe file('/etc/alpine-release') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'alpine-12' do
  impact 1.0
  title 'The /etc/alpine-release file must be group-owned by root'
  desc 'Ensure the group of /etc/alpine-release is correctly set to root.'

  describe file('/etc/alpine-release') do
    its('group') { should eq 'root' }
  end
end

control 'alpine-13' do
  impact 1.0
  title 'The /etc/alpine-release file must have mode 0644 or less permissive'
  desc 'Check periodically the owner and permissions for /etc/alpine-release.'

  describe file('/etc/alpine-release') do
    it { should be_writable.by 'owner' }
    it { should be_readable.by 'owner' }
    it { should be_readable.by 'group' }
    it { should be_readable.by 'other' }
    it { should_not be_writable.by 'group' }
    it { should_not be_writable.by 'other' }
    it { should_not be_executable.by 'owner' }
    it { should_not be_executable.by 'group' }
    it { should_not be_executable.by 'other' }
    its('mode') { should cmp '0644' }
  end
end

control 'alpine-14' do
  impact 1.0
  title 'The /etc/alpine-release file must contain the correct release'
  desc 'Check for the correct version of Alpine Linux from /etc/alpine-release.'

  describe file('/etc/alpine-release') do
    its('content') { should match /^#{alpine_version_id}$/ }
  end
end

control 'alpine-15' do
  impact 1.0
  title 'The /etc/apk/repositories file must exist'
  desc 'Check periodically the owner and permissions for /etc/apk/repositories.'

  describe file('/etc/apk/repositories') do
    it { should exist }
  end
end

control 'alpine-16' do
  impact 1.0
  title 'The /etc/apk/repositories file must be the correct type'
  desc 'Check periodically the owner and permissions for /etc/apk/repositories.'

  describe file('/etc/apk/repositories') do
    it { should be_file }
  end

  describe file('/etc/apk/repositories') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'alpine-17' do
  impact 1.0
  title 'The /etc/apk/repositories file must be owned by root'
  desc 'Check periodically the owner and permissions for /etc/apk/repositories.'

  describe file('/etc/apk/repositories') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'alpine-18' do
  impact 1.0
  title 'The /etc/apk/repositories file must be group-owned by root'
  desc 'Check periodically the owner and permissions for /etc/apk/repositories.'

  describe file('/etc/apk/repositories') do
    its('group') { should eq 'root' }
  end
end

control 'alpine-19' do
  impact 1.0
  title 'The /etc/apk/repositories file must have mode 0644 or less permissive'
  desc 'Check periodically the owner and permissions for /etc/apk/repositories.'

  describe file('/etc/apk/repositories') do
    it { should be_writable.by 'owner' }
    it { should be_readable.by 'owner' }
    it { should be_readable.by 'group' }
    it { should be_readable.by 'other' }
    it { should_not be_writable.by 'group' }
    it { should_not be_writable.by 'other' }
    it { should_not be_executable.by 'owner' }
    it { should_not be_executable.by 'group' }
    it { should_not be_executable.by 'other' }
    its('mode') { should cmp '0644' }
  end
end

control 'alpine-20' do
  impact 1.0
  title 'Check for the correct Alpine Linux repositories'
  desc 'Check for the correct Alpine Linux repositories.'

  describe file('/etc/apk/repositories') do
    its('content') {
      should match /^https:\/\/dl-cdn.alpinelinux.org\/alpine\/v#{alpine_version}\/main$/
    }

    its('content') {
      should match /^https:\/\/dl-cdn.alpinelinux.org\/alpine\/v#{alpine_version}\/community$/
    }
  end
end
