module VagrantDNS
  class RestartMiddleware
    def initialize(app, env)
      @app = app
      @env = env
    end

    def call(env)
      @env = env
      vm = env[:machine]
      if VagrantDNS::Config.auto_run
        tmp_path = File.join(vm.env.tmp_path, "dns")
        VagrantDNS::Configurator.new(vm, tmp_path).run!
        VagrantDNS::Service.new(tmp_path).restart!
        env[:ui].info "Restarted DNS Service"
      end

      @app.call(env)
    end
  end
end
