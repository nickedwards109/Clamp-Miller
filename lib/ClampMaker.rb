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


	# These methods generate CNC code according to the following conventions:
	#
	# '_as_an_increment' refers to a motion that is incremental from the start position.
	# All other motions are to a certain absolute position, regardless of the start position.
	#
	# "rapid_feed" refers to a motion where the cutting tool moves through air as fast as possible.
	# "cut" refers to a motion where the cutting tool cuts through material.
	# "rightward" refers to a motion in the +X direction.
	# "leftward" refers to a motion in the -X direction.
	# "forward" refers to a motion in the +Y direction.
	# "backward" refers to a motion in the -Y direction.
	# "up" refers to a motion in the +Z direction.
	# "down" refers to a motion in the -Z direction.


	def create_hole_toolpath

		remaining_Z_stock = @material_thickness

		until cutting_complete?(remaining_Z_stock)

			rapid_feed_up_one_safe_z_height_as_an_increment

			rapid_feed_to_xy_position_of_hole_center

			rapid_feed_down_then_cut_down_into_material_as_an_increment

			cut_rightward_to_prepare_for_making_hole_diameter

			cut_counter_clockwise_circle_to_make_hole_diameter

			remaining_Z_stock -= @axial_depth_of_cut

		end

		rapid_feed_to_z_zero

	end	


	def create_slot_toolpath
	
	remaining_Z_stock = @material_thickness

		until cutting_complete?(remaining_Z_stock)

			rapid_feed_up_one_safe_z_height_as_an_increment

			rapid_feed_to_xy_position_of_slot_top_center

			rapid_feed_down_then_cut_down_into_material_as_an_increment

			cut_backward_to_slot_bottom_center

			cut_rightward_to_right_edge_of_slot

			cut_forward_to_top_right_edge_of_slot

			cut_counter_clockwise_half_circle_to_make_slot_top_radius

			cut_backward_to_slot_bottom_center

			cut_counter_clockwise_half_circle_to_make_slot_bottom_radius

			remaining_Z_stock -= @axial_depth_of_cut

		end

		rapid_feed_to_z_zero

	end


	def create_outer_profile_toolpath

		rapid_feed_up_one_safe_z_height_as_an_increment

		rapid_feed_to_xy_position_at_rear_of_right_profile_edge

		rapid_feed_down_then_cut_down_into_material_as_an_increment

		cut_clockwise_quarter_circle_to_make_rear_right_profile_radius

		cut_leftward_to_make_rear_profile_edge

		cut_clockwise_quarter_circle_to_make_rear_left_profile_radius

		cut_forward_to_make_left_profile_edge

		cut_clockwise_half_circle_to_make_front_profile_radius

		cut_backward_to_rear_of_right_profile_edge
		
		remaining_Z_stock = @material_thickness - @axial_depth_of_cut

			#create multiple successive profile passes while incrementing the axial depth of cut
			until cutting_complete?(remaining_Z_stock)

				cut_down_into_material

				cut_clockwise_quarter_circle_to_make_rear_right_profile_radius

				cut_leftward_to_make_rear_profile_edge

				cut_clockwise_quarter_circle_to_make_rear_left_profile_radius

				cut_forward_to_make_left_profile_edge

				cut_clockwise_half_circle_to_make_front_profile_radius

				cut_backward_to_rear_of_right_profile_edge

				remaining_Z_stock -= @axial_depth_of_cut

			end

				rapid_feed_to_absolute_safe_z_height

				rapid_feed_to_xy_origin

				cut_to_z_zero

	end

	# Methods for generating modular snippets of CNC code

	def rapid_feed_up_one_safe_z_height_as_an_increment
		puts "G91"
		puts "G0Z#{safe_z_height}"
		puts "G90"
	end

	def rapid_feed_to_xy_position_of_hole_center
		puts "G0X#{x_position_of_hole_center}Y#{y_position_of_hole_center}"
	end

	def rapid_feed_down_then_cut_down_into_material_as_an_increment
		puts "G91"
		puts "G0Z-#{safe_z_height_less_one_radius}"
		puts "G1Z-#{axial_depth_of_cut_plus_one_radius}F#{z_feedrate}"
		puts "G90"
	end

	def cut_rightward_to_prepare_for_making_hole_diameter
		puts "G1X#{x_position_at_hole_diameter}Y#{y_position_at_hole_diameter}F#{xy_feedrate}"
	end

	def cut_counter_clockwise_circle_to_make_hole_diameter
		puts "G3X#{x_position_at_hole_diameter}Y#{y_position_at_hole_diameter}I#{i_offset_for_hole_radius}J#{j_offset_for_hole_radius}F#{xy_feedrate}"
	end

	def rapid_feed_to_z_zero
		puts "G0Z0.0"
	end

	def rapid_feed_to_xy_position_of_slot_top_center
		puts "G0X#{x_position_of_slot_center}Y#{y_position_of_slot_top_center}"
	end

	def cut_backward_to_slot_bottom_center
		puts "G1Y#{y_position_of_slot_bottom_center}F#{xy_feedrate}"
	end

	def cut_rightward_to_right_edge_of_slot
		puts "G1X#{x_position_at_right_slot_edge}F#{xy_feedrate}"
	end

	def cut_forward_to_top_right_edge_of_slot
		puts "G1Y#{y_position_of_slot_top_center}F#{xy_feedrate}"
	end

	def cut_counter_clockwise_half_circle_to_make_slot_top_radius
		puts "G3X#{x_position_at_left_slot_edge}I-#{i_offset_for_slot_end_radius}J#{j_offset_for_slot_end_radius}F#{xy_feedrate}"
	end

	def cut_counter_clockwise_half_circle_to_make_slot_bottom_radius
		puts "G3X#{x_position_at_right_slot_edge}I#{i_offset_for_slot_end_radius}J#{j_offset_for_slot_end_radius}F#{xy_feedrate}"
	end

	def rapid_feed_to_xy_position_at_rear_of_right_profile_edge
		puts "G0X#{x_position_for_starting_outside_profile_cut}Y#{y_position_for_starting_outside_profile_cut}"
	end

	def cut_clockwise_quarter_circle_to_make_rear_right_profile_radius
		puts "G2X#{x_position_at_bottom_of_lower_right_profile_radius}Y-#{y_position_at_bottom_of_lower_right_profile_radius}I-#{i_offset_for_lower_right_profile_radius}J#{j_offset_for_lower_right_profile_radius}F#{xy_feedrate}"
	end

	def cut_leftward_to_make_rear_profile_edge
		puts "G1X#{x_position_at_bottom_of_lower_left_profile_radius}F#{xy_feedrate}"
	end

	def cut_clockwise_quarter_circle_to_make_rear_left_profile_radius
		puts "G2X-#{x_position_at_top_of_lower_left_profile_radius}Y#{y_position_at_top_of_lower_left_profile_radius}I#{i_offset_for_lower_left_profile_radius}J#{j_offset_for_lower_left_profile_radius}F#{xy_feedrate}"
	end

	def cut_forward_to_make_left_profile_edge
		puts "G1Y#{y_position_at_bottom_of_top_profile_radius}F#{xy_feedrate}"
	end

	def cut_clockwise_half_circle_to_make_front_profile_radius
		puts "G2X#{x_position_at_right_side_of_top_profile_radius}Y#{y_position_at_bottom_of_top_profile_radius}I#{i_offset_for_top_profile_radius}J0.0F#{xy_feedrate}"	
	end

	def cut_backward_to_rear_of_right_profile_edge
		puts "G1X#{x_position_for_starting_outside_profile_cut}Y#{y_position_for_starting_outside_profile_cut}F#{xy_feedrate}"
	end

	def cut_down_into_material
		puts "G91"
		puts "G1Z-#{(@axial_depth_of_cut).round(3)}F#{z_feedrate}"
		puts "G90"
	end

	def rapid_feed_to_absolute_safe_z_height
		puts "G0Z#{@safe_z_height}"
	end

	def rapid_feed_to_xy_origin
		puts "G0X0.0Y0.0"
	end

	def cut_to_z_zero
		puts "G1Z0.0"
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

	# A method for determining whether the entire material thickness has been cut through
	def cutting_complete?(remaining_Z_stock)
		true if (remaining_Z_stock + 1.1*@tool_radius) < 0
	end

end