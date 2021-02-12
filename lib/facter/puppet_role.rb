Facter.add(:puppet_role) do
  setcode do
    Facter::Core::Execution.execute("/usr/bin/grep Puppet_Role= /etc/puppet_role.txt | /usr/bin/sed 's/Puppet_Role=//'")
  end
end
