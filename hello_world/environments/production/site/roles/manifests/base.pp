class roles::base {
    contain profiles::common::ntp_file_replace  
    contain profiles::common::packages  
    contain profiles::common::nas_mount_misc
    contain profiles::common::user_andrew
}
