module Bunny
  # connection manager class for bunny (rabbitmq client)
  class ConnectionManager
    include Singleton
    attr_accessor :active_connection, :active_channel

    def initialize
      establish_connection
    end

    def connection
      establish_connection unless connected?

      @active_connection
    end

    def channel
      establish_connection unless connected? && @active_channel&.open?

      @active_channel
    end

    private

    def establish_connection
      @active_connection = Bunny.new(user: 'admin', password: 'admin', host: 'rabbitmq')

      @active_connection.start
      @active_channel = active_connection.create_channel

      @active_connection
    end

    def connected?
      @active_connection&.connected?
    end
  end
end
