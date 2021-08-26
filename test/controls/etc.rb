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

title 'Alpine Linux settings'

control 'etc-01' do
  impact 1.0
  title 'The /etc/shadow file must exist'
  desc 'Check periodically the owner and permissions for /etc/shadow.'

  describe file('/etc/shadow') do
    it { should exist }
  end
end

control 'etc-02' do
  impact 1.0
  title 'The /etc/shadow file must be the correct type'
  desc 'Check periodically the owner and permissions for /etc/shadow.'

  describe file('/etc/shadow') do
    it { should be_file }
  end

  describe file('/etc/shadow') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'etc-03' do
  impact 1.0
  title 'The /etc/shadow file must be owned by root'
  desc 'Check periodically the owner and permissions for /etc/shadow.'

  describe file('/etc/shadow') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'etc-04' do
  impact 1.0
  title 'The /etc/shadow file must be group-owned by root'
  desc 'Check periodically the owner and permissions for /etc/shadow.'

  describe file('/etc/shadow') do
    its('group') { should eq 'shadow' }
  end
end

control 'etc-05' do
  impact 1.0
  title 'The /etc/shadow file must have mode 0640 or less permissive'
  desc 'Check periodically the owner and permissions for /etc/shadow.'

  describe file('/etc/shadow') do
    it { should be_writable.by 'owner' }
    it { should be_readable.by 'owner' }
    it { should be_readable.by 'group' }
    it { should_not be_writable.by 'group' }
    it { should_not be_writable.by 'other' }
    it { should_not be_readable.by 'other' }
    it { should_not be_executable.by 'owner' }
    it { should_not be_executable.by 'group' }
    it { should_not be_executable.by 'other' }
    its('mode') { should cmp '0640' }
  end
end

control 'etc-06' do
  impact 1.0
  title 'Check for the /etc/passwd file'
  desc 'Check periodically the owner and permissions for /etc/passwd.'

  describe file('/etc/passwd') do
    it { should exist }
  end
end

control 'etc-07' do
  impact 1.0
  title 'The /etc/passwd file must be the correct type'
  desc 'Check periodically the owner and permissions for /etc/passwd.'

  describe file('/etc/passwd') do
    it { should be_file }
  end

  describe file('/etc/passwd') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'etc-08' do
  impact 1.0
  title 'The /etc/passwd file must be owned by root'
  desc 'Check periodically the owner and permissions for /etc/passwd.'

  describe file('/etc/passwd') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'etc-09' do
  impact 1.0
  title 'The /etc/passwd file must be group-owned by root'
  desc 'Check periodically the owner and permissions for /etc/passwd.'

  describe file('/etc/passwd') do
    its('group') { should eq 'root' }
  end
end

control 'etc-10' do
  impact 1.0
  title 'The /etc/passwd file must have mode 0644 or less permissive'
  desc 'Check periodically the owner and permissions for /etc/passwd.'

  describe file('/etc/passwd') do
    it { should be_readable.by 'owner' }
    it { should be_writable.by 'owner' }
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

control 'etc-11' do
  impact 0.5
  title 'The /etc/passwd file must not contain password hashes'
  desc 'Passwords should never be stored in /etc/passwd file.'

  describe command("awk -F: '($2 != \"x\") {print}' /etc/passwd") do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq '' }
    its('stderr') { should eq '' }
  end
end

control 'etc-12' do
  impact 1.0
  title 'Check for the /etc/group file'
  desc 'Check periodically the owner and permissions for /etc/group.'

  describe file('/etc/group') do
    it { should exist }
  end
end

control 'etc-13' do
  impact 1.0
  title 'The /etc/group file must be the correct type'
  desc 'Check periodically the owner and permissions for /etc/group.'

  describe file('/etc/group') do
    it { should be_file }
  end

  describe file('/etc/group') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'etc-14' do
  impact 1.0
  title 'The /etc/group file must be owned by root'
  desc 'Check periodically the owner and permissions for /etc/group.'

  describe file('/etc/group') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'etc-15' do
  impact 1.0
  title 'The /etc/group file must be group-owned by root'
  desc 'Check periodically the owner and permissions for /etc/group.'

  describe file('/etc/group') do
    its('group') { should eq 'root' }
  end
