module	Rakify
	extend self

	def rakify_log
    	@@rakify_log ||= Logger.new('log/rakify_jobs.log')
  	end
  	
	def rescue_task(parent,method,*args)
		parent = parent.to_s.underscore.classify.constantize
		ts = Time.now
		identifier = "#{parent}.#{method} #{args}"
		rakify_log.info "==#{ts} Running #{identifier}=="
		rakify_log.report_memory
		begin
			parent.send(method.to_s,*args)
		rescue StandardError => e
			rakify_log.info "Rescue task exception in #{identifier} : #{e.message}"
			UserNotifier.exception_notify("Rescue task exception in #{identifier} : #{e.message} #{e.backtrace}").deliver
		end
		rakify_log.report_memory
		UserNotifier.report_memory memory_limit: 200, min_email_interval: 60
		rakify_log.info "==#{Time.now} Completed #{identifier} in #{Time.now - ts} sec=="
		return
	end


end