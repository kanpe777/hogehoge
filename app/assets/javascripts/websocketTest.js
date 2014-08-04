$(function() {
  if ($('h1')[0].innerHTML != "Welcome") { return; }
  var host = "localhost"
  var port = "3001"
  var ws = new WebSocket("ws://" + host + ":" + port);
  ws.onopen    = function()    { console.log(host + ":" + port + " open!!"); };
  ws.onclose   = function()    { console.log(host + ":" + port + " close orz"); };
  ws.onmessage = function(evt) { console.log("何かしらのメッセージが届きました"); };
});
