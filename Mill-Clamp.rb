require './ClampMaker.rb'

puts "(Dimension #1): What is the length of the clamp?"
	 length = Float(gets)

puts "(Dimension #2): What is the width of the clamp?"
	 width = Float(gets)

puts "(Dimension #3): There will be a hole for housing the height adjustment screw. What is the diameter of this height adjustment screw hole?"
	 hole_diameter = Float(gets)

puts "(Dimension #4): There will be a slot for the fastening screw. One end of the slot (at the center of the slot end's radius) will have a certain distance to the height adjustment screw hole. What is this distance?"
	 slot_to_hole_distance = Float(gets)

puts "(Dimension #5): The opposite end of the slot will have a certain distance to the end of the clamp. What is this distance?"
	 slot_to_end_of_clamp_distance = Float(gets)

puts "(Dimension #6): How wide is the slot?"
	 slot_width = Float(gets)

puts "(Dimension #7): What is the thickness of the material stock?"
	 material_thickness = Float(gets)

puts "What is the tool radius?"
	 tool_radius = Float(gets)

puts "What is the XY end-milling feedrate?"
	 xy_feedrate = Float(gets)

puts "What is the Z plunge feedrate?"
	 z_feedrate = Float(gets)

puts "What is the axial depth of cut?"
	 axial_depth_of_cut = Float(gets)

puts "What is a safe Z height that the tool will retract to before rapid feed to a new XY location?"
	 safe_z_height = Float(gets)

puts ""
puts "When setting up the CNC milling machine, follow these instructions: Use a slot drill (an end mill that can plunge in -Z). Set X=0 and Y=0 on the workpiece such that the Cartesian quadrant within X>0 and Y>0 is solid workpiece material. When running the CNC program, start with the tool at X=0, Y=0, and Z=0."	 

puts "Here is your CNC program: (Edit this to add spindle speed, coolant control, tool numbers, etc. as necessary)"
puts ""

clampmaker = ClampMaker.new(length, width, material_thickness, hole_diameter, slot_to_hole_distance, slot_width, slot_to_end_of_clamp_distance, tool_radius, xy_feedrate, z_feedrate, axial_depth_of_cut, safe_z_height)
clampmaker.create_toolpaths	