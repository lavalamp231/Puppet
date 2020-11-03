Puppet::Type.type(:fs).provide(:xfs) do

  desc 'Handles the filesystem creation of xfs and ext3'
  commands :mkfs_xfs => 'mkfs.xfs', :xfs_growfs => 'xfs_growfs', :mount => 'mount', :umount => 'umount'

  defaultfor kernel: 'Linux'


  ###################### EXISTS ############################

   def exists?
      case
      #  when partition_exists == false
      #    p "#{@resource[:fs_path]} does not exist"
      #    return false
      when checkfs == false
        p "filesystem doesn't exist"
        return false
      when @resource[:grow_fs] == :true && isgrown == false
          p "isgrown case statement"
          return false
      when ismounted == false
          p "failing the mount"
          return false
      when infstab == false
        p "fstab case"
        return false
      else
        return true
      end
  end
  ################## END OF EXISTS ########################


  ################# CREATE ###############################

  def create
    if @resource[:grow_fs] == :true
      fstabentry
      growfs
      mountfs
    else
      createfs()
      fstabentry
      mountfs
    end
  end


################## END OF CREATE #########################


################## DESTROY ##########################

  def destroy
    # no op
  end

################ END OF DESTORY ####################


######################## My Methods ############################


  def growfs
    case
    when checkfs == false && ismounted == false
      createfs
    when ismounted
      xfs_growfs(@resource[:fs_path])
      info("#{@resource[:fs_path]} has been grown")
    end
  end

  def createfs
     if checkfs == false
       info("Filesystem #{@resource[:fs_type]} is being written to #{@resource[:fs_path]}")
       mkfs_xfs(@resource[:fs_path], @resource[:option])
     end
  end

  def fstabentry
   # if @resource[:grow_fs] == :false
      mount_entry = "#{@resource[:fs_path]} #{@resource[:mount_path]} xfs defaults 1 2\n"
      check_entry = "#{@resource[:fs_path]} #{@resource[:mount_path]} xfs defaults 1 2"

      if !File.open('/etc/fstab').each_line.any?{|line| line.include?(check_entry) }
        File.open("/etc/fstab", 'a') { |file| file.write(mount_entry) }
        info("Adding fstab entry for #{@resource[:fs_path]}, which is mounting on #{@resource[:mount_path]}")
      end
   # end
  end

  def mountfs
 #   if ismounted == false
    if ismounted == false
      info("#{@resource[:mount_path]} is being mounted")
      mount(@resource[:fs_path])
  #  end
    end
  end

  def convert_to_mb(size)
    case
    when size.include?(" GiB")
      size = size.gsub(" GiB","").to_f
      size = size * 1000
    when size.include?("G")
      size = size.gsub("G","").to_f
      size = size * 1000
     when size.include?("g")
      size = size.gsub("g","").to_f
      size = size * 1000
    when size.include?(" MiB")
      size = size.gsub("MiB", "").to_i
    when size.include?("M")
      size = size.gsub("M", "").to_i
    when size.include?("m")
      size = size.gsub("m", "").to_i
    else
      size.to_i
    end
  end


#### Checks ####

  def checkfs
      if !Facter.value('partitions').key?(@resource[:fs_path])
        return false
      else
      fs = Facter.value('partitions')[@resource[:fs_path]]
      fs.include?('filesystem')
      end
  end

  def partition_exists
    Facter.value('partitions').key?(@resource[:fs_path])
  end


  def ismounted()
    ismount = Facter.value('partitions')[@resource[:fs_path]]
   # if @resource[:grow_fs] == :false
     case
     when partition_exists == false
      return false
     when ismount.include?('mount') == false
      return false
     end
   # end
  end


  def isgrown()
    if ismounted == true
      partition_size = Facter.value('partitions')[@resource[:fs_path]]['size']
      mount_point = Facter.value('partitions')[@resource[:fs_path]]['mount']
      mount_size = Facter.value('mountpoints')[mount_point]['size']
      partition_size = convert_to_mb(partition_size) 
      mount_size = convert_to_mb(mount_size) + 10
      p partition_size
      p mount_size
      partition_size == mount_size ? true : false
    end
  end

  def infstab
    check_entry = "#{@resource[:fs_path]} #{@resource[:mount_path]} xfs defaults 1 2"
    tmp_entry = "/dev/mapper/osvg-tmp.fs /tmp    xfs     defaults,nodev,nosuid   0       0"

    if @resource[:fs_path].include?("tmp")
      unless File.open('/etc/fstab').each_line.any?{|line| line.include?("tmp.fs") }
        p "tmp"
        return false
      end
    else
      if !File.open('/etc/fstab').each_line.any?{|line| line.include?(check_entry) }
        p "check_entry"
        return false
      end
    end
  end


end