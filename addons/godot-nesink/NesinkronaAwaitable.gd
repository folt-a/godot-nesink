## [b](アドオン内もしくは実装内でのみ使用)[/b]
## 待機可能な単位を表すインターフェイスです。
class_name NesinkronaAwaitable

#-------------------------------------------------------------------------------
# 定数
#-------------------------------------------------------------------------------

enum {
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## まだ完了もしくはキャンセルされておらず待機中であることを表します。
	STATE_PENDING,
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## まだ完了もしくはキャンセルされておらず待機中であり、
	## 1 度以上 [method wait] メソッドにより待機している箇所があることを表します。
	STATE_PENDING_WITH_WAITERS,
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## 完了したことを表します。
	STATE_COMPLETED,
	## [b](アドオン内もしくは実装内でのみ使用)[/b]
	## キャンセルされたことを表します。
	STATE_CANCELED,
}

#-------------------------------------------------------------------------------
# プロパティ
#-------------------------------------------------------------------------------

## この待機可能な単位が完了している場合 true を返します。[br]
## [br]
## [b]補足[/b][br]
## [method wait] を待機した後は、[member is_canceled] もしくは
## このプロパティのうちどちらかが必ず true になります。
var is_completed: bool:
	get:
		return get_state() == STATE_COMPLETED

## この待機可能な単位がキャンセルされている場合 true を返します。[br]
## [br]
## [b]補足[/b][br]
## [method wait] を待機した後は、[member is_completed] もしくは
## このプロパティのうちどちらかが必ず true になります。
var is_canceled: bool:
	get:
		return get_state() == STATE_CANCELED

## この待機可能な単位がまだ完了もしくはキャンセルされていない場合 true を返します。
var is_pending: bool:
	get:
		var state := get_state()
		return \
			state == STATE_PENDING or \
			state == STATE_PENDING_WITH_WAITERS

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## この待機可能な単位が完了もしくはキャンセルされるまで待機しその結果を返します。[br]
## [br]
## キャンセルされた場合の結果は必ず null となりますが、これは
## キャンセルされたかどうかの判断にはなりません。キャンセルされる可能性がある場合、
## [member is_completed] もしくは [member is_canceled] を確認する必要があります。[br]
## [br]
## [b]補足[/b][br]
## 状態が [STATE_PENDING] もしくは [STATE_PENDING_WITH_WAITERS] のとき
## 第 1 引数 [code]cancel[/code] に [Cancel] を指定しキャンセルを要求すると、
## 状態は [STATE_CANCELED] へ移行します。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var async: Async = ...
## var result = async.wait()
## [/codeblock]
func wait(cancel: Cancel = null):
	#
	# 継承先で実装する必要があります。
	#

	return await null

## [b](アドオン内もしくは実装内でのみ使用)[/b]
## この関数ではなく [member is_completed] もしくは [member is_canceled] を
## 使うようにしてください。将来名前が変わる可能性があります。
func get_state() -> int:
	#
	# 継承先で実装する必要があります。
	#

	return STATE_PENDING
