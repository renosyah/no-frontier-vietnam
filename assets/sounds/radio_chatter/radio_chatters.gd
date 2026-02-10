extends Node
class_name RadioChatters

signal on_radio_played(text)

const COMMAND_ACKNOWLEDGEMENT = 1
const AMBUSH_INITIATED = 2
const LOW_AMMO = 3
const AREA_CLEAR = 4
const CASUALTY = 5
const COMBAT_STATUS = 6
const ENEMY_SPOTTED = 7
const MOVEMENT = 8
const RETREAT = 9

onready var US_RADIO = {
	COMMAND_ACKNOWLEDGEMENT:{
		"Roger.":preload("res://assets/sounds/radio_chatter/us/COMMAND_ACKNOWLEDGEMENT/1.wav"),
		"Copy that.":preload("res://assets/sounds/radio_chatter/us/COMMAND_ACKNOWLEDGEMENT/2.wav"),
		"Wilco.":preload("res://assets/sounds/radio_chatter/us/COMMAND_ACKNOWLEDGEMENT/3.wav"),
		"Moving now.":preload("res://assets/sounds/radio_chatter/us/COMMAND_ACKNOWLEDGEMENT/4.wav"),
		"On the way.":preload("res://assets/sounds/radio_chatter/us/COMMAND_ACKNOWLEDGEMENT/5.wav"),
		"Orders received.":preload("res://assets/sounds/radio_chatter/us/COMMAND_ACKNOWLEDGEMENT/6.wav"),
	},
	AMBUSH_INITIATED:{
		"Targets in sight.":preload("res://assets/sounds/radio_chatter/us/AMBUSH_INITIATED/1.wav"),
		"Hold… hold…":preload("res://assets/sounds/radio_chatter/us/AMBUSH_INITIATED/2.wav"),
		"Spring the ambush!":preload("res://assets/sounds/radio_chatter/us/AMBUSH_INITIATED/3.wav"),
		"Engaging now!":preload("res://assets/sounds/radio_chatter/us/AMBUSH_INITIATED/4.wav"),
	},
	LOW_AMMO:{
		"Low on ammo!":preload("res://assets/sounds/radio_chatter/us/LOW_AMMO/1.wav"),
		"Running dry!":preload("res://assets/sounds/radio_chatter/us/LOW_AMMO/2.wav"),
		"We’re out!":preload("res://assets/sounds/radio_chatter/us/LOW_AMMO/3.wav"),
		"Need resupply!":preload("res://assets/sounds/radio_chatter/us/LOW_AMMO/4.wav"),
	},
	AREA_CLEAR:{
		"Area secure.":preload("res://assets/sounds/radio_chatter/us/AREA_CLEAR/1.wav"),
		"Targets down.":preload("res://assets/sounds/radio_chatter/us/AREA_CLEAR/2.wav"),
		"Clear.":preload("res://assets/sounds/radio_chatter/us/AREA_CLEAR/3.wav"),
		"We’re good here.":preload("res://assets/sounds/radio_chatter/us/AREA_CLEAR/4.wav"),
	},
	CASUALTY:{
		"Man down!":preload("res://assets/sounds/radio_chatter/us/CASUALTY/1.wav"),
		"We’ve got wounded!":preload("res://assets/sounds/radio_chatter/us/CASUALTY/2.wav"),
		"Need a medic!":preload("res://assets/sounds/radio_chatter/us/CASUALTY/3.wav"),
		"Taking losses!":preload("res://assets/sounds/radio_chatter/us/CASUALTY/4.wav"),
	},
	COMBAT_STATUS:{
		"Engaging.":preload("res://assets/sounds/radio_chatter/us/COMBAT_STATUS/1.wav"),
		"Suppressing!":preload("res://assets/sounds/radio_chatter/us/COMBAT_STATUS/2.wav"),
		"Reloading!":preload("res://assets/sounds/radio_chatter/us/COMBAT_STATUS/3.wav"),
		"We’re pinned!":preload("res://assets/sounds/radio_chatter/us/COMBAT_STATUS/4.wav"),
		"Pushing forward!":preload("res://assets/sounds/radio_chatter/us/COMBAT_STATUS/5.wav"),
	},
	ENEMY_SPOTTED:{
		"Contact!":preload("res://assets/sounds/radio_chatter/us/ENEMY_SPOTTED/1.wav"),
		"Enemy spotted.":preload("res://assets/sounds/radio_chatter/us/ENEMY_SPOTTED/2.wav"),
		"Eyes on target.":preload("res://assets/sounds/radio_chatter/us/ENEMY_SPOTTED/3.wav"),
		"Heavy contact!":preload("res://assets/sounds/radio_chatter/us/ENEMY_SPOTTED/4.wav"),
		"Taking fire!":preload("res://assets/sounds/radio_chatter/us/ENEMY_SPOTTED/5.wav"),
	},
	MOVEMENT:{
		"We’re moving.":preload("res://assets/sounds/radio_chatter/us/MOVEMENT/1.wav"),
		"Crossing now.":preload("res://assets/sounds/radio_chatter/us/MOVEMENT/2.wav"),
		"Entering the area.":preload("res://assets/sounds/radio_chatter/us/MOVEMENT/3.wav"),
		"Reached position.":preload("res://assets/sounds/radio_chatter/us/MOVEMENT/4.wav"),
		"Holding here.":preload("res://assets/sounds/radio_chatter/us/MOVEMENT/5.wav"),
	},
	RETREAT:{
		"Pull back!":preload("res://assets/sounds/radio_chatter/us/RETREAT/1.wav"),
		"Break contact!":preload("res://assets/sounds/radio_chatter/us/RETREAT/2.wav"),
		"Fall back!":preload("res://assets/sounds/radio_chatter/us/RETREAT/3.wav"),
		"Disengaging!":preload("res://assets/sounds/radio_chatter/us/RETREAT/4.wav"),
	},
}

