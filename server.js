var http = require('http'), 
    url = require('url'),
    fs = require('fs'),
    io = require('./lib/socket.io'),
    sys = require('sys'),
    paperboy = require('./lib/paperboy/paperboy'),
    
    send404 = function(res){
	res.writeHead(404);
	res.write('404');
	res.close();
    },

    /* This is copied exactly from the examply in node-paperboy - http://github.com/felixge/node-paperboy */
    server = http.createServer(function(req, res) {
	var ip = req.connection.remoteAddress;
	paperboy
	.deliver(__dirname, req, res)
	.addHeader('Expires', 300)
	.addHeader('X-PaperRoute', 'Node')
	.before(function() {
	    sys.log('Recieved Request')
	})
	.after(function(statCode) {
	    res.write('Delivered: '+req.url);
	    log(statCode, req.url, ip);
	})
	.error(function(statCode,msg) {
	    res.writeHead(statCode, {'Content-Type': 'text/plain'});
	    res.write("Error: " + statCode);
	    res.close();
	    log(statCode, req.url, ip, msg);
	})
	.otherwise(function(err) {
	    var statCode = 404;
	    res.writeHead(statCode, {'Content-Type': 'text/plain'});
	    log(statCode, req.url, ip, err);
	});
    });
    server.listen(8080);

    function log(statCode, url, ip,err) {
	var logStr = statCode + ' - ' + url + ' - ' + ip
	if (err)
	    logStr += ' - ' + err;
	sys.log(logStr);
    }
    /* End paperboy example */
    
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