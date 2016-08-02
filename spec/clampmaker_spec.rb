require '../lib/ClampMaker.rb'
require './spec_helper.rb'

RSpec.describe ClampMaker do 

  context "length: 3.0, width: 1.5, material_thickness: 0.5, xy_feedrate: 15.0, z_feedrate: 10.0, axial_depth_of_cut: 0.15" do
    let(:clampmaker) { ClampMaker.new(3.0, 1.5, 0.5, 15.0, 10.0, 0.15) }

      # In this context, CNC code for a proper hole XY profile has the following properties:
      # The hole is machined with two passes, starting with the cutting tool centered initially at X=0.813 and subsequently at X=0.85
      # The hole is centered at a Y location of Y=2.25
      # The hole is centered at an X location of X=0.75, implied by the X positions plus the I offset values
      it "generates CNC code for machining a proper hole XY profile" do
        expect {clampmaker.create_XY_hole_profile_toolpath}.to output(/G1X0.85Y2.25F15.0\nG3X0.85Y2.25I-0.1J0.0F15.0\n/).to_stdout
      end
      
  end

end