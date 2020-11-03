
Puppet::Type.type(:diskpart).provide(:fdisk) do
  desc 'Handles fdisk for partition manipulation'
  commands :part => '/sbin/partprobe'


  defaultfor kernel: 'Linux'

  def exists?
    #If we are forcing any changes, we can not let puppet know what the real state of the resource is on the server,
    #We need to invert the truth table. If puppet finds the resource on the server, even if it is not updated, it will ignore it completely
    #By lying to it, it won't ignore and it will treat as non existant
    if @resource[:force] == true
      info("We are forcing disk changes, force is set to true")
      correct = @resource[:ensure] == :absent
      if !shouldForce()
        correct = !correct
      end
      return correct
    end
    #Is the disk path really a disk? we can't partition folders
    if !FileTest.blockdev?(@resource[:disk_path])
      raise Puppet::Error, "Invalid Disk " + @resource[:disk_path]
    end
    return FileTest.blockdev?(getFullPath())
  end

  def create
    #Checks for any basic sintax errors
    info("Checking for disk errors")
    checkError()

    #Check if we have enough space to do what we want, to avoid a broken disk later
    if testGetDiskSizeOnSize()
      raise Puppet::Error, "Insufficient Space"
    end

    #If we are forcing an update, we need to first delete the partition already in place
    if @resource[:force] == true
      if FileTest.blockdev?(getFullPath())
        info("Force is set to true,destroying current disk to change its parameters")
        destroy()
      end
    end
    #Fdisk has issues with piping and stdin when used by puppet, as such we need to construct our own stdin
    createDisk(false)
  end

  def destroy
    if !FileTest.blockdev?(getFullPath())
      return true
    end
    command = "("
    command += addParam("d")
    if partitionQuantities(@resource[:disk_path], true) == true
        command += addParam(@resource[:partition_number])
    end
    command += addParam("w")
    command += "echo q) | /sbin/fdisk "
    command += @resource[:disk_path]
    info("Deleting disk " + getFullPath())
    Puppet::Util::Execution.execute(command)
  end
  #Check the amount of partitions we have created
  def partitionQuantities(disk, destroy)
      output = Puppet::Util::Execution.execute("/sbin/fdisk -l "+disk,{ failonfail: false })
      partitions = output.split("\n")
      i = destroy ? 8 : 9
      return partitions.length - i >= 1
  end

  def testGetDiskSize(disk)
      output = Puppet::Util::Execution.execute("/sbin/fdisk -l "+disk, {failonfail: false})
      fullsize = output.split("\n")
      sectors_sectors = fullsize[1].split(",")[2]
      sectors = sectors_sectors.split(" ")[0]
      sectors = Integer(sectors)
      if  Integer(@resource[:end_sector]) > sectors
        raise Puppet::Error, "End Sector out of range"
      end
      minn = 0
      sizes = []
      for i in 9..fullsize.length-1
        if @resource[:disk_path] == "/dev/sda"
          sizes.push((Integer(fullsize[i].split[2])..Integer(fullsize[i].split[3])))
        else
          sizes.push((Integer(fullsize[i].split[1])..Integer(fullsize[i].split[2])))
        end
      end
      sizes.each do |ranges|
        ps = ranges.min
        if ps < minn
          minn = ps
        end
        if ranges.include?(Integer(@resource[:start_sector])) || ranges.include?(Integer(@resource[:end_sector]))
          raise Puppet::Error, "Invalid sector selected"
        end
      end
      if minn != 0 &&  minn != 2048 && Integer(@resource[:start_sector])
        raise Puppet::Error, "Invalid start sector, you can not create a partition with a blank space before it, blank space detected between 2048-"+String(minn)
      end
  end

   def testGetDiskSizeOnSize()
    size = nil
    if @resource[:size] == ''
      return false
    end
    if @resource[:force] == false
      begin
        hash_size = Facter.value('partitions')[getFullPath()]['size']
        size = String(hash_size)
      rescue
        size = nil
      end
    end

    if size == nil || size == ''
      partition = ''
      partition << String(@resource[:disk_path])
      partition_f = partition.sub!('/dev/','')
      begin
        size = String(Facter.value('disks')[partition_f]['size'])
      rescue
        size = nil
      end
    end

    if size == nil || size == ''
      return false
    end
      size = removeString(size,['.00 GiB','.00 MiB','.00 KiB'])
      isize = Integer(size)
      dsize = Integer(@resource[:size])

      if dsize > isize
        raise Puppet::Error, "Invalid Partition Size"
      end
      if size == @resource[:size]
        return false
      end

      if @resource[:start_sector] == '' || @resource[:end_sector] == ''
        return false
      end

      sectors = Integer(@resource[:end_sector]) - Integer(@resource[:start_sector])
      sectors = sectors / 1024 / 1024

      if String(sectors)+"G" == @resource[:size]
        return false
      end
      return true

   end

  def shouldForce
    if !FileTest.blockdev?(getFullPath())
      return @resource[:ensure] == :present
    end

    begin
      hash_size = Facter.value('partitions')[@resource[:disk_path]+@resource[:partition_number]]['size']
      size = String(hash_size)
    rescue
      size = nil
    end
    if size == nil || size == ''
      return false
    end

    size = removeString(size,['.00 GiB','.00 MiB','.00 KiB'])

    if size != @resource[:size]
      return true
    end
    return false

  end

  def checkError()
     if @resource[:size] != '' && (@resource[:start_sector] != '' || @resource[:end_sector] != '')
      raise Puppet::Error, "You can not have set Partition Size and Start-End sectors at the same time, either use only Size or Start-End sectors"
     end

    if (@resource[:start_sector] != '' && @resource[:end_sector] == '')
      raise Puppet::Error, "You must have end sector populated"
    end

    if  (@resource[:start_sector] == '' && @resource[:end_sector] != '')
      raise Puppet::Error, "You must have start sector populated"
    end
  end

  #removes replace from input
  def removeString(input,replace)
    replace.each do |str|
      if input.include?(str)
         return input.sub!(str,'')
      end
    end
    return input
  end

  #Returns the full qualified path of the partition
  def getFullPath()
    fullpath = ""
    fullpath += @resource[:disk_path]
    fullpath += @resource[:partition_number]
    return fullpath
  end

  #Adds echo x ; to x
  def addParam(param)
    return "echo " + param + "; "
  end
  def createDisk(disk_error)
    command = "("
    command += addParam("n")
    command += addParam("p")
    command += addParam(@resource[:partition_number])

    if @resource[:start_sector] != '' && @resource[:end_sector] != ''
      if Integer(@resource[:start_sector]) < 2048 #The first 2048 blocks of the disk is where the MBR is stored, we need to update this for GPT in the future
       raise Puppet::Error, "Invalid start sector, start sector should be atleast 2048"
      end
      testGetDiskSize(@resource[:disk_path])
      command += addParam(@resource[:start_sector])
      command += addParam(@resource[:end_sector])
    else
      command += addParam("\"\"")
      if disk_error != true
        command += addParam("+"+(@resource[:size] + "G"))
      else
        info("Detected Ghost sector, creating the disk with Size-1 sectors")
        command += addParam("\"\"")
      end
    end
    command += addParam("t")
    if partitionQuantities(@resource[:disk_path], false) == true
        command += addParam(@resource[:partition_number])
    end
    command += addParam(@resource[:partition_type])
    command += addParam("w")
    command += "echo q) | /sbin/fdisk "
    command += @resource[:disk_path] + ' >> /dev/null'
    info(command)
    begin
      Puppet::Util::Execution.execute(command, { failonfail: true, combine: true}) #execute fdisk with our own stdin, failonfail ensures it throws an exception if exit code isn't 0, and combine combines sterr+stdout
    rescue
       part()#partprobe
      if !FileTest.blockdev?(getFullPath())
        if disk_error == false
          createDisk(true)
        else
          raise Puppet::Error, "Insufficient Space on Disk"
        end
      end
    end
  end
end
