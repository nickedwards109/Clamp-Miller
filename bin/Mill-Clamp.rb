require '../lib/ClampMaker.rb'

puts "Units are inches." 
puts ""

puts "What is the length of the clamp?"
	 length = Float(gets)
puts ""

puts "What is the width of the clamp?"
	 width = Float(gets)
puts ""

puts "What is the thickness of the material stock?"
	 material_thickness = Float(gets)
puts ""

puts "What is the XY end-milling feedrate?"
	 xy_feedrate = Float(gets)
puts ""

puts "What is the Z plunge feedrate?"
	 z_feedrate = Float(gets)
puts ""

puts "What is the axial depth of cut?"
	 axial_depth_of_cut = Float(gets)
puts ""

puts "When setting up the CNC milling machine, follow these instructions: Use a 1/8\" ball end mill as the cutting tool. Set X=0 and Y=0 on the workpiece such that the Cartesian quadrant within X>0 and Y>0 is solid workpiece material. Ensure that no point on the top of the workpiece surface extends more than 1/8\" above Z=0. When running the CNC program, start with the tool at X=0, Y=0, and Z=0."	 
puts ""

puts "Here is your CNC program: (Edit this to add spindle speed, coolant control, tool numbers, etc. as necessary)"
puts ""

clampmaker = ClampMaker.new(length, width, material_thickness, xy_feedrate, z_feedrate, axial_depth_of_cut)
clampmaker.create_toolpaths	