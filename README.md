This guide assumes that you have basic technical experience in setting up a CNC router and running a CNC program. If that doesn't describe you, please consider finding a makerspace that has a CNC router and a community where you can learn!

Clamp-Miller is a CNC programming utility that creates a CNC program which can be used to machine a clamp for milling workholding applications.

Here's how you can run the application and generate a CNC program:
  - Install Ruby 2.x and Rack 2.x on your local machine
  - Clone the application source code to your machine
  - In a terminal, navigate to the ./web directory
  - Run `$ ruby server.rb`
  - In a browser, navigate to localhost:8080
  - Fill out the form and submit it!
  - If you want to preview the toolpath, copy the G-code program and paste it into the simulator at [Q'n'dirty toolpath simulator](https://nraynaud.github.io/webgcode/)

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

Contributors are welcome! To contribute to this code base, please create a pull request to https://github.com/nickedwards109/Clamp-Miller
