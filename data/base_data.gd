extends Resource
class_name BaseData

func from_dictionary(_data:Dictionary):
	pass
	
func to_dictionary() -> Dictionary :
	return {}

func to_bytes() -> PoolByteArray:
	return var2bytes(to_dictionary())
	
func from_bytes(bytes :PoolByteArray):
	from_dictionary(bytes2var(bytes))
