require "uri"

# customized methods to open a web page built on top of uri class
# it would hold methods to regulate calls to a website and to add options like roxy server and error handling
class CustomUri
	attr_accessor :url, :uri

	class << self
		def parse(url)
			URI.parse self.sanitize(url)
		end

		# See http://stackoverflow.com/questions/3891158/how-do-i-monkey-patch-rubys-uri-parse-method
		# for reason of ecaping square brackets
		def sanitize(url)
			URI.encode url.strip.gsub('[', '%5B').gsub(']', '%5D')
		end

		def open_url(url,opts={})
			#puts response.body, response.code, response.message, response.headers.inspect
			response = HTTParty.get url, opts
			response.body
		end

		def build_url(opts)
			uri = URI::HTTP.build(:host => opts[:host],
	                      :path => opts[:path]	                      
	                      )
			uri.query_values = opts[:query].map{ |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&') if opts[:query].present?
			uri
		end

	end

	def initialize(url)
		self.url = url
		self.uri = CustomURI.parse(url)
	end

end