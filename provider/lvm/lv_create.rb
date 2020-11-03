# need to ensure it does not exist - DONE
# need to ensure that it has enough space - WIP
# extents - DONE
# Create multiple at the same time - DONE


Puppet::Type.type(:lvm).provide(:lv_create) do

  desc 'This will handle the creation of the LVMs'
  commands :lv_create => 'lvcreate', :lv_remove => 'lvremove', :lv_extend => 'lvextend', :xfs_growfs => 'xfs_growfs'

  defaultfor kernel: 'Linux'

############### EXISTS ##########################

  def exists?
    dm = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
    unless Facter.value('partitions').key?(dm)
      return false
      puts "key is missing"
    end

    if @resource[:lv_extend] == :true && islvmextended == false
        return false
    end

    return FileTest.symlink?(dm)

  end

############### END OF EXISTS ####################


############### CREATE ############################


  def create

    if @resource[:lv_extend] == :true
      lv_extended()
     else
       lv_creates()
    end

  end
############### END OF CREATE  ############################



############### DESTROY ############################

  def destroy
    lvm_path = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
    args_destroy = []
    args_destroy << "-f"
    args_destroy << lvm_path
    info("#{lvm_path} is being removed.")
    lv_remove(*args_destroy)
  end

############## DESTORY END #########################





############### MY METHODS ########################

# This will check to see if GiB and MiB are in the string
# if so then it will remove the GiB and MiB and covert
# into an integer

  def convert_to_bytes(size)
    case
    when size.include?(" GiB")
      size = size.gsub(" GiB","").to_i
      size = size * 1073741824
    when size.include?("G")
      size = size.gsub("G","").to_i
      size = size * 1073741824
     when size.include?("g")
      size = size.gsub("g","").to_i
      size = size * 1073741824
    when size.include?(" MiB")
      size = size.gsub("MiB", "").to_i
      size = size * 1000000
    when size.include?("M")
      size = size.gsub("M", "").to_i
      size = size * 1000000
    when size.include?("m")
      size = size.gsub("m", "").to_i
      size = size * 1000000
    else
      size.to_i
    end
  end

  def lv_extended()
      lvmargs = []
      lvm_path = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
      lvmargs << lvm_path
      case
        when @resource[:extents] != '' && @resource[:size] != ''
          raise Puppet::Error, "You have both extents and size populated. Choose one or the other."
        when @resource[:size] != ''
          lvmargs << "-L#{@resource[:size]}"
          info("#{lvm_path} is being grown to #{@resource[:size]}")
        when @resource[:extents] != ''
          lvmargs << "-l#{@resource[:extents]}"
          info("#{lvm_path} is being grown to #{@resource[:extents]} extents")
        when @resource[:extents] == '' && @resource[:size] == ''
          fail("You need to populate size or extents.")
      end
      lv_extend(*lvmargs)
      growfs
  end

  def lv_creates()
    dm = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
    unless Facter.value('partitions').key?(dm)
      args = []
      case
      when @resource[:extents] != '' && @resource[:size] != ''
        raise Puppet::Error, "You have both extents and size populated. Choose one or the other."
      when @resource[:size] != ''
        args << "-L#{@resource[:size]}"
      when @resource[:extents] != ''
        args << "-l#{@resource[:extents]}"
      else
        fail("You need to populate size or extents.")
      end
      args << "-n#{@resource[:lvm]}"
      args << "#{@resource[:vg]}"
      #args << "-n"
      lv_create(*args)
      info("LVM #{@resource[:lvm]} is being created")
    end
  end

  def growfs
    lvm_path = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
    if ismounted == true
      xfs_growfs(lvm_path)
      info("#{lvm_path} has been grown")
    end
  end

  ################# Checks ########################

  def islvmextended
      lvm_path = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
      sz = String(Facter.value('partitions')[lvm_path]['size_bytes']) # LVM byte_size
      sz_to_i = convert_to_bytes(sz).to_i # LVM size to integer
      r_sz = @resource[:size]
      r_sz = convert_to_bytes(r_sz) # resource[:size] converted to bytes
      sz_to_i >= r_sz  ? true : false # if resource[:size] is less then the LVM size then return false
  end

  def ismounted
    lvm_path = "/dev/mapper/" + @resource[:vg] + "-" + @resource[:lvm]
    facter_lvm = Facter.value('partitions')[lvm_path]
    facter_lvm.include?('mount')
  end
end


