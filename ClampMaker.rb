class ClampMaker



	def initialize(length, width, material_thickness, hole_diameter, slot_to_hole_distance, slot_width, slot_to_end_of_clamp_distance, tool_radius, xy_feedrate, z_feedrate, axial_depth_of_cut, safe_z_height)
		
		@length = length
		@width = width
		@material_thickness = material_thickness
		@hole_diameter = hole_diameter
		@slot_to_hole_distance = slot_to_hole_distance
		@slot_width = slot_width
		@slot_to_end_of_clamp_distance = slot_to_end_of_clamp_distance
		@tool_radius = tool_radius
		@xy_feedrate = xy_feedrate
		@z_feedrate = z_feedrate
		@axial_depth_of_cut = axial_depth_of_cut
		@safe_z_height = safe_z_height

		@large_profile_radius = width/2
		@small_profile_radius = width/4
		@half_width = width/2

	end



	def create_toolpaths

		self.create_hole_toolpath
		self.create_slot_toolpath
		self.create_outer_profile_toolpath

	end



		def create_hole_toolpath
			
			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

			#define a counting variable
			i = 1

				#create multiple successive profile passes while incrementing the axial depth of cut
				while (remaining_Z_stock + @tool_radius) > 0

					#rapid feed up in Z by one safe Z height amount to prepare for XY motion
					puts "G91"
					puts "G0Z#{@safe_z_height.round(3)}"
					puts "G90"

					#rapid feed to the XY location of the hole
					puts "G0X#{@large_profile_radius.round(3)}Y#{(@length - @large_profile_radius).round(3)}"

					#rapid feed/plunge to one tool radius above the machined material
					puts "G0Z#{(@tool_radius - (i - 1)*@axial_depth_of_cut).round(3)}"

					#feed/plunge down in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G1Z-#{(@axial_depth_of_cut + @tool_radius).round(3)}F#{@z_feedrate}"
					puts "G90"

					#create an XY toolpath for machining the outside profile
					self.create_XY_hole_profile_toolpath

					#there is now one axial depth of cut less of material
					remaining_Z_stock = remaining_Z_stock - @axial_depth_of_cut

					i = i + 1

				end

		end

				def create_XY_hole_profile_toolpath

					#The tool is plunged into the material by one axial depth of cut. 
					#the tool has not yet made any other circular passes to machine the hole's inner profile. 

					#set a variable to represent remaining inner profile hole stock in the XY plane (as a diameter)
					remaining_XY_hole_stock = @hole_diameter - 2*@tool_radius

					#define a counting variable
					i = 1

					#rough out the hole diameter until there is less than one tool radius of stock remaining on each opposing side
					while (remaining_XY_hole_stock/2) > @tool_radius

						#feed into the material in the +X direction by an amount of one tool radius in order to prepare for a circular pass
						puts "G1X#{(@large_profile_radius + i*@tool_radius).round(3)}F#{@xy_feedrate}"

						#make a single climb milling circular pass. the final XY values are equivalent to the XY values before the G3 command, creating a complete circle centered about X = @large_profile_radius and Y = length - @large_profile_radius
						puts "G3X#{(@large_profile_radius + i*@tool_radius).round(3)}Y#{(@length - @large_profile_radius).round(3)}I-#{i*@tool_radius.round(3)}J0.0F#{@xy_feedrate}"

						remaining_XY_hole_stock = remaining_XY_hole_stock - 2*@tool_radius

						i = i + 1

					end

					#move to furthest X position in the hole to prepare for machining the final diameter of the hole
					puts "G1X#{(@large_profile_radius - 0.5*@hole_diameter + @tool_radius).round(3)}F#{@xy_feedrate}"

					#create the final pass to machine the final the diameter of the hole
					puts "G3X#{(@large_profile_radius - 0.5*@hole_diameter + @tool_radius).round(3)}Y#{(@length - @large_profile_radius).round(3)}I#{(0.5*@hole_diameter - @tool_radius).round(3)}J0.0F#{@xy_feedrate}"

				end



		def create_slot_toolpath

			#rapid feed to the safe z height to prepare for XY motion
			puts "G0Z#{@safe_z_height.round(3)}"
			
			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

			#define a counting variable
			i = 1

				#create multiple successive profile passes while incrementing the axial depth of cut
				while (remaining_Z_stock + @tool_radius) > 0

					#rapid feed up in Z by one safe Z height amount to prepare for XY motion
					puts "G91"
					puts "G0Z#{@safe_z_height.round(3)}"
					puts "G90"

					#rapid feed to the XY coordinates at the radius center at the slot top
					puts "G0X#{@half_width.round(3)}Y#{(@length - @large_profile_radius - @slot_to_hole_distance).round(3)}"

					#rapid feed/plunge to one tool radius above the machined material
					puts "G0Z#{(@tool_radius - (i - 1)*@axial_depth_of_cut).round(3)}"

					#feed/plunge down in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G1Z-#{(@axial_depth_of_cut + @tool_radius).round(3)}F#{@z_feedrate}"
					puts "G90"

					#create an XY toolpath for machining the outside profile
					self.create_XY_slot_profile_toolpath

					remaining_Z_stock = remaining_Z_stock - @axial_depth_of_cut

					i = i + 1

				end

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
						puts "G1X#{(@half_width + i*@tool_radius).round(3)}F#{@xy_feedrate}F#{@xy_feedrate}"

						#make a linear interpolation climb milling pass in the +Y direction
						puts "G1Y#{(@length - @large_profile_radius - @slot_to_hole_distance).round(3)}F#{@xy_feedrate}"

						#make a counter-clockwise circular interpolation pass about the top radius of the slot
						puts "G3X#{(@half_width - i*@tool_radius).round(3)}I-#{(i*@tool_radius).round(3)}J0.0F#{@xy_feedrate}"

						#make a linear interpolation climb milling pass in the -Y direction
						puts "G1Y#{@slot_to_end_of_clamp_distance.round(3)}F#{@xy_feedrate}"

						#make a counter-clockwise circular interpolation pass about the bottom radius of the slot
						puts "G3X#{(@half_width + i*@tool_radius).round(3)}I#{(i*@tool_radius).round(3)}F#{@xy_feedrate}" 

						remaining_XY_slot_stock = remaining_XY_slot_stock - 2*@tool_radius

						i = i + 1

					end

					#puts "(TEST: The final XY pass in create_XY_slot_profile_toolpath is starting)"

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
					puts "G3X#{(@half_width + @slot_width/2 - @tool_radius).round(3)}I#{(@slot_width/2 - @tool_radius).round(3)}F#{@xy_feedrate}" 
				end




		def create_outer_profile_toolpath

			#rapid feed to the safe z height to prepare for XY motion
			puts "G0Z#{@safe_z_height.round(3)}"

			#rapid feed to the XY coordinates for a Z plunge at the top of the lower right radius of the clamp
			puts "G0X#{(@width + @tool_radius).round(3)}Y#{@small_profile_radius.round(3)}"

			#rapid feed/plunge to one tool radius above Z=0
			puts "G0Z#{@tool_radius}"
			
			#specify a variable to store the amount of material that is not yet machined
			remaining_Z_stock = @material_thickness

				#create multiple successive profile passes while incrementing the axial depth of cut
				while (remaining_Z_stock + @tool_radius) > 0

					#feed/plunge down in Z by an increment of one axial depth of cut
					puts "G91"
					puts "G1Z-#{@axial_depth_of_cut.round(3)}F#{@z_feedrate}"
					puts "G90"

					#create an XY toolpath for machining the outside profile
					self.create_XY_outer_profile_toolpath

					remaining_Z_stock = remaining_Z_stock - @axial_depth_of_cut

				end

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


end