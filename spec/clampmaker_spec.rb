require '../lib/ClampMaker.rb'
require './spec_helper.rb'

RSpec.describe ClampMaker do 

  # Tests for methods that generate CNC code which cuts in the XY plane
  context "length: 3.0, width: 1.5, material_thickness: 0.5, xy_feedrate: 15.0, z_feedrate: 10.0, axial_depth_of_cut: 0.15" do
    let(:clampmaker) { ClampMaker.new(3.0, 1.5, 0.5, 15.0, 10.0, 0.15) }

      # In this context, CNC code for a proper hole XY profile has the following properties:
      # The hole is machined with two passes, starting with the cutting tool centered initially at X=0.813 and subsequently at X=0.85
      # The hole is centered at a Y location of Y=2.25
      # The hole is centered at an X location of X=0.75, implied by the X positions plus the I offset values
      it "generates CNC code for machining a proper hole XY profile" do
        expect {clampmaker.create_XY_hole_profile_toolpath}.to output(/
                                                                      G1X0.85Y2.25F15.0\n # Feed to the X position for cutting the XY hole profile
                                                                      G3X0.85Y2.25I-0.1J0.0F15.0\n  # Cut a circle offset by -0.1 along X and 0.0 along Y
                                                                      /x).to_stdout
      end
      
  end

  # Tests for methods that generate CNC code which cuts all the way through the material in the Z axis.
  # These tests are facilitated by a relatively smaller material thickness and larger axial depth of cut...
  # ...which results in fewer cutting passes and less code in the RSpec matcher
  context "length: 3.0, width: 1.5, material_thickness: 0.25, xy_feedrate: 15.0, z_feedrate: 10.0, axial_depth_of_cut: 0.2" do
  let(:clampmaker) { ClampMaker.new(3.0, 1.5, 0.25, 15.0, 10.0, 0.2) }

    # This test uses x at the end of the regexp to ignore whitespace and comments...
    # ...which allows the matcher to be broken up over many lines, improving readability.
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
      
  end

end