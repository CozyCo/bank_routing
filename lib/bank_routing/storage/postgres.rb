require 'pg'
require "bank_routing/storage/sql"

class RoutingNumber

  class PostgresStore < SQLStore

    DefaultOptions = {
      table_name: 'routing_numbers',
      connection_class: :PG,
      connection_method: :connect,
      disconnect_method: :finish,
      string_escape_method: :escape_string
    }

    TypeMap = {
      int: 'integer',
      string: 'text',
      boolean: 'bool'
    }

    ConnectOptions = PG::Connection::CONNECT_ARGUMENT_ORDER

    def create_table_statement
      "DROP TABLE #{ options[ :table_name ] }; CREATE TABLE #{ options[ :table_name ] } (routingnumber_id serial PRIMARY KEY, #{ Schema.map {|(field,type)| "#{field.to_s} #{ TypeMap[type] }" }.join( ', ' ) })"
    end

  end

  Stores[:postgres] = PostgresStore

end
