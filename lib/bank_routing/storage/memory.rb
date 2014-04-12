require "bank_routing/storage/base"

class RoutingNumber

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

  Stores[:default] = MemStore
  Stores[:memory] = MemStore

end
