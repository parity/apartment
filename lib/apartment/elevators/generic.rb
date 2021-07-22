require 'rack/request'
require 'apartment/tenant'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on request
    #
    class Generic

      def initialize(app, processor = nil)
        @app = app
        @processor = processor || method(:parse_tenant_name)
      end

      def call(env)
        request = Rack::Request.new(env)

        database = @processor.call(request)

        if database
          # We are passing true here as we want schema based lookup.
          # And not by changing schema path
          Apartment::Tenant.switch(database, true) { @app.call(env) }
        else
          @app.call(env)
        end
      end

      def parse_tenant_name(request)
        raise "Override"
      end
    end
  end
end
