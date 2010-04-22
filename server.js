var http = require('http'), 
    url = require('url'),
    fs = require('fs'),
    io = require('./lib/socket.io'),
    sys = require('sys'),
    
    send404 = function(res){
	res.writeHead(404);
	res.write('404');
	res.close();
    },
    
    server = http.createServer(function(req, res){
	send404(res);
    });

    server.listen(8080);
    
    // socket.io, I choose you
    // simplest chat application evar
    var buffer = [], json = JSON.stringify;

    var listener = io.listen(server, {
	
	onClientConnect: function(client){
	    client.send(json({ buffer: buffer }));
	    client.broadcast(json({ announcement: client.sessionId + ' connected' }));
	},
	
	onClientDisconnect: function(client){
	    client.broadcast(json({ announcement: client.sessionId + ' disconnected' }));
	},
	
	onClientMessage: function(message, client){
	    client.broadcast(message);
	}
    });

    listener.options.transports = ['websocket', 'server-events', 'htmlfile', 'xhr-multipart', 'xhr-polling'];