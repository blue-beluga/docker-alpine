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

title 'Alpine Linux files and directories'

control 'os-01' do
  impact 0.5
  title 'Library files must have mode 0755 or less permissive'
  desc 'Restrictive permissions are to protect the integrity of the system.'

  %w(/lib /usr/lib).each do |lib|
    describe command("find -L #{lib} -perm /022 -type f") do
      its('exit_status') { should eq 0 }
      its('stdout') { should eq '' }
      its('stderr') { should eq '' }
    end
  end
end

control 'os-02' do
  impact 0.5
  title 'Library files must be owned by root'
  desc 'Restrictive permissions are to protect the integrity of the system.'

  %w(/lib /usr/lib).each do |lib|
    describe command("find -L #{lib} \! -user root") do
      its('exit_status') { should eq 0 }
      its('stdout') { should eq '' }
      its('stderr') { should eq '' }
    end
  end
end

control 'os-03' do
  impact 0.5
  title 'All system command files must have mode 755 or less permissive'
  desc 'Restrictive permissions are necessary to ensure safe execution.'

  %w(/bin /usr/bin /usr/local/bin /sbin /usr/sbin).each do |dir|
    describe command("find -L #{dir} -perm /022 -type f") do
      its('exit_status') { should eq 0 }
      its('stdout') { should eq '' }
      its('stderr') { should eq '' }
    end
  end
end

control 'os-04' do
  impact 0.5
  title 'All system command files must be owned by root'
  desc 'Restrictive permissions are necessary to ensure safe execution.'

  %w(/bin /usr/bin /usr/local/bin /sbin /usr/sbin).each do |dir|
    describe command("find -L #{dir} \! -user root") do
      its('exit_status') { should eq 0 }
      its('stdout') { should eq '' }
      its('stderr') { should eq '' }
    end
  end
end

control 'os-05' do
  impact 0.5
  title 'All rsyslog-generated log files must be owned by root'
  desc 'The log files generated contain valuable information.'

  %w(auth.log boot.log kern.log mail.log).each do |log|
    if file("/var/log/#{log}").exist?
      describe.one do
        describe file("/var/log/#{log}") do
          its('owner') { should eq 'root' }
        end

        describe file("/var/log/#{log}") do
          its('owner') { should eq 'syslog' }
        end
      end
    end
  end

  %w(cron maillog messages secure spooler syslog).each do |log|
    if file("/var/log/#{log}").exist?
      describe.one do
        describe file("/var/log/#{log}") do
          its('owner') { should eq 'root' }
        end

        describe file("/var/log/#{log}") do
          its('owner') { should eq 'syslog' }
        end
      end
    end
  end
end

control 'os-06' do
  impact 0.5
  title 'All rsyslog-generated log files must be group-owned by root'
  desc 'The log files generated contain valuable information.'

  %w(auth.log boot.log kern.log mail.log).each do |log|
    if file("/var/log/#{log}").exist?
      describe.one do
        describe file("/var/log/#{log}") do
          its('group') { should eq 'root' }
        end

        describe file("/var/log/#{log}") do
          its('group') { should eq 'adm' }
        end
      end
    end
  end

  %w(cron maillog messages secure spooler syslog).each do |log|
    if file("/var/log/#{log}").exist?
      describe.one do
        describe file("/var/log/#{log}") do
          its('group') { should eq 'root' }
        end

        describe file("/var/log/#{log}") do
          its('group') { should eq 'adm' }
        end
      end
    end
  end
end

control 'os-07' do
  impact 0.5
  title 'All rsyslog-generated log files must have mode 0600 or less permissive'
  desc 'The log files generated contain valuable information.'

  %w(auth.log boot.log kern.log mail.log).each do |log|
    if file("/var/log/#{log}").exist?
      describe file("/var/log/#{log}") do
        it { should be_writable.by 'owner' }
        it { should be_readable.by 'owner' }
        it { should_not be_readable.by 'group' }
        it { should_not be_readable.by 'other' }
        it { should_not be_writable.by 'group' }
        it { should_not be_writable.by 'other' }
        it { should_not be_executable.by 'owner' }
        it { should_not be_executable.by 'group' }
        it { should_not be_executable.by 'other' }
        its('mode') { should cmp '0600' }
      end
    end
  end

  %w(cron maillog messages secure spooler syslog).each do |log|
    if file("/var/log/#{log}").exist?
      describe file("/var/log/#{log}") do
        it { should be_writable.by 'owner' }
        it { should be_readable.by 'owner' }
        it { should_not be_readable.by 'group' }
        it { should_not be_readable.by 'other' }
        it { should_not be_writable.by 'group' }
        it { should_not be_writable.by 'other' }
        it { should_not be_executable.by 'owner' }
        it { should_not be_executable.by 'group' }
        it { should_not be_executable.by 'other' }
        its('mode') { should cmp '0600' }
      end
    end
  end
