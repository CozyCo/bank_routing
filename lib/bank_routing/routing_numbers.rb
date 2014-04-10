require 'logger'
require 'yajl'

class RoutingNumber
	
	class InvalidStore < StandardError; end
	
	class StoreBase
		
		def initialize(opts = {})
			@options = opts
			@logger = opts.delete(:logger)
		end
		
		def log
			@logger ||= Logger.new(STDOUT)
		end
		
		def options
			@options
		end
		
		def loaded?
			@loaded
		end
		
		def loaded!
			@loaded = true
		end
		
		def loading!
			return false if loading?
			@loading = true
		end
		
		def loading?
			@loading
		end
		
		def done_loading!
			@loading = false
			loaded!
		end
		
		def save(num,obj)
			puts "Don't know how to save!"
		end
		
		def get(num)
			puts "Don't know how to get!"
		end
		
		def shutdown!
		end
		
		def reconnect!
		end
		
	end
	
	class MemStore < StoreBase
		
		def initialize(opts = {})
			@options = opts
			@vals = {}
		end
		
		def save(num,obj)
			@vals[num.to_s] = obj
		end
		
		def get(num)
			@vals[num.to_s]
		end
		
		def shutdown!
			@vals = nil
		end
		
	end
	
	class RedisStore < StoreBase
		
		LOADED_KEY = "LoadedRoutingNumbers".freeze
		LOADING_KEY = "#{LOADED_KEY}::loading".freeze
		STORAGE_KEY = "RoutingNumberLookup"
		
		def initialize(*args)
			super(*args)
			require 'redis'
		end
		
		def loaded?
			store.exists(LOADED_KEY)
		end
		
		def loaded!
			store.set(LOADED_KEY,"yes")
			store.expire(LOADED_KEY,60*60*24*7)
		end
		
		def loading!
			store.setnx(LOADING_KEY,"yup")
		end
		
		def loading?
			loading!
		end
		
		def done_loading!
			store.del(LOADING_KEY)
			loaded!
		end
		
		def save(num,obj)
			store.hset(STORAGE_KEY,num.to_s,Yajl::Encoder.encode(obj))
		end
		
		def get(num)
			if cnt = store.hget(STORAGE_KEY,num.to_s)
				Yajl::Parser.new(symbolize_keys: true).parse(cnt)
			else
				nil
			end
		end
		
		def store
			@store ||= (
				log.info "Connecting to Redis."
				log.debug "Connection settings: #{options.inspect}"
				Redis.new(options)
			)
		end
		
		def reconnect!
			@store = nil
			store
		end
		
		def shutdown!
			@store = nil
		end
		
	end
	
	# class MemcacheStore < StoreBase
	# 	
	# 	
	# 	
	# end
	
	Stores = {
		default: MemStore,
		memory: MemStore,
		redis: RedisStore,
		# memcached: MemcachedStore
	}
	
	class << self
		
		FORMAT = [
			[:route,9],
			[:office_code,1],
			[:servicing_frb_number,9],
			[:record_type_code,1],
			[:change_date,6],
			[:new_routing_number,9],
			[:name,36],
			[:address,36],
			[:city,20],
			[:state,2],
			[:zip,5],
			[:zip_ext,4],
			[:phone_area,3],
			[:phone_prefix,3],
			[:phone_suffix,4],
			[:institution_status_code,1],
			[:data_view_code,1],
			[:filler,5]
		].freeze
		
		DefaultOptions = {
			store_in: :memory,
			routing_data_url: "https://www.fededirectory.frb.org/FedACHdir.txt",
			routing_data_file: File.expand_path(File.dirname(__FILE__)) + "/../../data/FedACHdir.txt",
			fetch_fed_data: false,
			store_opts: {},
			mapping_file: File.expand_path(File.dirname(__FILE__) + "/../../data/mappings.json"),
			metadata_file: File.expand_path(File.dirname(__FILE__) + "/../../data/metadata.json")
		}.freeze
		
		def init!(opts = {})
			return if @initted
			@options = options.merge(opts)
			if options[:store_in]
				store_in options[:store_in], options[:store_opts]
			end
			unless store.loaded?
				log.info "Loading routing numbers..."
				load_routing_numbers
				log.info "Done loading routing numbers."
			end
			@initted = true
		end
		
		def options=(opts)
			@options = options.merge(opts)
		end
		
		def get(num)
			init!(options)
			if cnt = store.get(num.to_s)
				cnt
			else
				nil
			end
		end
		alias_method :[], :get
		alias_method :find, :get
		
		def store_in(name, opts={})
			raise InvalidStore unless s_cls = Stores[name.to_sym]
			return if @store.is_a?(s_cls)
			@store.shutdown! if @store
			@store = s_cls.new(opts.merge(logger: log))
			@initted = false
			options[:store_in] = name.to_sym
			options[:store_opts] = opts
			init!
		end
		
		def reconnect!
			log.info "Reconnecting!"
			store.reconnect!
		end
		
		private
		
		def store
			@store ||= default_store
		end
		
		def default_store
			Stores[:default].new(logger: log)
		end
		
		def options
			@options ||= DefaultOptions.dup
		end
		
		def get_raw_data
			unless options[:fetch_fed_data]
				log.info "Using routing data from local file at: #{options[:routing_data_file]}"
				File.new(options[:routing_data_file])
			else
				log.info "Getting new bank routing data from: #{options[:routing_data_url]}"
				require 'typhoeus'
				Typhoeus::Request.get(options[:routing_data_url], :ssl_verifypeer => false).body
			end
		end
		
		def load_routing_numbers(data=get_raw_data)
			if store.loading!
				loading!
				data.each_line do |line|
					process_line line
				end
				store.done_loading!
				done_loading!
			end
		end
		
		def process_line(line)
			obj = unpack_line(line)
			rt = obj.delete(:route)
			store.save rt, obj.merge(:routingnumber_id => rt.to_s).merge(@metadata[rt.to_s] || {})
			@cur += 1
			if @cur % 10 == 0
				tm = Time.now - @st_time
				print "\r  #{@cur} loaded (#{tm.round(2)} seconds ~ #{tm > 0 ? (@cur / tm).round(0) : "?"}/sec) "
			end
		end
		
		def pretty_maps
			@pretty_maps
		end
		
		def loading!
			@cur = 0
			@st_time = Time.now
			@pretty_maps = Yajl::Parser.parse(IO.read(options[:mapping_file]))
			@metadata = Yajl::Parser.parse(IO.read(options[:metadata_file]))
		end
		
		def done_loading!
			tm = Time.now - @st_time
			print "\r  #{@cur} loaded (#{tm.round(2)} seconds ~ #{tm > 0 ? (@cur / tm).round(0) : "?"}/sec) \n"
			@cur = @st_time = @pretty_maps = @metadata = nil
		end
		
		def unpack_line(line)
			vals = line.unpack(unpack_template)
			obj = {}
			FORMAT.each_with_index do |(name,length),i|
				val = vals[i]
				obj[name] = converted(name,val)
			end
			obj[:zip] = "#{obj.delete(:zip)}#{(ext = obj.delete(:zip_ext)) and ext.size > 0 ? "-#{ext}" : ""}"
			obj[:phone] = "#{obj.delete(:phone_area)}-#{obj.delete(:phone_prefix)}-#{obj.delete(:phone_suffix)}"
			obj.delete(:garbage)
			obj
		end
		
		def converted(name,val)
			if pretty_maps[name.to_s] and (v = pretty_maps[name.to_s][val])
				v
			else
				val
			end
		end
		
		def unpack_template
			@unpack_format ||= FORMAT.map do |(name,length)|
				"A#{length}"
			end.join
		end
		
		def log
			@logger ||= Logger.new(STDOUT)
		end
		
	end
	
end