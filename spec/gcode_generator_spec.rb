require '../lib/GCodeGenerator.rb'
require './spec_helper.rb'

RSpec.describe GCodeGenerator do

  # Specs for the three methods that generate all of the CNC code for making a clamp.
  # These specs are facilitated by a small material thickness and large axial depth of cut...
  # ...which results in fewer cutting passes and less code in the RSpec matcher
  context "length: 3.0, width: 1.5, material_thickness: 0.25, xy_feedrate: 15.0, z_feedrate: 10.0, axial_depth_of_cut: 0.2" do
  let(:gcode_generator) { ToolpathProgrammer.new(3.0, 1.5, 0.25, 15.0, 10.0, 0.2) }

    it "generates CNC code for machining the clamp's hole" do
      expect {gcode_generator.create_hole_toolpath}.to output(/
                                                        \(.+\)\n # Comment in the CNC code. Parentheses followed by one or more of anything followed by parentheses
                                                        # First cutting pass
                                                        G91\n  # Set incremental mode
                                                        G0Z0.125\n  # Rapid feed up in Z by one tool diameter
                                                        G90\n  # Set absolute mode
                                                        G0X0.75Y2.25\n   # Rapid feed to the XY position of the hole center
                                                        G91\n  # Set incremental mode
                                                        G0Z-0.063\n  # Rapid feed to one tool radius above the material
                                                        G1Z-0.263F10.0\n # Feed one depth of cut into the material
                                                        G90\n  # Set absolute mode
                                                        G1X0.85Y2.25F15.0\n  # Feed to the X position for cutting the XY hole profile
                                                        G3X0.85Y2.25I-0.1J0.0F15.0\n  # Cut a circle offset by -0.1 along X and 0.0 along Y
                                                        # Second cutting pass
                                                        G91\n  # Set incremental mode
                                                        G0Z0.125\n  # Rapid feed up in Z by one tool diameter
                                                        G90\n  # Set absolute mode
                                                        G0X0.75Y2.25\n   # Rapid feed to the XY position of the hole center
                                                        G91\n  # Set incremental mode
                                                        G0Z-0.063\n  # Rapid feed to one tool radius above the material
                                                        G1Z-0.263F10.0\n # Feed one depth of cut into the material
                                                        G90\n  # Set absolute mode
                                                        G1X0.85Y2.25F15.0\n  # Feed to the X position for cutting the XY hole profile
                                                        G3X0.85Y2.25I-0.1J0.0F15.0\n  # Cut a circle offset by -0.1 along X and 0.0 along Y
                                                        G0Z0.0\n  # Return to the surface of the material
                                                        /x).to_stdout
    end

    it "generates CNC code for machining the clamp's slot" do
      expect {gcode_generator.create_slot_toolpath}.to output(/
                                                        \(.+\)\n # Comment in the CNC code. Parentheses followed by one or more of anything followed by parentheses
                                                        # First cutting pass
                                                        G91\n  # Set incremental mode
                                                        G0Z0.125\n  # Rapid feed up in Z by one tool diameter
                                                        G90\n  # Set absolute mode
                                                        G0X0.75Y1.75\n  # Rapid feed to the XY position of the slot end diameter center
                                                        G91\n  # Set incremental mode
                                                        G0Z-0.063\n  # Rapid feed to one tool radius above the material
                                                        G1Z-0.263F10.0\n  # Feed one depth of cut into the material
                                                        G90\n  # Set absolute mode
                                                        G1Y0.5F15.0\n  # Feed through the X middle of the slot to the Y position at the lower end of the slot
                                                        G1X0.788F15.0\n  # Feed to the X position where the edge of the tool is at the right edge of the slot
                                                        G1Y1.75F15.0\n  # Feed along the right edge of the slot to the Y position at the upper end of the slot
                                                        G3X0.713I-0.038J0.0F15.0\n  # Make a counter-clockwise circular interpolation pass about the upper radius of the slot
                                                        G1Y0.5F15.0\n  # Feed along the left edge of the slot to the Y position at the lower end of the slot
                                                        G3X0.788I0.038J0.0F15.0\n  # Make a counter-clockwise circular interpolation pass about the lower radius of the slot
                                                        # Second cutting pass
                                                        G91\n  # Set incremental mode
                                                        G0Z0.125\n  # Rapid feed up in Z by one tool diameter
                                                        G90\n  # Set absolute mode
                                                        G0X0.75Y1.75\n  # Rapid feed to the XY position of the slot end diameter center
                                                        G91\n  # Set incremental mode
                                                        G0Z-0.063\n  # Rapid feed to one tool radius above the material
                                                        G1Z-0.263F10.0\n  # Feed one depth of cut into the material
                                                        G90\n  # Set absolute mode
                                                        G1Y0.5F15.0\n  # Feed through the X middle of the slot to the Y position at the lower end of the slot
                                                        G1X0.788F15.0\n  # Feed to the X position where the edge of the tool is at the right edge of the slot
                                                        G1Y1.75F15.0\n  # Feed along the right edge of the slot to the Y position at the upper end of the slot
                                                        G3X0.713I-0.038J0.0F15.0\n  # Make a counter-clockwise circular interpolation pass about the upper radius of the slot
                                                        G1Y0.5F15.0\n  # Feed along the left edge of the slot to the Y position at the lower end of the slot
                                                        G3X0.788I0.038J0.0F15.0\n  # Make a counter-clockwise circular interpolation pass about the lower radius of the slot
                                                        G0Z0.0\n  # Return to Z zero
                                                        /x).to_stdout
    end

    it "generates CNC code for machining the clamp's outer profile" do
      expect {gcode_generator.create_outer_profile_toolpath}.to output(/
                                                                 \(.+\)\n # Comment in the CNC code. Parentheses followed by one or more of anything followed by parentheses
                                                                 # First cutting pass
                                                                 G91\n  # Set incremental mode
                                                                 G0Z0.125\n  # Rapid feed up in Z by one tool diameter
                                                                 G90\n  # Set absolute mode
                                                                 G0X1.563Y0.375\n  # Rapid feed to the XY coordinates for a Z plunge at the top of the lower right radius of the clamp
                                                                 G91\n  # Set incremental mode
                                                                 G0Z-0.063\n  # Rapid feed to one tool radius above the material
                                                                 G1Z-0.263F10.0\n  # Feed one depth of cut into the material
                                                                 G90\n  # Set absolute mode
                                                                 G2X1.125Y-0.063I-0.438J0.0F15.0\n  # Counter-clockwise circular interpolation feed to machine the lower right profile radius
                                                                 G1X0.375F15.0\n  # Feed to an X location of one small profile radius from the left side
                                                                 G2X-0.063Y0.375I0.0J0.438F15.0\n # Counter-clockwise circular interpolation feed to machine the lower left profile radius
                                                                 G1Y2.25F15.0\n # Feed to a Y location of the clamp length minus the large profile radius
                                                                 G2X1.563Y2.25I0.813J0.0F15.0\n # Counter-clockwise circular interpolation feed to machine the large profile radius
                                                                 G1X1.563Y0.375F15.0\n # Feed to the starting position
                                                                 # Second cutting pass. Since the cutting tool ended its last motion at the start position...
                                                                 # ...it can immediately feed one axial depth of cut into the material, without first approaching from a safe Z position.
                                                                 G91\n  # Set incremental mode
                                                                 G1Z-0.2F10.0\n  # Feed one depth of cut into the material
                                                                 G90\n  # Set absolute mode
                                                                 G2X1.125Y-0.063I-0.438J0.0F15.0\n  # Counter-clockwise circular interpolation feed to machine the lower right profile radius
                                                                 G1X0.375F15.0\n  # Feed to an X location of one small profile radius from the left side
                                                                 G2X-0.063Y0.375I0.0J0.438F15.0\n # Counter-clockwise circular interpolation feed to machine the lower left profile radius
                                                                 G1Y2.25F15.0\n # Feed to a Y location of the clamp length minus the large profile radius
                                                                 G2X1.563Y2.25I0.813J0.0F15.0\n # Counter-clockwise circular interpolation feed to machine the large profile radius
                                                                 G1X1.563Y0.375F15.0\n # Feed to the starting position
                                                                 G0Z0.125\n  # Rapid feed to a safe Z position
                                                                 G0X0.0Y0.0\n  # Rapid feed to XY origin
                                                                 G1Z0.0\n  # Rapid feed to Z origin
                                                                 /x).to_stdout
    end

  end

end
