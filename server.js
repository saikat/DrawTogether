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
    
    var json = JSON.stringify;

    var listener = io.listen(server, {	
	onClientDisconnect: function(client)
	{
	},
	
	onClientMessage: function(message, client)
	{
	    client.broadcast(message);
	}
    });

    listener.addListener('clientConnect', function(client)
			 {
			     // This code to sync up clients when a new client connects clearly
			     // doesn't actually work that well.  I need to deal with client
			     // synchronization and merging - this is the hard part =)
			     if (this.clients.length > 0)
			     {
				 var count = this.clients.length;
				 while (count--)
				 {
				     if (this.clients[count] != null && this.clients[count] != client)
				     {
					 this.clients[count].send(json({ action: 'fetch' }));
					 return;
				     }
				 }
			     }
			 });
    listener.options.transports = ['websocket', 'server-events', 'htmlfile', 'xhr-multipart', 'xhr-polling'];