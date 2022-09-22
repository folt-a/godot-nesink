extends Node

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

func create_timer(timeout: float) -> SceneTreeTimer:
	return _tree.create_timer(timeout)

func create_completed(result = null) -> Async:
	return \
		_completed_async \
		if result == null else \
		NesinkronaCompletedAsync.new(result)
		
	return _completed_async

func create_canceled() -> Async:
	return _canceled_async

#-------------------------------------------------------------------------------

@onready
var _tree := get_tree()
var _completed_async := NesinkronaCompletedAsync.new(null)
var _canceled_async := NesinkronaCanceledAsync.new()
