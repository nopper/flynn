Flynn
=====

Flynn is a simple CPU monitor for your Mac OS system that uses Flynn Taggart face to represent the CPU usage of your system. A bloody face in your Dock indicates that your system is doing something computational intensive :)

Flynn takes inspiration from [GkrellmFlynn](http://bax.comlab.uni-rostock.de/en/projekte/gkrellflynn.html) software.

![Flynn](http://i.imgur.com/a3RnDdy.png "Flynn")

Download
========

Use the download page of GitHub to download the latest version.

How to build
============

Assuming you have Xcode installed, the following command should do the work:

    $ xcodebuild -configuration Release

At this point you should find in `build/` directory your `Flynn.app`.

Author
======

The project is developed by me, Francesco Piccinno (stack.box@gmail.com). It's my first attempt to create an Objective-C application so probably there's something wrong in the code. If this is the case send me a pull request I will be glad to include your fixes/contributions in the project.

License
=======

The code is released under BSD license.
