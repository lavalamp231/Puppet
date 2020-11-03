Puppet::Type.newtype(:lvm) do
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Title of lvm name'
  end

  newparam(:lvm) do
    desc 'Creating the LVM'
    defaultto { @resource[:name]}
  end

  newparam(:vg) do
    desc 'What volume group is the LVM part of'
    # validate do |volume_group|
    #   unless Facter.value('vgdisplay').key?(volume_group)
    #     raise Puppet::Error, "Volume group does not exist"
    #   end
    # end
  end

  # Sizes
  # need to only allow <integer> + g/b
  newparam(:size) do
    desc 'Set size of the logical volume'
    defaultto :''
    #newvalues(/\A\d{1,10}[bBmMgG]{0,1}\z/)
    munge do |size|
      size.to_s
    end
  end

  newparam(:extents) do
    desc 'Use extents instead of size'
    defaultto :''
    munge do |d|
      String(d)
    end
  end

  newparam(:lv_extend) do
    desc 'Extend the LVM size'
    defaultto :false
    newvalues(:true, :false)
    #munge { |sizes| sizes.to_i }
  end

end