extends Node

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func create_timer(timeout: float) -> SceneTreeTimer:
	return _tree.create_timer(timeout)

func create_canceled() -> Async:
	return _canceled_async

#-------------------------------------------------------------------------------

@onready
var _tree := get_tree()
var _canceled_async := NesinkronaCanceledAsync.new()
