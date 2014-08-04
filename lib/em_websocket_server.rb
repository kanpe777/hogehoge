require 'em-websocket'
require 'json'

connections = Hash.new(Array.new)

EventMachine::WebSocket.start(host: "localhost", port: 3001) do |ws|
  ws.onopen { puts "Open!!" }

  ws.onclose { puts "closing..." }

  ws.onmessage do |msg|
    parsed_msg = JSON.parse(msg)
    parsed_msg["body"].gsub!(/\r\n|\r|\n/, "<br />")
    room_id    = parsed_msg["room_id"]
    parsed_msg["date"] = Time.now.utc.localtime("+09:00")
    key = "room_" + room_id.to_s
    unless connections[key].include?(ws)
      connections[key].push(ws)
    end
    connections[key].each do |con|
      con.send(parsed_msg.to_json)
    end
  end
end