end

control 'os-08' do
  impact 0.1
  title 'All public directories must be owned by a system account'
  desc 'Allowing a user to own a world-writable directory is undesirable.'

  %w(/tmp /var /var/log usr usr/local / /home /root).each do |mnt|
    if mount(mnt).mounted?
      describe command("find #{mnt} -xdev -type d -perm -0002 -user root -print") do
        its('exit_status') { should eq 0 }
        its('stdout') { should eq "/var/tmp\n/tmp\n" }
        its('stderr') { should eq '' }
      end
    end
  end
end

control 'os-09' do
  impact 0.5
  title 'There must be no world-writable files on the system'
  desc 'Data in world-writable files can be modified by any user on the system.'

  %w(/tmp /var /var/log usr usr/local / /home /root).each do |mnt|
    if mount(mnt).mounted?
      describe command("find #{mnt} -xdev -type f -perm -002") do
        its('exit_status') { should eq 0 }
        its('stdout') { should eq '' }
        its('stderr') { should eq '' }
      end
    end
  end
end

control 'os-10' do
  impact 0.1
  title 'The sticky bit must be set on all public directories'
  desc 'Failing to set the sticky bit allows users to delete files.'

  %w(/tmp /var /var/log usr usr/local / /home /root).each do |mnt|
    if mount(mnt).mounted?
      describe command("find #{mnt} -xdev -type d -perm -002 \! -perm -1000") do
        its('exit_status') { should eq 0 }
        its('stdout') { should eq '' }
        its('stderr') { should eq '' }
      end
    end
  end
end

control 'os-11' do
  impact 0.5
  title 'There must be no .netrc files on the system'
  desc 'Policy requires passwords be encrypted in storage.'

  describe command('find /root /home -xdev -name .netrc') do
    its('exit_status') { should eq 0 }
    its('stdout') { should eq '' }
    its('stderr') { should eq '' }
  end
end

control 'os-12' do
  impact 1.0
  title 'Trusted hosts login'
  desc 'Do not use rhosts/hosts.equiv files for authentication.'

  describe command('find / -name .rhosts') do
    its('exit_status') { should eq 0 }
    its('stdout') { should be_empty }
    its('stderr') { should eq '' }
  end

  describe command('find / -name hosts.equiv') do
    its('exit_status') { should eq 0 }
    its('stdout') { should be_empty }
    its('stderr') { should eq '' }
  end
end

