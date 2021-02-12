Facter.add(:environment) do
  setcode do
    Facter::Core::Execution.execute("/usr/bin/grep environment= /etc/puppet_role.txt | /usr/bin/sed 's/environment=//'")
  end
end
