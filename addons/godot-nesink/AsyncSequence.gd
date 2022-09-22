class_name AsyncSequence extends Async

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## ジェネレータを待機し、結果を 1 つ受け取った後ジェネレータを再開させます。[br]
## [br]
## yield された値を返します。[br]
## [br]
## [b]補足[/b][br]
## return されたことをこのメソッドのみでは検知できないため、
## [member Nesinkrona.is_completed] や [member Nesinkrona.is_canceled] と組み合わせて使います。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var seq: AsyncSequence = ...
## while not seq.is_completed and not seq.is_canceled:
##     var res = await seq.next(10)
## [/codeblock]
func next(
	value = null,
	cancel: Cancel = null) -> Async:

	#
	# 継承先で実装する必要があります。
	#

	return await null
