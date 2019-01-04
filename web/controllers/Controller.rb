require_relative '../../lib/ClampMaker.rb'
require 'cgi'

class Controller
attr_reader :length, :width, :material_thickness, :xy_feedrate, :z_feedrate, :axial_depth_of_cut

  def initialize(query_string)
    params = CGI::parse(query_string)
    if !params.empty?
      @length = params["length"].first.to_f
      @width = params["width"].first.to_f
      @material_thickness = params["material-thickness"].first.to_f
      @xy_feedrate = params["xy-feedrate"].first.to_f
      @z_feedrate = params["z-feedrate"].first.to_f
      @axial_depth_of_cut = params["axial-depth-of-cut"].first.to_f
    end
  end

  def render_form
    File.read('../web/views/form.html')
  end

  def generate_gcode
    clamp_maker = ClampMaker.new(self.length, self.width, self.material_thickness, self.xy_feedrate, self.z_feedrate, self.axial_depth_of_cut)
    clamp_maker.generate_gcode
  end
end
