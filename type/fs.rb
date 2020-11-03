require 'pathname'

Puppet::Type.newtype(:fs) do

  desc 'Will manage the filesystem of LVMs'

  ensurable


   newparam(:name, :namevar => true) do
     desc 'Title of resource'
   end

  newparam(:fs_path) do
    desc 'The full path to the filesytem name'
    defaultto { @resource[:name] }
    munge { |v| String(v) }
    # validate do |value|
    #   unless Puppet::FileSystem.symlink?(value)
    #     raise Puppet::Error, "Path is not a symlink - All LVMs are symlinks"
    #   end
    # end
  end

  newparam(:fs_type) do
    desc 'What type of file system you need'
    munge do |value|
      String(value)
    end
    defaultto :'xfs'
  end

  newparam(:option) do
    desc 'What options to add to mkfs'
    defaultto :'-q'
  end

  newparam(:grow_fs) do
    desc 'To grow the filesystem'
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:mount_path) do
    desc 'The mount path of the LVM'
    defaultto :''
    munge do |turn_to_string|
      String(turn_to_string)
    end
    # validate do |value|
    #   unless Puppet::FileSystem.dir_exist?(value)
    #     raise Puppet::Error, "Path is not directory"
    #   end
    # end
  end


end