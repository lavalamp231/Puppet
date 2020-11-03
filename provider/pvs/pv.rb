
Puppet::Type.type(:pvs).provide(:pv) do
  desc 'Handles lvm  for physical volumes'
 commands :pvcreate => '/sbin/pvcreate', :pvremove => '/sbin/pvremove', :pvdisplay => 'pvdisplay'

  defaultfor kernel: 'Linux'


  def exists?
    pvs = Puppet::Util::Execution.execute("/sbin/pvdisplay " + @resource[:pv_name], {failonfail: false}).split("\n")
    return pvs.length > 5
  end

  def create
     pvcreate(@resource[:pv_name])
  end

  def destroy
     pvremove(@resource[:pv_name])
  end

end
