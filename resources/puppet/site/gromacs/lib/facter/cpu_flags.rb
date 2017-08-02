Facter.add("cpu_flags") do
  confine :kernel => :linux
  setcode do
    flags = []
    File.readlines('/proc/cpuinfo').each do |l|
      lp = l.split(':')
      if lp[0].strip == 'flags'
        flags = lp[1].split
        break
      end
    end

    flags
  end
end
