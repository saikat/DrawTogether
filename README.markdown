Introduction
============

This application makes use of [Socket.IO](http://github.com/RosePad/Socket.IO) and [Cappuccino](http://github.com/280north/cappuccino) to create a sample collaborative drawing app.  Multiple users can draw rectangles and circles and all other users using the app see the changes.  Socket.IO automatically allows the application to use WebSockets when it can, falling back to other Comet methods for other browsers.  To read more about Socket.IO, check out the [client](http://github.com/rosepad/socket.io) and [server](http://github.com/rosepad/socket.io-node).

Requirements
============

To run this example, you need to install [Socket.IO-node](http://github.com/rosepad/socket.io-node), which depends on [Node.js](http://github.com/ry/node).  Socket.IO-node currently requires you to patch your Node installation - this should hopefully go away in the future.

Instructions to Run
===================

After installing Socket.IO-node, cd into your DrawTogether directory and run "sudo node server.js".  Then, in different browsers, go to http://localhost:8080/client/index.html.  Draw a rectangle by clicking and dragging your mouse anywhere.  To change to drawing circles, press "c" (and press "r" to go back to rectangles).  Click and drag shapes to move them and double-click shapes to delete them.