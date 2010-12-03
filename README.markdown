Introduction
============

This application makes use of [Socket.IO](http://github.com/LearnBoost/Socket.IO) and [Cappuccino](http://github.com/280north/cappuccino) to create a sample collaborative drawing app.  Multiple users can draw rectangles and circles and all other users using the app see the changes.  Socket.IO automatically allows the application to use WebSockets when it can, falling back to other Comet methods for other browsers.  To read more about Socket.IO, check out the [client](http://github.com/LearnBoost/socket.io) and [server](http://github.com/LearnBoost/socket.io-node).  You can read more about it (and see a demo) [here](http://techblog.gomockingbird.com/socket-to-em).

Requirements
============

To run this example, you need to install [Node.js](http://github.com/ry/node).  Also, make sure you clone the DrawTogether repository with git clone --recursive to get the socket.io submodule.

Instructions to Run
===================

After installing Socket.IO-node, cd into your DrawTogether directory and run "sudo node server.js".  Then, in different browsers, go to http://localhost:8080/client/index.html.  Draw a rectangle by clicking and dragging your mouse anywhere.  To change to drawing circles, press "c" (and press "r" to go back to rectangles).  Click and drag shapes to move them and double-click shapes to delete them.