module VagrantDNS
  class RestartMiddleware
    def initialize(app, env)
      @app = app
      @env = env
    end

    def call(env)
      if VagrantDNS::Config.auto_run
        tmp_path = File.join(env[:vm].env.tmp_path, "dns")
        VagrantDNS::Configurator.new(env[:vm], tmp_path).run!
        VagrantDNS::Service.new(tmp_path).restart!
        env[:ui].info "Restarted DNS Service"
      end

      @app.call(env)
    end
  end
end