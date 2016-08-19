require '../lib/ClampMaker.rb'
require './spec_helper.rb'

RSpec.describe ClampMaker do 

  # Tests for methods that generate CNC code which cuts in the XY plane
  context "length: 3.0, width: 1.5, material_thickness: 0.5, xy_feedrate: 15.0, z_feedrate: 10.0, axial_depth_of_cut: 0.15" do
    let(:clampmaker) { ClampMaker.new(3.0, 1.5, 0.5, 15.0, 10.0, 0.15) }

      it "generates CNC code for machining a proper hole XY profile" do
        expect {clampmaker.create_XY_hole_profile_toolpath}.to output(/
                                                                      G1X0.85Y2.25F15.0\n # Feed to the XY position for starting to cut the hole, at X0.85 and Y2.25
                                                                      G3X0.85Y2.25I-0.1J0.0F15.0\n  # Cut a circle centered at X0.75 and Y2.25, offset by -0.1 along X and 0.0 along Y
                                                                      /x).to_stdout
      end

      it "generates CNC code for machining a proper slot XY profile" do
        expect {clampmaker.create_XY_slot_profile_toolpath}.to output(/
                                                                      G1Y0.5F15.0\n  # Feed in the Y direction to the Y position at the lower end of the slot
                                                                      G1X0.788F15.0\n  # Feed in the X direction to the X position on the right edge of the slot
                                                                      G1Y1.75F15.0\n  # Feed in the Y direction to the Y position at the upper end of the slot
                                                                      G3X0.713I-0.038J0.0F15.0\n # Cut a half-circle, ending at the left edge of the slot, offset by -.038 along X and 0.0 along Y
                                                                      G1Y0.5F15.0\n  # Feed in the Y direction to the Y position at the lower end of the slot
                                                                      G3X0.788I0.038J0.0F15.0\n # Cut a half-circle, ending at the right edge of the slot, offset by .038 along X and 0.0 along Y
                                                                      /x).to_stdout
      end

      it "generates CNC code for machining a proper outer XY profile" do
        expect {clampmaker.create_XY_outer_profile_toolpath}.to output(/
                                                                      G2X1.125Y-0.063I-0.438J0.0F15.0\n  # Counter-clockwise circular interpolation feed to machine the lower right profile radius
                                                                      G1X0.375F15.0\n  # Feed to an X location of one small profile radius from the left side
                                                                      G2X-0.063Y0.375I0.0J0.438F15.0\n # Counter-clockwise circular interpolation feed to machine the lower left profile radius
                                                                      G1Y2.25F15.0\n # Feed to a Y location of the clamp length minus the large profile radius
                                                                      G2X1.563Y2.25I0.813J0.0F15.0\n # Counter-clockwise circular interpolation feed to machine the large profile radius
                                                                      G1X1.563Y0.375F15.0\n # Feed to the starting position
                                                                      /x).to_stdout
      end
      
  end

  # Tests for methods that generate CNC code which cuts all the way through the material in the Z axis.
  # These tests are facilitated by a relatively smaller material thickness and larger axial depth of cut...
  # ...which results in fewer cutting passes and less code in the RSpec matcher
  context "length: 3.0, width: 1.5, material_thickness: 0.25, xy_feedrate: 15.0, z_feedrate: 10.0, axial_depth_of_cut: 0.2" do
  let(:clampmaker) { ClampMaker.new(3.0, 1.5, 0.25, 15.0, 10.0, 0.2) }

    it "generates CNC code for machining a hole all the way through the material in the Z axis" do
      expect {clampmaker.create_hole_toolpath}.to output(/
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

    it "generates CNC code for machining a slot all the way through the material in the Z axis" do
      expect {clampmaker.create_slot_toolpath}.to output(/
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

    it "generates CNC code for machining the outer profile all the way through the material in the Z axis" do
      expect {clampmaker.create_outer_profile_toolpath}.to output(/
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