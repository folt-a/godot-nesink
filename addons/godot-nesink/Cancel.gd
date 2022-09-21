## キャンセルの単位です。
##
## [method Cancel.wait] によりキャンセルを要求します。
## [Async]、[AsyncSequence] に外部から中止を伝えるときに必要となるクラスです。
class_name Cancel

# (内部用) キャンセルされたとき発火するシグナル。
#
# このシグナルはアドオン外部からの利用を前提にしていません。
# デッドロックしてしまったり、[RefCounted] の寿命を跨いでしまったり、とにかく
# 安全ではないため [NesinkronaAwaitable] の実装内でのみ使用するようにしてください。
#
# Usage:
#     [codeblock]
#     var cancel: Cancel = ...
#     if not cancel.is_requested: # 必ずチェックすること
#         await cancel.requested
#     [/codeblock]
signal requested

## キャンセルが要求されているかを返します。
var is_requested: bool:
	get: return _is_requested

## キャンセルを要求します。
func request() -> void:
	if not _is_requested:
		_is_requested = true
		requested.emit()

#-------------------------------------------------------------------------------

var _is_requested := false
