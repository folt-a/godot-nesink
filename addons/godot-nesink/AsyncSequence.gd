class_name AsyncSequence extends Async

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## ジェネレータが返す値を 1 つ含む [Async] を作成し、ジェネレータを再開させます。[br]
## [br]
## yield された値を含む [Async] を返します。[br]
## [br]
## [b]使い方[/b]
## [codeblock]
## var seq: AsyncSequence = ...
## while not seq.is_completed and not seq.is_canceled:
##     var ret := seq.next(10)
##     print(ret.wait())
##     if ret.is_completed or ret.is_canceled:
##         break
## [/codeblock]
func next(value = null) -> Async:
	#
	# 継承先で実装する必要があります。
	#

	return NesinkronaCanon.create_canceled_async()
