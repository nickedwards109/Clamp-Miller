class ClampMaker



	def initialize(length, width, material_thickness, xy_feedrate, z_feedrate, axial_depth_of_cut)
		
		# User-defined instance variables
		@length = length
		@width = width
		@material_thickness = material_thickness
		@xy_feedrate = xy_feedrate
		@z_feedrate = z_feedrate
		@axial_depth_of_cut = axial_depth_of_cut

		# Default instance variables
		@hole_diameter = 0.325
		@slot_to_hole_distance = 0.5
		@slot_width = 0.2
		@slot_to_end_of_clamp_distance = 0.5
		@tool_radius = 0.0625
		@safe_z_height = 0.125
		@large_profile_radius = width/2
		@small_profile_radius = width/4
		@half_width = width/2

	end

	# Methods for getting absolute positional targets for CNC code generators.
	# These methods must be used in absolute mode.
	# In other words, G90 must be more recent in the generated CNC program than G91.

		def x_position_at_hole_diameter
			(@half_width + 0.5*@hole_diameter - @tool_radius).round(3)
		end

		def y_position_at_hole_diameter
			(@length - @half_width).round(3)
		end

		def i_offset_for_hole_radius
			-(0.5*@hole_diameter - @tool_radius).round(3)
		end

		def j_offset_for_hole_radius
			0.0
		end

		def x_position_of_hole_center
			@half_width.round(3)
		end

		def y_position_of_hole_center
			(@length - @large_profile_radius).round(3)
		end

		def x_position_of_slot_center
			@half_width.round(3)
		end

		def y_position_of_slot_top_center
			(@length - @large_profile_radius - @slot_to_hole_distance).round(3)
		end

		def y_position_of_slot_bottom_center
			@slot_to_end_of_clamp_distance.round(3)
		end

		def x_position_at_right_slot_edge
			(@half_width + @slot_width/2 - @tool_radius).round(3)
		end

		def x_position_at_left_slot_edge
			(@half_width - @slot_width/2 + @tool_radius).round(3)
		end

		def i_offset_for_slot_end_radius
			(@slot_width/2 - @tool_radius).round(3)
		end

		def j_offset_for_slot_end_radius
			0.0
		end

		def x_position_for_starting_outside_profile_cut
			(@width + @tool_radius).round(3)
		end

		def y_position_for_starting_outside_profile_cut
			@small_profile_radius.round(3)
		end

		def x_position_at_bottom_of_lower_right_profile_radius
			(@width - @small_profile_radius).round(3)
		end

		def y_position_at_bottom_of_lower_right_profile_radius
			@tool_radius.round(3)
		end

		def i_offset_for_lower_right_profile_radius
			(@small_profile_radius + @tool_radius).round(3)
		end

		def j_offset_for_lower_right_profile_radius
			0.0
		end

		def x_position_at_bottom_of_lower_left_profile_radius
			@small_profile_radius.round(3)
		end

		def x_position_at_top_of_lower_left_profile_radius
			@tool_radius.round(3)
		end

		def y_position_at_top_of_lower_left_profile_radius
			@small_profile_radius.round(3)
		end

		def i_offset_for_lower_left_profile_radius
			0.0
		end

		def j_offset_for_lower_left_profile_radius
			(@small_profile_radius + @tool_radius).round(3)
		end

		def y_position_at_bottom_of_top_profile_radius
			(@length - @large_profile_radius).round(3)
		end

		def x_position_at_right_side_of_top_profile_radius
			(@width + @tool_radius).round(3)
		end

		def i_offset_for_top_profile_radius
			(@large_profile_radius + @tool_radius).round(3)
		end


	# Methods for getting relative positional targets for CNC code generators.
	# These methods must be used in incremental mode.
	# In other words, G91 must be more recent in the generated CNC program than G90.

	def safe_z_height
		@safe_z_height.round(3)
	end

	def safe_z_height_less_one_radius
		(@safe_z_height - @tool_radius).round(3)
	end

	def axial_depth_of_cut_plus_one_radius
		(@axial_depth_of_cut + @tool_radius).round(3)
	end


	# Methods for getting feedrates

	def xy_feedrate
		@xy_feedrate
	end

	def z_feedrate
		@z_feedrate
	end

	# Methods for generating modular snippets of CNC code

		def create_XY_hole_profile_toolpath

			# Move to the furthest X position in the hole to prepare for cutting the diameter of the hole.
			puts "G1X#{x_position_at_hole_diameter}Y#{y_position_at_hole_diameter}F#{xy_feedrate}"

			# Cut the diameter of the hole.
			puts "G3X#{x_position_at_hole_diameter}Y#{y_position_at_hole_diameter}I#{i_offset_for_hole_radius}J#{j_offset_for_hole_radius}F#{xy_feedrate}"

		end

		def create_hole_toolpath

			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

			#create multiple successive profile passes while incrementing the axial depth of cut. stop doing this when the entire tool radius has completely machined through the material stock.
			while (remaining_Z_stock + 1.1*@tool_radius) > 0

				#rapid feed up in Z by one safe Z height amount to prepare for XY motion
				puts "G91"
				puts "G0Z#{safe_z_height}"
				puts "G90"

				#rapid feed to the XY location of the hole
				puts "G0X#{x_position_of_hole_center}Y#{y_position_of_hole_center}"

				#rapid feed/plunge to one tool radius above the machined material
				#feed/plunge into the material in Z by an increment of one axial depth of cut
				puts "G91"
				puts "G0Z-#{safe_z_height_less_one_radius}"
				puts "G1Z-#{axial_depth_of_cut_plus_one_radius}F#{z_feedrate}"
				puts "G90"

				#create an XY toolpath for machining the outside profile
				self.create_XY_hole_profile_toolpath

				#there is now one axial depth of cut less of material
				remaining_Z_stock = remaining_Z_stock - @axial_depth_of_cut

			end

				#The hole is now complete. Rapid feed to Z zero to prepare for the next machining operation.
				puts "G0Z0.0"

		end	


		def create_slot_toolpath
			
			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

				#create multiple successive profile passes while incrementing the axial depth of cut
				while (remaining_Z_stock + 2*@tool_radius) > 0

					#rapid feed up in Z by one safe Z height amount to prepare for XY motion
					puts "G91"
					puts "G0Z#{safe_z_height}"
					puts "G90"

					#rapid feed to the XY coordinates at the radius center at the slot top
					puts "G0X#{x_position_of_slot_center}Y#{y_position_of_slot_top_center}"

					#rapid feed/plunge to one tool radius above the machined material
					#feed/plunge into the material in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G0Z-#{safe_z_height_less_one_radius}"
					puts "G1Z-#{axial_depth_of_cut_plus_one_radius}F#{z_feedrate}"
					puts "G90"

					#create an XY toolpath for machining the outside profile
					self.create_XY_slot_profile_toolpath

					remaining_Z_stock = remaining_Z_stock - @axial_depth_of_cut

				end

					#The slot is now complete. Rapid feed to Z zero to prepare for the next machining operation.
					puts "G0Z0.0"

		end


				def create_XY_slot_profile_toolpath

					#feed to the Y position at the end of the slot opposite the hole
					puts "G1Y#{y_position_of_slot_bottom_center}F#{xy_feedrate}"

					#feed in the +X direction to the position where the tool edge is at the final profile of the slot
					puts "G1X#{x_position_at_right_slot_edge}F#{xy_feedrate}"

					#make the final linear interpolation climb milling pass in the +Y direction
					puts "G1Y#{y_position_of_slot_top_center}F#{xy_feedrate}"

					#make the final counter-clockwise circular interpolation pass about the top radius of the slot
					puts "G3X#{x_position_at_left_slot_edge}I-#{i_offset_for_slot_end_radius}J#{j_offset_for_slot_end_radius}F#{xy_feedrate}"

					#make the final linear interpolation climb milling pass in the -Y direction
					puts "G1Y#{y_position_of_slot_bottom_center}F#{xy_feedrate}"

					#make the final counter-clockwise circular interpolation pass about the bottom radius of the slot
					puts "G3X#{x_position_at_right_slot_edge}I#{i_offset_for_slot_end_radius}J#{j_offset_for_slot_end_radius}F#{xy_feedrate}" 

				end




		def create_outer_profile_toolpath

			#rapid feed up in Z by one safe Z height amount to prepare for XY motion
			puts "G91"
			puts "G0Z#{safe_z_height}"
			puts "G90"

			#rapid feed to the XY coordinates for a Z plunge at the top of the lower right radius of the clamp
			puts "G0X#{x_position_for_starting_outside_profile_cut}Y#{y_position_for_starting_outside_profile_cut}"

			#rapid feed/plunge to one tool radius above the machined material
			#feed/plunge to Z zero, immediately followed by the loop that incrementally feeds/plunges into the material in Z to prepare for end-milling
			puts "G91"
			puts "G0Z-#{safe_z_height_less_one_radius}"
			puts "G1Z-#{(@tool_radius + @axial_depth_of_cut).round(3)}F#{z_feedrate}"
			puts "G90"

			#the tool is now one axial depth of cut into the material, so make an initial cutting pass.
			#for subsequent passes, the depth of cut will be incremented for each pass, without the need to approach form a safe Z height.
			self.create_XY_outer_profile_toolpath
			
			#specify a variable to store the amount of material that is not yet machined. 
			#here, one cutting pass has already been done. 
			remaining_Z_stock = @material_thickness - @axial_depth_of_cut

				#create multiple successive profile passes while incrementing the axial depth of cut
				while (remaining_Z_stock + 2*@tool_radius) > 0

					#feed/plunge down in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G1Z-#{(@axial_depth_of_cut).round(3)}F#{z_feedrate}"
					puts "G90"

					#create an XY toolpath for machining the outside profile
					self.create_XY_outer_profile_toolpath

					remaining_Z_stock = remaining_Z_stock - @axial_depth_of_cut

				end

					#The entire clamp is now complete. Rapid feed to the safe Z height.
					puts "G0Z#{@safe_z_height}"

					#Rapid feed to X zero and Y zero
					puts "G0X0.0Y0.0"

					#Feed to Z zero
					puts "G1Z0.0"

		end

				def create_XY_outer_profile_toolpath

					#counter-clockwise circular interpolation feed to machine the lower right profile radius
					puts "G2X#{x_position_at_bottom_of_lower_right_profile_radius}Y-#{y_position_at_bottom_of_lower_right_profile_radius}I-#{i_offset_for_lower_right_profile_radius}J#{j_offset_for_lower_right_profile_radius}F#{xy_feedrate}"

					#linear interpolation feed to an X location of one small profile radius from the left side
					puts "G1X#{x_position_at_bottom_of_lower_left_profile_radius}F#{xy_feedrate}"

					#counter-clockwise circular interpolation feed to machine the lower left profile radius
					puts "G2X-#{x_position_at_top_of_lower_left_profile_radius}Y#{y_position_at_top_of_lower_left_profile_radius}I#{i_offset_for_lower_left_profile_radius}J#{j_offset_for_lower_left_profile_radius}F#{xy_feedrate}"

					#linear interpolation feed to a Y location of the clamp length minus the top profile radius
					puts "G1Y#{y_position_at_bottom_of_top_profile_radius}F#{xy_feedrate}"

					#counter-clockwise circular interpolation feed to machine the large profile radius
					puts "G2X#{x_position_at_right_side_of_top_profile_radius}Y#{y_position_at_bottom_of_top_profile_radius}I#{i_offset_for_top_profile_radius}J0.0F#{xy_feedrate}"

					#linear interpolation feed to the starting position
					puts "G1X#{x_position_for_starting_outside_profile_cut}Y#{y_position_for_starting_outside_profile_cut}F#{xy_feedrate}"

				end


	# One method to tie it all together and generate all the CNC code!

	def create_toolpaths

		self.create_hole_toolpath
		self.create_slot_toolpath
		self.create_outer_profile_toolpath

	end


end