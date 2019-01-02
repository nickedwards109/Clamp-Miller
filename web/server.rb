require 'rack'

server = Proc.new do |env|
  if env['PATH_INFO'] == '/'
    ['200', {'Content-type' => 'text/html'}, ['Hello Rack']]
  end
end

Rack::Handler::WEBrick.run server
