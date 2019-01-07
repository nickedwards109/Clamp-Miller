class GCodeTemplate
  attr_reader :template

  def initialize
    explanatory_message = '<span>Here is your CNC program! You can copy it and paste it <a href="https://nraynaud.github.io/webgcode/">here</a> to preview it. Please take a look at the README in the <a href="https://github.com/nickedwards109/Clamp-Miller">source code</a> for guidelines on setting up your CNC router.</span><br/><br/>'
    @template = explanatory_message
  end

  def add_gcode_block(gcode)
    template_line = '<span>' + gcode + '</span><br>'
    @template += template_line
  end
end
