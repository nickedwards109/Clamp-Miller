require 'rack'
form = File.read('./views/form.html')
require '../lib/Controller.rb'

server = Proc.new do |env|
  if env['PATH_INFO'] == '/'
    ['200', {'Content-type' => 'text/html'}, [form]]
  elsif env['PATH_INFO'] == '/generate_gcode'
    controller = Controller.new(env['QUERY_STRING'])
    gcode = controller.generate_gcode
    ['200', {'Content-type' => 'text/html'}, [gcode]]
  end
end

Rack::Handler::WEBrick.run server
