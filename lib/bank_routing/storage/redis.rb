require "bank_routing/storage/base"

class RoutingNumber

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
      @store ||= connect
    end

    def connect
      log.info "Connecting to Redis."
      log.debug "Connection settings: #{options.inspect}"
      Redis.new(options)
    end

    def reconnect!
      @store = nil
      store
    end

    def shutdown!
      @store = nil
    end

  end

  Stores[:redis] = RedisStore

end
