## 非同期的な生成処理 (双方向での値の受け渡しを含みます) を抽象化するインターフェイスです。
##
## 非同期的な生成処理を抽象化し、将来生成され決まる生成結果をこの共通のインターフェイスからアクセスできるようにします。
class_name AsyncGenerator extends NesinkronaAwaitable

#-------------------------------------------------------------------------------
# メソッド
#-------------------------------------------------------------------------------

## この [AsyncGenerator] の最終結果が [Async] である場合、
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

## この [AsyncGenerator] が完了した場合、
## 指定したコルーチン (もしくは関数) の戻り値を結果として完了する新たな [Async] を作成します。
func then(
	coroutine: Callable,
	cancel: Cancel = null) -> Async:

	assert(coroutine != null)
	return NesinkronaThenAsync.new(self, cancel, coroutine)

## この [AsyncGenerator] が完了した場合、
## 指定したコルーチン (もしくは関数) を呼び出し結果を待機する新たな [Async] を作成します。
func then_callback(
	coroutine: Callable,
	cancel: Cancel = null) -> Async:

	assert(coroutine != null)
	return NesinkronaThenCallbackAsync.new(self, cancel, coroutine)

func next(value = null) -> Async:
	#
	# 継承先で実装する必要があります。
	#

	return NesinkronaCanon.create_canceled_async()

static func from(coroutine: Callable) -> AsyncGenerator:
	assert(coroutine != null)
	return NesinkronaAsyncGenerator.new(coroutine)

#-------------------------------------------------------------------------------

func _to_string() -> String:
	var str: String
	match get_state():
		STATE_PENDING:
			str = "(pending)" + str
		STATE_PENDING_WITH_WAITERS:
			str = "(pending_with_waiters)" + str
		STATE_CANCELED:
			str = "(canceled)" + str
		STATE_COMPLETED:
			str = "(completed)" + str
		_:
			assert(false)
	return str + "<AsyncGenerator#%d>" % get_instance_id()
