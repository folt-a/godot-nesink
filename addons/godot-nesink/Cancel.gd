## [Async] や [AsyncSequence] にキャンセルが要求されたことを伝えるためのクラスです。
class_name Cancel

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
	NesinkronaCanon.create_timer(timeout_).timeout.connect(cancel.request)
	return cancel

## キャンセルされた状態のキャンセルを作成します。
static func canceled() -> Cancel:
	return NesinkronaCanon.create_canceled_cancel()

## キャンセルを要求します。
func request() -> void:
	if not _is_requested:
		_is_requested = true
		requested.emit()

#-------------------------------------------------------------------------------

var _is_requested := false
