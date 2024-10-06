## [Async] や [AsyncSequence] にキャンセルが要求されたことを伝えるためのクラスです。
class_name Cancel extends RefCounted

#-------------------------------------------------------------------------------
# シグナル
#-------------------------------------------------------------------------------

## [b](アドオン内もしくは実装内でのみ使用)[/b] キャンセルされたとき発火するシグナル。[br]
## [br]
## このシグナルはアドオン外からの利用を想定していません。[br]
## デッドロックしてしまったり、[RefCounted] の寿命を跨いでしまったり、[br]
## 安全ではないため [Async] の実装内でのみ使用するようにしてください。[br]
## [br]
## Usage:
##     [codeblock]
##     var cancel: Cancel = ...
##     if not cancel.is_requested: # 必ずチェックすること
##         await cancel.requested
##     [/codeblock]
signal requested

#-------------------------------------------------------------------------------
# プロパティ
#-------------------------------------------------------------------------------

## キャンセルが要求されているかを返します。
var is_requested: bool:
	get: return _is_requested

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## タイムアウトするとキャンセルが要求されるキャンセルを作成します。
static func timeout(timeout_: float) -> Cancel:
	var cancel := new()
	NesinkronaAsyncBase \
		.get_tree() \
		.create_timer(timeout_) \
		.timeout \
		.connect(cancel.request)
	return cancel

## キャンセルされた状態のキャンセルを作成します。
static func canceled() -> Cancel:
	if _canceled == null:
		_canceled = new()
		_canceled.request()
	return _canceled

## キャンセルを要求します。
func request() -> void:
	if not _is_requested:
		_is_requested = true
		requested.emit()

#-------------------------------------------------------------------------------

static var _canceled: Cancel

var _is_requested := false