onready var VIET_RADIO = {
	COMMAND_ACKNOWLEDGEMENT:{
		"Rõ.":preload("res://assets/sounds/radio_chatter/viet/COMMAND_ACKNOWLEDGEMENT/1.wav"),
		"Đã rõ.":preload("res://assets/sounds/radio_chatter/viet/COMMAND_ACKNOWLEDGEMENT/2.wav"),
		"Nhận lệnh.":preload("res://assets/sounds/radio_chatter/viet/COMMAND_ACKNOWLEDGEMENT/3.wav"),
		"Đang di chuyển.":preload("res://assets/sounds/radio_chatter/viet/COMMAND_ACKNOWLEDGEMENT/4.wav"),
		"Thi hành.":preload("res://assets/sounds/radio_chatter/viet/COMMAND_ACKNOWLEDGEMENT/5.wav"),
	},
	AMBUSH_INITIATED:{
		"Địch đã vào.":preload("res://assets/sounds/radio_chatter/viet/AMBUSH_INITIATED/1.wav"),
		"Chờ lệnh.":preload("res://assets/sounds/radio_chatter/viet/AMBUSH_INITIATED/2.wav"),
		"Nổ súng!":preload("res://assets/sounds/radio_chatter/viet/AMBUSH_INITIATED/3.wav"),
		"Tiêu diệt!":preload("res://assets/sounds/radio_chatter/viet/AMBUSH_INITIATED/4.wav"),
	},
	LOW_AMMO:{
		"Sắp hết đạn!":preload("res://assets/sounds/radio_chatter/viet/LOW_AMMO/1.wav"),
		"Thiếu đạn!":preload("res://assets/sounds/radio_chatter/viet/LOW_AMMO/2.wav"),
		"Hết đạn!":preload("res://assets/sounds/radio_chatter/viet/LOW_AMMO/3.wav"),
		"Cần tiếp tế!":preload("res://assets/sounds/radio_chatter/viet/LOW_AMMO/4.wav"),
	},
	AREA_CLEAR:{
		"Khu vực an toàn.":preload("res://assets/sounds/radio_chatter/viet/AREA_CLEAR/1.wav"),
		"Đã tiêu diệt.":preload("res://assets/sounds/radio_chatter/viet/AREA_CLEAR/2.wav"),
		"Sạch địch.":preload("res://assets/sounds/radio_chatter/viet/AREA_CLEAR/3.wav"),
		"Hoàn tất.":preload("res://assets/sounds/radio_chatter/viet/AREA_CLEAR/4.wav"),
	},
	CASUALTY:{
		"Có thương binh!":preload("res://assets/sounds/radio_chatter/viet/CASUALTY/1.wav"),
		"Có người bị thương!":preload("res://assets/sounds/radio_chatter/viet/CASUALTY/2.wav"),
		"Tổn thất!":preload("res://assets/sounds/radio_chatter/viet/CASUALTY/3.wav"),
		"Cần cứu thương!":preload("res://assets/sounds/radio_chatter/viet/CASUALTY/4.wav"),
	},
	COMBAT_STATUS:{
		"Đang giao chiến.":preload("res://assets/sounds/radio_chatter/viet/COMBAT_STATUS/1.wav"),
		"Bắn áp chế!":preload("res://assets/sounds/radio_chatter/viet/COMBAT_STATUS/2.wav"),
		"Nạp đạn!":preload("res://assets/sounds/radio_chatter/viet/COMBAT_STATUS/3.wav"),
		"Bị ghìm chặt!":preload("res://assets/sounds/radio_chatter/viet/COMBAT_STATUS/4.wav"),
		"Xung phong!":preload("res://assets/sounds/radio_chatter/viet/COMBAT_STATUS/5.wav"),
	},
	ENEMY_SPOTTED:{
		"Phát hiện địch!":preload("res://assets/sounds/radio_chatter/viet/ENEMY_SPOTTED/1.wav"),
		"Có địch!":preload("res://assets/sounds/radio_chatter/viet/ENEMY_SPOTTED/2.wav"),
		"Bị bắn!":preload("res://assets/sounds/radio_chatter/viet/ENEMY_SPOTTED/3.wav"),
		"Địch phía trước!":preload("res://assets/sounds/radio_chatter/viet/ENEMY_SPOTTED/4.wav"),
		"Giao tranh!":preload("res://assets/sounds/radio_chatter/viet/ENEMY_SPOTTED/5.wav"),
	},
	MOVEMENT:{
		"Đang tiến quân.":preload("res://assets/sounds/radio_chatter/viet/MOVEMENT/1.wav"),
		"Đã vào khu vực.":preload("res://assets/sounds/radio_chatter/viet/MOVEMENT/2.wav"),
		"Đến vị trí.":preload("res://assets/sounds/radio_chatter/viet/MOVEMENT/3.wav"),
		"Giữ vị trí.":preload("res://assets/sounds/radio_chatter/viet/MOVEMENT/4.wav"),
		"Dừng lại.":preload("res://assets/sounds/radio_chatter/viet/MOVEMENT/5.wav"),
	},
	RETREAT:{
		"Rút lui!":preload("res://assets/sounds/radio_chatter/viet/RETREAT/1.wav"),
		"Thoát ly!":preload("res://assets/sounds/radio_chatter/viet/RETREAT/2.wav"),
		"Rời khỏi giao tranh!":preload("res://assets/sounds/radio_chatter/viet/RETREAT/3.wav"),
		"Rút quân!":preload("res://assets/sounds/radio_chatter/viet/RETREAT/4.wav"),
	},
}

onready var queue_task = $queue_task
onready var speaker = $speaker
onready var static_ambient = $static_ambient
onready var delays = $delays

func play_radio(text :String, audio :Resource, clear:bool = false):
	if clear:
		queue_task.task_queue.clear()
		
	queue_task.add_task(self,"_play_radio",[text,audio])

func _play_radio(text :String, audio :Resource):
	emit_signal("on_radio_played", text)
	speaker.stream = audio
	static_ambient.play()
	delays.start()
	
	yield(delays,"timeout")
	speaker.play()
	
	yield(speaker,"finished")
	static_ambient.stop()






