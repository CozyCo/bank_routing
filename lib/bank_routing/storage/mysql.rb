require 'mysql2'
require "bank_routing/storage/sql"

class RoutingNumber

  class MySQLStore < SQLStore

    DefaultOptions = {
      table_name: 'routing_numbers',
      connection_class: Mysql2::Client,
      connection_method: :new,
      string_escape_method: :escape
    }

    def create_table_statement
      "CREATE TABLE IF NOT EXISTS #{ options[ :table_name ] } (id integer PRIMARY KEY AUTO_INCREMENT, #{ Schema.map {|(field,type)| "#{field.to_s} #{ TypeMap[type] }" }.join( ', ' ) })"
    end

  end

  Stores[:mysql] = MySQLStore

end
