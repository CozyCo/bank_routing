require "bank_routing/storage/base"

class RoutingNumber

  class SQLStore < StoreBase

    DefaultOptions = {
      table_name: 'routing_numbers'
    }

    Schema = [
      [ :routing_number, :int ],
      [ :office_code, :string ],
      [ :servicing_frb_number, :string ],
      [ :record_type_code, :string ],
      [ :change_date, :string ],
      [ :new_routing_number, :string ],
      [ :name, :string ],
      [ :address, :string ],
      [ :city, :string ],
      [ :state, :string ],
      [ :zip, :string ],
      [ :phone, :string ],
      [ :institution_status_code, :string ],
      [ :data_view_code, :string ],
      [ :alias, :string ],
      [ :prepaid_card, :boolean ],
      [ :possible_fraud_vector, :boolean ],
      [ :filler, :string ]
    ].freeze

    TypeMap = {
      int: 'INT',
      string: 'VARCHAR(36)',
      boolean: 'BOOL'
    }

    ConnectionOptions = []

    def initialize(opts = {})
      opts = self.class::DefaultOptions.merge( opts )
      super( opts )
      require( options[ :require ] ) if options[ :require ]
    end

    def save_statement(num,obj)
      rehash = obj.merge( routing_number: num.to_i ).each_pair.to_a
      keys = rehash.map{ |(k,v)| k.to_s }.join( ',' )
      values = rehash.map{ |(k,v)| v.to_s == "" ? 'NULL' : v.is_a?(String) ? "'#{ store.send( options[ :string_escape_method ], v.to_s ) }'" : v.to_s }.join( ',' )
      "INSERT INTO #{ options[ :table_name ] }(#{ keys }) VALUES (#{ values })"
    end

    def save( num, obj )
      # log.info "Saving with: #{save_statement( num, obj )}"
      store.exec( save_statement( num, obj ) )
    end

    def get_statement( num )
      "SELECT * FROM #{options[:table_name]} WHERE routing_number = #{num.to_s} LIMIT 1"
    end

    def get( num )
      result = store.exec( get_statement( num ) )
      if result.first
        result.first.to_hash.inject({}) { |acc,(k,v)| acc[k.to_sym] = v; acc }
      else
        nil
      end
    end

    def store
      @store ||= connect
    end

    def connect
      log.info "Connecting to #{ self.class.name.gsub( /Store$/, '' ) }."
      log.debug "Connection settings: #{connection_options.inspect}"
      connection_class.send( options[ :connection_method ], connection_options )
    end

    def connection_options
      self.class::ConnectOptions.inject({}) { |acc,k| if options[k.to_sym]; acc[k] = options[k.to_sym]; end; acc }
    end

    def connection_class
      Object.const_get( options[ :connection_class ] )
    end

    def reconnect!
      shutdown!
      store
    end

    def shutdown!
      @store.send( options[ :disconnect_method ] ) if options[ :disconnect_method ]
      @store = nil
    end

    def create_table_statement
      "CREATE TABLE #{ options[ :table_name ] } (routingnumber_id integer PRIMARY KEY, #{ Schema.map {|(field,type)| "#{field.to_s} #{ TypeMap[type] }" }.join( ', ' ) })"
    end

    def create_table!
      log.info "Creating table with: #{create_table_statement}"
      store.exec( create_table_statement )
    end

    def loading!
      create_table!
      super
    end

  end

  Stores[ :sql ] = SQLStore

end
