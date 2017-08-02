class cuda::toolkit {
  $_release = regsubst($::cuda::release, '\.', '-', 'G')
  $_packages = ["${::cuda::package_toolkit}-${_release}"]
  ensure_packages($_packages)
}
