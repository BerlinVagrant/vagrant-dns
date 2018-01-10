module VagrantDNS
  module Middlewares
    class ConfigUp
      def initialize(app, env)
        @app = app
        @env = env
      end

      def call(env)
        @env = env
        vm = env[:machine]
        if VagrantDNS::Config.auto_run
          tmp_path = File.join(vm.env.tmp_path, "dns")
          VagrantDNS::Configurator.new(vm, tmp_path).up!
        end
        @app.call(env)
      end
    end
  end
end
