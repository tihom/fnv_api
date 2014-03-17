require "logger"

Logger.instance_eval do 
	def memory_usage
		# get mem in MBs
		`ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)[1]/1000
	end

	def process_details
		`ps axo pid,user,command,args | grep #{$$}`.each_line do |l|
			out = l.split(" ")
			next unless out.any? && out.first.to_s == "#{$$}"
			return l
		end
	end
end

Logger.class_eval do 
 
 # logs the memory usage of the current process
   def report_memory
       self.info  'Memory ' + Logger.memory_usage.to_s + 'MB'
   end

end