control 'os-13' do
  impact 1.0
  title 'Check network connectivity'
  desc 'Check network connectivity.'

  describe host('8.8.8.8', port: 53, protocol: 'udp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe host('8.8.4.4', port: 53, protocol: 'udp') do
    it { should be_reachable }
    it { should be_resolvable }
  end

  describe host('google.com', port: 80, protocol: 'tcp') do
    it { should be_reachable }
    it { should be_resolvable }
  end
end

control 'os-14' do
  impact 1.0
  title 'The /usr/bin/apk-install file must exist'
  desc 'Check periodically the owner and permissions for /usr/bin/apk-install.'

  describe file('/usr/bin/apk-install') do
    it { should exist }
  end
end

control 'os-15' do
  impact 1.0
  title 'The /usr/bin/apk-install file must be the correct type'
  desc 'Check periodically the owner and permissions for /usr/bin/apk-install.'

  describe file('/usr/bin/apk-install') do
    it { should be_file }
  end

  describe file('/usr/bin/apk-install') do
    it { should_not be_pipe }
    it { should_not be_socket }
    it { should_not be_symlink }
    it { should_not be_mounted }
    it { should_not be_directory }
    it { should_not be_block_device }
    it { should_not be_character_device }
  end
end

control 'os-16' do
  impact 1.0
  title 'The /usr/bin/apk-install file must be owned by root'
  desc 'Check periodically the owner of /usr/bin/apk-install.'

  describe file('/usr/bin/apk-install') do
    it { should be_owned_by 'root' }
    its('owner') { should eq 'root' }
  end
end

control 'os-17' do
  impact 1.0
  title 'The /usr/bin/apk-install file must be group-owned by root'
  desc 'Check periodically the group-ownership for /usr/bin/apk-install.'

  describe file('/usr/bin/apk-install') do
    its('group') { should eq 'root' }
  end
end

control 'os-18' do
  impact 1.0
  title 'The /usr/bin/apk-install file must have mode 0755 or less permissive'
  desc 'Check periodically permissions for /usr/bin/apk-install.'

  describe file('/usr/bin/apk-install') do
    it { should be_writable.by 'owner' }
    it { should be_readable.by 'owner' }
    it { should be_readable.by 'group' }
    it { should be_readable.by 'other' }
    it { should be_executable.by 'owner' }
    it { should be_executable.by 'group' }
    it { should be_executable.by 'other' }
    it { should_not be_writable.by 'group' }
    it { should_not be_writable.by 'other' }
    its('mode') { should cmp '0755' }
  end
end

control 'os-19' do
  impact 0.5
  title 'The /usr/bin/apk-install script must be installed'
  desc 'Check for the /usr/bin/apk-install script.'

  describe command('which apk-install') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^\/usr\/bin\/apk-install$/ }
    its('stderr') { should eq '' }
  end
end

control 'os-20' do
  impact 1.0
  title 'The system installs packages correctly'
  desc 'Check the system to ensure packages install correctly.'

  describe command('apk-install git') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^OK:/ }
    its('stderr') { should eq '' }
  end
end

control 'os-21' do
  impact 1.0
  title 'Installed packages execute correctly'
  desc 'Check the system to ensure packages install correctly.'

  describe command('git --version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^git version 2.32.0$/ }
    its('stderr') { should eq '' }
  end
end

control 'os-22' do
  impact 1.0
  title 'The package cache is empty'
  desc 'Check the cache in /var/cache/apk to ensure it is empty.'

  describe command('ls -1 /var/cache/apk | wc -l') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^0$/ }
    its('stderr') { should eq '' }
  end
end

control 'os-23' do
  impact 1.0
  title 'Dot in PATH variable'
  desc 'Do not include the current working directory in PATH variable.'

  describe os_env('PATH') do
    its('split') { should_not include '' }
    its('split') { should_not include '.' }
  end
end

control 'os-24' do
  impact 1.0
  title 'Check for SUID/SGID blacklist'
  desc 'Find blacklisted SUID/SGID files to ensure they are removed.'

  blacklist = [
    '/usr/bin/rcp',
    '/usr/bin/rlogin',
    '/usr/bin/rsh',
    '/usr/libexec/openssh/ssh-keysign',
    '/usr/lib/openssh/ssh-keysign',
    '/sbin/netreport',
    '/usr/sbin/usernetctl',
    '/usr/sbin/userisdnctl',
    '/usr/sbin/pppd',
    '/usr/bin/lockfile',
    '/usr/bin/mail-lock',
    '/usr/bin/mail-unlock',
    '/usr/bin/mail-touchlock',
    '/usr/bin/dotlockfile',
    '/usr/bin/arping',
    '/usr/sbin/arping',
    '/usr/sbin/uuidd',
    '/usr/bin/mtr',
    '/usr/lib/evolution/camel-lock-helper-1.2',
    '/usr/lib/pt_chown',
    '/usr/lib/eject/dmcrypt-get-device',
    '/usr/lib/mc/cons.saver'
  ]

  output = command <<-EOF
  find / -perm -4000 -o -perm -2000 -type f ! -path '/proc/*' \
         -print 2>/dev/null | grep -v '^find:'
  EOF
  diff = output.stdout.split(/\r?\n/) & blacklist

  describe diff do
    it { should be_empty }
  end
end

control 'os-25' do
  impact 0.5
  title 'OpenSSH must not be running'
  desc 'OpenSSH must not be running.'

  describe processes('ssh') do
    its('entries.length') { should eq 0 }
  end

  describe processes('sshd') do
    its('entries.length') { should eq 0 }
  end

  describe port(22) do
    it { should_not be_listening }
  end
end
