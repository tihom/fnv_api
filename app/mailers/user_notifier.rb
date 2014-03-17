class UserNotifier < ActionMailer::Base
  default from: "auto-mailer@aalgro.com"
  default to: "mohitagg@gmail.com"
 
  def exception_notify(msg)
    mail(subject: "Exception encountered in #{Rails.env} : #{HOST}", body: msg)
  end

  # notify admin if the memeory of a process goes above the limit
  def report_memory(opts={})
    mem = Logger.memory_usage
    limit = opts[:memory_limit] || 250
    if (mem > limit)# minimum interval between emails for the same process
      host = `hostname`
      opts[:min_email_interval] ||= 600
      key = "#{$$}_#{host}_report_memory_usage"
      last_sent = Rails.cache.read(key) || 0
      if (Time.now.to_i - last_sent) > opts[:min_email_interval]
        mail(:subject => "Memory usage for process id #{$$} is #{mem}MB on #{host}",
          :body => "#{Logger.process_details}\n#{caller.to_yaml}").deliver
        Rails.cache.write(key, Time.now.to_i)
      end
    end
  end
end
