var express = require('express'),
    app = express.createServer(),
    nowjs = require("now"),
    fs = require('fs');

//Car steering variables :)
var leftvotes=0,
    rightvotes=0,
    govotes=0;

var driversOnline=0;

app.use(express.logger()); //Add in logging (optional)
app.use("/css", express.static(__dirname + '/css'));
app.use("/js", express.static(__dirname + '/js'));

//Serve the interface for the car
app.get('/camera/', function(req, res){
	fs.readFile('./camera.html', function(error, content) {
        if (error) {
            res.writeHead(500);
            res.end();
        }
        else {
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(content, 'utf-8');
        }
    });
});

//Serve the car interface
app.get('/car/', function(req, res){
	fs.readFile('./index.html', function(error, content) {
        if (error) {
            res.writeHead(500);
            res.end();
        }
        else {
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(content, 'utf-8');
        }
    });
});


//TODO: This should never have to be coded but this is a temporary hack
function CheckNonNegativeSteerControls()
{
if(leftvotes<0)
	leftvotes=0;

if(rightvotes<0)
	rightvotes=0;

if(govotes<0)
	govotes=0;
}

//Here are the Now.js functions, doing the real-time magic
var everyone = nowjs.initialize(app, {socketio: {transports: ['xhr-polling', 'jsonp-polling']}});

//When a new client opens the website
nowjs.on('connect', function(){
	CheckNonNegativeSteerControls();
	driversOnline++;
    //console.log("Joined: " + this.now.name);
    var synchstring = "" + leftvotes +"," + rightvotes +"," + govotes + "," + driversOnline;
    this.now.receiveMessage(synchstring);
});

//When a client closes the web page 
//Note this function was not very reliable for me. -DG 07/10/12
nowjs.on('disconnect', function(){
	  driversOnline--;
	  if(driversOnline<0)
	      driversOnline=0
      console.log("Left: " + driversOnline);
});


//Define the function that sends messages from server to client
//(The client->server function is receiveMessage and written in index.html and camera.html)
everyone.now.distributeMessage = function(message){
  //The incoming message will be <DIRECTION>-<ON(1)/OFF(0)>
  var parts = message.split("-")

	if (parts[0] == "left"){
	  	if(parts[1]==1)
  	    leftvotes++;
	else
		leftvotes--;
	}
	else if (parts[0] == "right"){
	  	if(parts[1]==1)
  		    rightvotes++;
		else
			rightvotes--;
	}	
	
	else if (parts[0] == "go"){
  	if(parts[1]==1)
  	    govotes++;
	else
		govotes--;
	}
	
	else{ //Set bogus results in the case of a strange input
		console.log("Error: parts[0] =" + parts[0]);
		leftvotes=-1;
		rightvotes=-1;
		govotes=-1;
  	}

  var synchstring = "" + leftvotes +"," + rightvotes +"," + govotes + "," + driversOnline;
  CheckNonNegativeSteerControls()
  everyone.now.receiveMessage(synchstring);
};

everyone.now.ClearServerSideVariables = function(){
  driversOnline=0;
  leftvotes=0;
  rightvotes=0;
  govotes=0;

  var synchstring = "" + leftvotes +"," + rightvotes +"," + govotes + "," + driversOnline;
  everyone.now.receiveMessage(synchstring);
}

var port = process.env.PORT || 5000;
app.listen(port, function(){
console.log('Express server started on port %s', app.address().port);
});
