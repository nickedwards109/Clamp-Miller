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

	# Methods for setting positional targets for CNC code generators

		def x_position_for_cutting_hole
			(@half_width + 0.5*@hole_diameter - @tool_radius).round(3)
		end

		def y_position_for_cutting_hole
			(@length - @half_width).round(3)
		end

		def i_offset_for_cutting_hole
			-(0.5*@hole_diameter - @tool_radius).round(3)
		end

		def j_offset_for_cutting_hole
			0.0
		end

	# Methods for generating modular snippets of CNC code

		def create_XY_hole_profile_toolpath

			# Move to the furthest X position in the hole to prepare for cutting the diameter of the hole.
			puts "G1X#{x_position_for_cutting_hole}Y#{y_position_for_cutting_hole}F#{@xy_feedrate}"

			# Cut the diameter of the hole.
			puts "G3X#{x_position_for_cutting_hole}Y#{y_position_for_cutting_hole}I#{i_offset_for_cutting_hole}J#{j_offset_for_cutting_hole}F#{@xy_feedrate}"

		end

		def create_hole_toolpath

			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

			#create multiple successive profile passes while incrementing the axial depth of cut. stop doing this when the entire tool radius has completely machined through the material stock.
			while (remaining_Z_stock + 1.1*@tool_radius) > 0

				#rapid feed up in Z by one safe Z height amount to prepare for XY motion
				puts "G91"
				puts "G0Z#{@safe_z_height.round(3)}"
				puts "G90"

				#rapid feed to the XY location of the hole
				puts "G0X#{@large_profile_radius.round(3)}Y#{(@length - @large_profile_radius).round(3)}"

				#rapid feed/plunge to one tool radius above the machined material
				#feed/plunge into the material in Z by an increment of one axial depth of cut
				puts "G91"
				puts "G0Z-#{(@safe_z_height - @tool_radius).round(3)}"
				puts "G1Z-#{(@axial_depth_of_cut + @tool_radius).round(3)}F#{@z_feedrate}"
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
					puts "G0Z#{@safe_z_height.round(3)}"
					puts "G90"

					#rapid feed to the XY coordinates at the radius center at the slot top
					puts "G0X#{@half_width.round(3)}Y#{(@length - @large_profile_radius - @slot_to_hole_distance).round(3)}"

					#rapid feed/plunge to one tool radius above the machined material
					#feed/plunge into the material in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G0Z-#{(@safe_z_height - @tool_radius).round(3)}"
					puts "G1Z-#{(@axial_depth_of_cut + @tool_radius).round(3)}F#{@z_feedrate}"
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
					puts "G1Y#{@slot_to_end_of_clamp_distance.round(3)}F#{@xy_feedrate}"

					#set a variable to represent total slot stock remaining on both opposing sides
					remaining_XY_slot_stock = @slot_width - 2*@tool_radius

					#define a counting variable
					i = 1

					#rough out the inner slot profile until there is less than one tool radius of stock remaining on both opposing sides
					while (remaining_XY_slot_stock/2) > @tool_radius

						#feed in the +X direction by one tool radius to prepare for an inner profile climb milling cut
						puts "G1X#{(@half_width + i*@tool_radius).round(3)}F#{@xy_feedrate}"

						#make a linear interpolation climb milling pass in the +Y direction
						puts "G1Y#{(@length - @large_profile_radius - @slot_to_hole_distance).round(3)}F#{@xy_feedrate}"

						#make a counter-clockwise circular interpolation pass about the top radius of the slot
						puts "G3X#{(@half_width - i*@tool_radius).round(3)}I-#{(i*@tool_radius).round(3)}J0.0F#{@xy_feedrate}"

						#make a linear interpolation climb milling pass in the -Y direction
						puts "G1Y#{@slot_to_end_of_clamp_distance.round(3)}F#{@xy_feedrate}"

						#make a counter-clockwise circular interpolation pass about the bottom radius of the slot
						puts "G3X#{(@half_width + i*@tool_radius).round(3)}I#{(i*@tool_radius).round(3)}J0.0F#{@xy_feedrate}" 

						remaining_XY_slot_stock = remaining_XY_slot_stock - 2*@tool_radius

						i = i + 1

					end

					#create the final passes to machine the final inner profile of the slot
					#feed in the +X direction to the position where the tool edge is at the final profile of the slot
					puts "G1X#{(@half_width + @slot_width/2 - @tool_radius).round(3)}F#{@xy_feedrate}"

					#make the final linear interpolation climb milling pass in the +Y direction
					puts "G1Y#{(@length - @large_profile_radius - @slot_to_hole_distance).round(3)}F#{@xy_feedrate}"

					#make the final counter-clockwise circular interpolation pass about the top radius of the slot
					puts "G3X#{(@half_width - @slot_width/2 + @tool_radius).round(3)}I-#{(@slot_width/2 - @tool_radius).round(3)}J0.0F#{@xy_feedrate}"

					#make the final linear interpolation climb milling pass in the -Y direction
					puts "G1Y#{@slot_to_end_of_clamp_distance.round(3)}F#{@xy_feedrate}"

					#make the final counter-clockwise circular interpolation pass about the bottom radius of the slot
					puts "G3X#{(@half_width + @slot_width/2 - @tool_radius).round(3)}I#{(@slot_width/2 - @tool_radius).round(3)}J0.0F#{@xy_feedrate}" 

				end




		def create_outer_profile_toolpath

			#rapid feed up in Z by one safe Z height amount to prepare for XY motion
			puts "G91"
			puts "G0Z#{@safe_z_height.round(3)}"
			puts "G90"

			#rapid feed to the XY coordinates for a Z plunge at the top of the lower right radius of the clamp
			puts "G0X#{(@width + @tool_radius).round(3)}Y#{@small_profile_radius.round(3)}"

			#rapid feed/plunge to one tool radius above the machined material
			#feed/plunge to Z zero, immediately followed by the loop that incrementally feeds/plunges into the material in Z to prepare for end-milling
			puts "G91"
			puts "G0Z-#{(@safe_z_height - @tool_radius).round(3)}"
			puts "G1Z-#{(@tool_radius).round(3)}F#{@z_feedrate}"
			
			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

				#create multiple successive profile passes while incrementing the axial depth of cut
				while (remaining_Z_stock + 2*@tool_radius) > 0

					#feed/plunge down in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G1Z-#{(@axial_depth_of_cut).round(3)}F#{@z_feedrate}"
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
					puts "G2X#{(@width - @small_profile_radius).round(3)}Y-#{@tool_radius.round(3)}I-#{(@small_profile_radius + @tool_radius).round(3)}J0.0F#{@xy_feedrate}"

					#linear interpolation feed to an X location of one small profile radius from the left side
					puts "G1X#{@small_profile_radius.round(3)}F#{@xy_feedrate}"

					#counter-clockwise circular interpolation feed to machine the lower left profile radius
					puts "G2X-#{@tool_radius.round(3)}Y#{@small_profile_radius.round(3)}I0.0J#{(@small_profile_radius + @tool_radius).round(3)}F#{@xy_feedrate}"

					#linear interpolation feed to a Y location of the clamp length minus the profile radius
					puts "G1Y#{(@length - @large_profile_radius).round(3)}F#{@xy_feedrate}"

					#counter-clockwise circular interpolation feed to machine the large profile radius
					puts "G2X#{(@width + @tool_radius).round(3)}Y#{(@length - @large_profile_radius).round(3)}I#{(@large_profile_radius + @tool_radius).round(3)}J0.0F#{@xy_feedrate}"

					#linear interpolation feed to the starting position
					puts "G1X#{(@width + @tool_radius).round(3)}Y#{@small_profile_radius.round(3)}F#{@xy_feedrate}"

				end


	# One method to tie it all together and generate all the CNC code!

	def create_toolpaths

		self.create_hole_toolpath
		self.create_slot_toolpath
		self.create_outer_profile_toolpath

	end


end