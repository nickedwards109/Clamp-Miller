require 'rack'
require './controllers/Controller.rb'

server = Proc.new do |env|
  controller = Controller.new(env['QUERY_STRING'])
  if env['PATH_INFO'] == '/'
    response = controller.render_form
    ['200', {'Content-type' => 'text/html'}, [response]]
  elsif env['PATH_INFO'] == '/generate_gcode'
    response = controller.generate_gcode
    ['200', {'Content-type' => 'text/html'}, [response]]
  end
end

Rack::Handler::WEBrick.run server
