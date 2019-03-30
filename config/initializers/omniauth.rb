OmniAuth::Strategy.module_eval do
    def setup_phase
        case options.name.to_s
        when 'google_oauth2'
            options.client_id = Setting["GOOGLE_KEY"]
            options.client_secret = Setting["GOOGLE_SECRET"]
        else
            options.client_id = Setting["#{options.name.upcase}_KEY"]
            options.client_secret = Setting["#{options.name.upcase}_SECRET"]
        end
        if options[:setup].respond_to?(:call)
            log :info, 'Setup endpoint detected, running now.'
            options[:setup].call(env)
        elsif options[:setup]
            log :info, 'Calling through to underlying application for setup.'
            setup_env = env.merge('PATH_INFO' => setup_path, 'REQUEST_METHOD' => 'GET')
            call_app!(setup_env)
        end
    end
end