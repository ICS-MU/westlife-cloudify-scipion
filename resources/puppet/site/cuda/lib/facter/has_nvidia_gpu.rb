Facter.add("has_nvidia_gpu") do
  confine :kernel => :linux
  setcode do
    out = Facter::Core::Execution.exec("lspci | egrep -i '(3D|VGA).*NVIDIA'")
    if out and ! out.empty?
      true
    else
      out = Facter::Core::Execution.exec("dmesg | egrep -i '(loading NVIDIA|Initialized nouveau)'")
      if out and ! out.empty?
        true
      else
        false
      end
    end
  end
end