end

control 'etc-16' do
  impact 1.0
  title 'The /etc/group file must have mode 0644 or less permissive'
  desc 'Check periodically the owner and permissions for /etc/group.'

  describe file('/etc/group') do
    it { should be_readable.by 'owner' }
    it { should be_writable.by 'owner' }
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

# control 'etc-17' do
#   impact 1.0
#   title 'The /etc/TZ file must exist'
#   desc 'Check periodically the owner and permissions for /etc/TZ.'
#
#   describe file('/etc/TZ') do
#     it { should exist }
#   end
# end
#
# control 'etc-18' do
#   impact 1.0
#   title 'The /etc/TZ file must be the correct type'
#   desc 'Check periodically the owner and permissions for /etc/TZ.'
#
#   describe file('/etc/TZ') do
#     it { should be_file }
#   end
#
#   describe file('/etc/TZ') do
#     it { should_not be_pipe }
#     it { should_not be_socket }
#     it { should_not be_symlink }
#     it { should_not be_mounted }
#     it { should_not be_directory }
#     it { should_not be_block_device }
#     it { should_not be_character_device }
#   end
# end
#
# control 'etc-19' do
#   impact 1.0
#   title 'The /etc/TZ file must be owned by root'
#   desc 'Check periodically the owner and permissions for /etc/TZ.'
#
#   describe file('/etc/TZ') do
#     it { should be_owned_by 'root' }
#     its('owner') { should eq 'root' }
#   end
# end
#
# control 'etc-20' do
#   impact 1.0
#   title 'The /etc/TZ file must be group-owned by root'
#   desc 'Check periodically the owner and permissions for /etc/TZ.'
#
#   describe file('/etc/TZ') do
#     its('group') { should eq 'root' }
#   end
# end
#
# control 'etc-21' do
#   impact 1.0
#   title 'The /etc/TZ file must have mode 0644 or less permissive'
#   desc 'Check periodically the owner and permissions for /etc/TZ.'
#
#   describe file('/etc/TZ') do
#     it { should be_writable.by 'owner' }
#     it { should be_readable.by 'owner' }
#     it { should be_readable.by 'group' }
#     it { should be_readable.by 'other' }
#     it { should_not be_writable.by 'group' }
#     it { should_not be_writable.by 'other' }
#     it { should_not be_executable.by 'owner' }
#     it { should_not be_executable.by 'group' }
#     it { should_not be_executable.by 'other' }
#     its('mode') { should cmp '0644' }
#   end
# end
#
# control 'etc-22' do
#   impact 1.0
#   title 'The timezone is set to UTC'
#   desc 'Check that the timezone is set correctly.'
#
#   describe file('/etc/TZ') do
#     its('content') { should match /^UTC$/ }
#   end
#
#   describe command('date +%Z') do
#     its('exit_status') { should eq 0 }
#     its('stdout') { should match /^UTC$/ }
#     its('stderr') { should eq '' }
#   end
# end

control 'etc-23' do
  impact 1.0
  title 'Check for duplicates in the /etc/passwd file'
  desc 'Check for unique uids gids'

  describe passwd do
    its('uids') { should_not be_empty }
    its('uids') { should_not contain_duplicates }
  end
end

control 'etc-24' do
  impact 1.0
  title 'Check for duplicates in the /etc/group file'
  desc 'Check for unique uids gids'

  describe etc_group do
    its('gids') { should_not be_empty }
    its('gids') { should_not contain_duplicates }
  end
end

control 'etc-25' do
  impact 1.0
  title 'Check for duplicates in the /etc/shadow file'
  desc 'Check for unique uids gids'

  describe shadow do
    its('users') { should_not be_empty }
    its('users') { should_not contain_duplicates }
  end
end
