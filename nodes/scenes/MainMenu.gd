extends CanvasLayer

@export var Address = "127.0.0.1"
@export var port = 8910
var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

# this get called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))
	$Loading/AnimationPlayer.stop()
	$Loading.text = "Connected"
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")
	
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	
# called only from clients
func connected_to_server():
	print("connected To Server!")
	SendPlayerInformation.rpc_id(1, $NameEdit.text, multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print("Couldnt Connect")

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name" : name,
			"id" : id,
			"house": 0,
			"holes": [1,6,1,1,1,1,5]
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			SendPlayerInformation.rpc(GameManager.players[i].name, i)

func loading_animation():
	$Loading.text = "loading..."
	$Loading.visible = true
	$Loading/AnimationPlayer.play("loading")
	pass

func _on_join_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "fill name"
		return
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	loading_animation()

func _on_host_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "fill name"
		return
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	SendPlayerInformation($NameEdit.text, multiplayer.get_unique_id())
	loading_animation()
