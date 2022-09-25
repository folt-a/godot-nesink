## 非同期的な反復処理を抽象化するインターフェイスです。
##
## 非同期的な反復処理を抽象化し、将来生成され決まる反復結果をこの共通のインターフェイスからアクセスできるようにします。
class_name AsyncIterator extends NesinkronaAwaitable

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## この [AsyncIterator] の最終結果が [Async] である場合、
## 指定した回数アンラップを試みた新たな [Async] を作成します。
func unwrap(
	depth := 1,
	cancel: Cancel = null) -> Async:

	assert(0 <= depth)
	return \
		NesinkronaCanon.create_canceled_async() \
		if cancel and cancel.is_requested or is_canceled else \
		self \
		if depth == 0 else \
		NesinkronaUnwrapAsync.new(self, cancel, depth)

## この [AsyncIterator] が完了した場合、
## 指定したコルーチン (もしくは関数) の戻り値を結果として完了する新たな [Async] を作成します。
func then(
	coroutine: Callable,
	cancel: Cancel = null) -> Async:

	assert(coroutine != null)
	return NesinkronaThenAsync.new(self, cancel, coroutine)

## この [AsyncIterator] が完了した場合、
## 指定したコルーチン (もしくは関数) を呼び出し結果を待機する新たな [Async] を作成します。
func then_callback(
	coroutine: Callable,
	cancel: Cancel = null) -> Async:

	assert(coroutine != null)
	return NesinkronaThenCallbackAsync.new(self, cancel, coroutine)

func next() -> Async:
	#
	# 継承先で実装する必要があります。
	#

	return NesinkronaCanon.create_canceled_async()

static func from(coroutine: Callable) -> AsyncIterator:
	assert(coroutine != null)
	return NesinkronaAsyncIterator.new(coroutine)

#-------------------------------------------------------------------------------

func _to_string() -> String:
	var str: String
	match get_state():
		STATE_PENDING:
			str = "(pending)"
		STATE_PENDING_WITH_WAITERS:
			str = "(pending_with_waiters)"
		STATE_CANCELED:
			str = "(canceled)"
		STATE_COMPLETED:
			str = "(completed)"
		_:
			assert(false)
	return str + "<AsyncIterator#%d>" % get_instance_id()
