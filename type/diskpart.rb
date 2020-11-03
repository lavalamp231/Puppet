Puppet::Type.newtype(:diskpart) do
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Handles disk partitions'
  end

  newparam(:disk_path) do
    defaultto {
    if value == nil || value == ''
      name = @resource[:name]
      if String(name).include?(":")
        String(String(name).split(":")[0])
      else
         String(value)
      end
    end
  }
  end

  newparam(:partition_number) do
    defaultto {
    if value == nil || value == ''
      name = @resource[:name]
      if String(name).include?(":")
         String(String(name).split(":")[1])
      else
         '1'
      end
    end
    }
  end

  newparam(:partition_type) do
    defaultto :'8e'
    munge do |value|
      String(value)
    end
  end

  newparam(:size) do
    defaultto :''
    munge do |value|
      String(value)
    end
  end

  newparam(:start_sector) do
    defaultto :''
    munge do |value|
      String(value)
    end
  end

  newparam(:end_sector) do
    defaultto :''
    munge do |value|
      String(value)
    end
  end

  newparam(:force) do
    defaultto :false
  end

end