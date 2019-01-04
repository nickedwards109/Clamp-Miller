class GCodeTemplate
  attr_reader :template

  def initialize
    @template = ''
  end

  def add_gcode_block(gcode)
    template_line = '<span>' + gcode + '</span><br>'
    @template += template_line
  end
end
