class profiles::common::packages (
    $packages = lookup('packages::installed'),
) {
    package { $packages:
            ensure => installed,
              }
}
