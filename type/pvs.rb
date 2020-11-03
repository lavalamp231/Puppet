Puppet::Type.newtype(:pvs) do
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Title of the resource'
  end

  newparam(:pv_name) do
    defaultto { @resource[:name] }
    desc 'Manage physical volume creation'
  end
  
end