class RoutingNumber

  Stores = {}

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

end
