# Using the application

Clamp-Miller is a CNC programming utility that generates a CNC program for manufacturing custom clamps for a CNC router. It asks the user for a few mechanical parameters and then generates a CNC program consisting of G-Code. A CNC router can then run the CNC program to cut out the clamp from a piece of material stock.

You can go ahead and use the application at http://ec2-13-58-192-235.us-east-2.compute.amazonaws.com:1111/

# Setting up your CNC router
This guide assumes that you have basic technical experience in setting up a CNC router and running a CNC program. If that doesn't describe you, please consider finding a makerspace that has a CNC router and a community where you can learn!

Once you have generated a CNC program, consider whether your CNC machine manages spindle control manually or through G-code. The generated CNC program only controls feed motions and feedrate speeds. If the spindle on your CNC machine is managed by G-code, you will need add code at the beginning of the program to turn on the spindle with something like `S1000M03` and turn it off at the end of the program with `M05`.

You'll also need to set up the coordinate system on your milling machine before you can run the CNC program. Follow these set-up rules:
  - Use a 1/8" ball end mill as the cutting tool
  - Set X=0 and Y=0 on the lower left corner of the workpiece
  - Set Z=0 at the top of the workpiece
  - Ensure that no point on the top of the workpiece surface extends more than 1/8" above Z=0
  - When running the CNC program, start with the tool at X=0, Y=0, and Z=0

Here is an image of a setup for machining a clamp. The outer profile of the clamp is being machined, and the slot and height adjustment hole have already been machined. 3 smaller clamps on the right are fixturing the workpiece to the workholding table.

![Use Case](/img/Use-Case.png)

Once you have generated a CNC program and set up your CNC router, you can upload the CNC program to your CNC controller and run it. In my case, I uploaded it over a serial connection to an Arduino running [GRBL](https://github.com/grbl/grbl)

# Contributing

Contributors are welcome! To contribute to this code base, please create a pull request to https://github.com/nickedwards109/Clamp-Miller

First, you'll need to be able to run the application locally. To do this:
  - Install Ruby 2.x and Bundler 2.x on your local machine
  - Clone the application source code to your machine
  - In a terminal, navigate to the source code's root directory
  - Install dependencies by running `$ bundle install`
  - Navigate to the /web directory and start a local server by running `$ puma server.ru`
  - In a browser, navigate to localhost:9292
