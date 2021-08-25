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

title 'Root user'

control 'root-01' do
  impact 1.0
  title 'The root user must exist'
  desc 'Check for the root user.'

  describe user('root') do
    it { should exist }
  end
end

control 'root-02' do
  impact 1.0
  title 'The root user UID/GID is correct'
  desc 'Check the UID/GID of the root user.'

  describe user('root') do
    its('uid') { should eq 0 }
    its('gid') { should eq 0 }
  end

  describe passwd do
    its('users') { should include 'root' }
  end

  describe passwd.uids(0) do
    its('users') { should cmp 'root' }
  end

  describe passwd.users('root') do
    its('uids') { should cmp 0 }
  end
end

control 'root-03' do
  impact 1.0
  title 'The root user group is correct'
  desc 'Check the group of the root user.'

  describe user('root') do
    its('group') { should eq 'root' }
    its('groups') {
      should eq %w(root bin daemon sys adm disk wheel floppy dialout tape video)
    }
  end

  describe group('root') do
    it { should exist }
    its('gid') { should eq 0 }
  end

  describe etc_group do
    its('users') { should include 'root' }
    its('groups') { should include 'root' }
  end

  describe etc_group.where(name: 'root') do
    its('gids') { should eq [0] }
    its('users') { should include 'root' }
  end
end

control 'root-04' do
  impact 1.0
  title 'The root user home is correct'
  desc 'Check the home of the root user.'

  describe user('root') do
    its('home') { should eq '/root' }
  end
end

control 'root-05' do
  impact 1.0
  title 'The root user shell is correct'
  desc 'Check the shell of the root user.'

  describe user('root') do
    its('shell') { should eq '/bin/ash' }
  end
end

control 'root-06' do
  impact 1.0
  title 'The root user password is disabled'
  desc 'Check that the current user is the root user.'

  describe shadow.users('root') do
     its('passwords') { should cmp "!" }
  end
end

control 'root-07' do
  impact 1.0
  title 'The current user is root'
  desc 'Check that the current user is the root user.'

  describe command('whoami') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^root$/ }
    its('stderr') { should eq '' }
  end
end

control 'root-08' do
  impact 1.0
  title 'The root user UID/GID is unique'
  desc 'Check for unique uids gids'

  describe passwd do
    its('uids') { should_not contain_duplicates }
    its('users') { should_not contain_duplicates }
  end

  describe etc_group do
    its('gids') { should_not contain_duplicates }
    its('groups') { should_not contain_duplicates }
  end

  describe shadow do
    its('users') { should_not contain_duplicates }
  end
end
