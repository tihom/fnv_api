# This is a generic class that holds the methods to extract data from a html/xml page using Nokogiri
	class NokogiriNode


		class << self
			# Return the text value of an node.
			def get(node, path='.')
				return unless node
				result = node.xpath(path)
				result = textf(result.text) if result
				result
			end

			# Reutrn the text value of first matching node
			def get_first(node,path='.')
				return unless node
				result = node.xpath(path).first
				result ? textf(result.text) : "" # return blank if no mathcing elment to be consistent with get method
			end

			def get_top(node,path='.')
				return unless node
				result = node.xpath(path)
				result ? textf(result.xpath('text()')) : "" # return blank if no mathcing elment to be consistent with get method
			end

			def csstxt(node,path='.')
				return unless node
				res = node.css(path)
				res = textf(res.text) if res
				res
			end


		    def textf(text)
		    	return unless text
		    	# encode does not do anything if the string is already in utf-8 so changing back and forth to another encoding to replace invalid
		    	# see http://stackoverflow.com/questions/2982677/ruby-1-9-invalid-byte-sequence-in-utf-8
		    	s = text.encode('utf-16le',:invalid => :replace, :undef => :replace, replace: '')
		    	s.encode('utf-8',:invalid => :replace, :undef => :replace, replace: '')
		    end

		    def strpdate_with_current_time(str,format)
		    	# http://danilenko.org/2012/7/6/rails_timezones/
				# in time zone is needed to make it beginning of day in IST or the rails default time zone which is set to IST in application.rb
				
		    	t = Date.strptime(str, format).in_time_zone rescue nil
		    	return unless t
		    	hour_of_day = Time.zone.now - Time.zone.now.beginning_of_day
		    	current_date = Time.zone.today
		    	# if the current data is higher than set t to 24 hours if lower set it to 0 hours else same
		    	if current_date > t.to_date
		    		hour_of_day = 24.hours - 1.second
		    	elsif current_date < t.to_date
		    		hour_of_day = 0.hours
		    	end
		    	t  += hour_of_day
		    	t
		    end


		end


	    # Pass Nokogiri::HTML::node object
	    def initialize(url=nil,node=nil)
	    	if url 
	    		@url = url.to_s
	    		html = CustomUri.open_url url.to_s
				@node = Nokogiri::HTML(html) #, nil, 'UTF-8')
			else
		        @node = node
		  	end
	    end

	    def textf(text)
	    	NokogiriNode.textf(text)
	    end
	    
		def node
			@node
		end
		

	    # Returns the attribute value for the give key
	    def /(key)
	      @node[key]
	    end


	   # Return an array of nodes matching the given path
	    def get_nodes(path)
	      nodes = @node.xpath(path)
	      return unless nodes
	      nodes = nodes.map{|node| NokogiriNode.new(nil,node)}
	    end
	    
	    # return first node if more than one nodes found
	    def get_node(path)
	      nodes = get_nodes(path)
	      nodes[0] if nodes
	    end

	    def get_nodes(path)
	    	nodes = @node.xpath(path)
	    end

	    def get_node(path)
	    	nodes = get_nodes(path)
	    	nodes.first if nodes
	    end

	    def get_top(path='.')
	    	NokogiriNode.get_top(@node, path)
	    end

		# Get the text value of the given path, leave empty to retrieve current node value.
	    def get(path='.')
	        NokogiriNode.get(@node, path)
	    end

	    def csstxt(path='.')
	        NokogiriNode.csstxt(@node, path)
	    end

	    def extract_rs(txt)
	    	txt.gsub(/\s+Rs\.?\s+/i,"").strip.to_i
	    end

	    def strpdate_with_current_time(str,format)
	    	NokogiriNode.strpdate_with_current_time(str,format)
	    end

	end