Puppet::Type.newtype(:vgs) do
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Manage VGs'
  end

  newparam(:vg_name) do
    defaultto { @resource[:name] }
     munge do |value|
      String(value)
    end
  end

  newparam(:vg_disks) do
    desc 'Which partitions to be in the volume group'
    validate do |value|
      if value == nil
        raise Puppet::Error, "you must set vg_disks"
      end
      value.each do |item|
        if item == ''
          raise Puppet::Error, "you can not set " " as a disk"
        end
      end
    end
    munge do |value|
      Array(value)
    end
  end

end