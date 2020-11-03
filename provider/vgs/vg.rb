
Puppet::Type.type(:vgs).provide(:vg) do
  desc 'Handles lvm  for volume groups'
 commands :vgcreate => 'vgcreate', :vgremove => 'vgremove', :vgreduce => 'vgreduce', :vgextend => 'vgextend', :vgs => 'vgs', :pvdisplay => 'pvdisplay', :lvs => 'lvs'

  defaultfor kernel: 'Linux'


  def exists?
    if @resource[:vg_disks] == nil && @resource[:ensure] == :present
      raise Puppet::Error, "VG_Disks cannot be empty when creating or updating a VG."
    end
    begin
      vgs(@resource[:vg_name])
    rescue
      return false
    end
    if @resource[:ensure] == :present && !isAllPVsAssociatedToVG()
        return false
    end
    return true
  end

  def create
    begin
      vgs(@resource[:vg_name])
    rescue
      begin
        vgcreate(@resource[:vg_name], *@resource[:vg_disks])
      rescue Puppet::ExecutionFailure => erro
        raise Puppet::Error, erro.message
      end
      return true
    end
    vgextend(@resource[:vg_name], *getUnassociatedPVs())
  end

  def destroy
    if @resource[:vg_disks] == nil
      ldisks = String(lvs())
      if !ldisks.include?(@resource[:vg_name])
        vgremove(@resource[:vg_name])
        return true
      else
        raise Puppet::Error, "This VG Contains a LV assigned to it, you cannot delete a VG with LVs assigned to it"
      end
    else
        vgreduce(@resource[:vg_name], *@resource[:vg_disks])
    end
  end

  def isAllPVsAssociatedToVG
    @resource[:vg_disks].each do |disk|
      if !pvdisplay(disk)
        return false
      end
      pv = pvdisplay(disk)
      if !pv.include?(@resource[:vg_name])
        return false
      end
    end
    return true
  end

  def getUnassociatedPVs
    disks = []
    @resource[:vg_disks].each do |disk|
      if !pvdisplay(disk)
        raise Puppet::Error, "Invalid Disk "+disk
      end
      pv = pvdisplay(disk)
      if !pv.include?(@resource[:vg_name])
         disks.push(disk)
      end
    end
    return disks
  end

end
