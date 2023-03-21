---
layout: page
tags: [wip, cooperative-multitasking]
title: Distinguishing Coroutines and Fibers
---

# Distinguishing Coroutines and Fibers

 From
 [N4024](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4024.pdf).

## Background

 It might be useful for the authors to disambiguate the conceptual
 space addressed by the coroutine library from the conceptual space
 addressed by the fiber library.

 코루틴 라이브러리가 다루는 개념적인 부분과 파이버 라이브러리가 다루는
 개념적인 부분을 구분하는 것이 저자들에게 도움이 될 것 같다.

## Fibers
### A Quick Sketch of the Fiber Library

 For purposes of this paper, we can regard the term 'fiber' to mean
 'user-space thread.' A fiber is launched, and conceptually it can
 have a lifespan independent of the code that launched it. A fiber can
 be detached from the launching code; alternatively, one fiber can
 join another. A fiber can sleep until a specified time, or for a
 specified duration. Multiple conceptually-independent fibers can run
 on the same kernel thread. When a fiber blocks, for instance waiting
 for a result that's not yet available, other fibers on the same
 thread continue to run. 'Blocking' a fiber implicitly transfers
 control to a fiber scheduler to dispatch some other ready-to-run
 fiber.

 이 글의 목적을 위해, '파이퍼'가 '유저 공간 쓰레드'를 뜻한다고
 간주한다. 한 파이버가 시작되면, 개념적으로는 그 파이버를 실행한
 코드와는 독립적인 수명을 가질 수 있다. 파이버는 그 파이버를 실행한
 코드로부터 분리(detach)될 수 있다. 대신, 한 파이버는 다른 파이버와
 합쳐질 수 있다(join). 파이버는 지정된 기간만큼 또는 지정된 시간이 될
 때까지 잠들 수 있다(sleep). 개념적으로 독립적인 여러 개의 파이버가
 같은 커널 쓰레드 위에서 돌 수 있다. 파이버가 차단되면(block), 예를
 들어 아직 쓸 수 없는 결과를 기다린는 경우, 같은 쓰레드에 있는 다른
 파이버가 계속해서 실행될 수 있다. 파이버 '차단(blocking)'은
 묵시적으로 파이버 스케쥴러에게 제어권을 넘겨줘서 실행될 준비가 된
 다른 파이버를 파견할 수 있게(dispatch) 한다.

---

 Fibers conceptually resemble kernel threads. In fact, the forthcoming
 fiber library proposal intentionally emulates much of the
 `std::thread` API. It provides fiber-local storage. It provides
 several variants of fiber mutexes. It provides `condition_variables`
 and `barriers`. It provides bounded and unbounded queues. It provides
 `future`, `shared_future`, `promise` and `packaged_task`. These
 fiber-oriented synchronization mechanisms differ from their thread
 counterparts in that when (for instance) a mutex blocks its caller,
 it blocks only the calling fiber - not the whole thread on which that
 fiber is running.

 파이버는 개념적으로 커널 쓰레드를 닮아있다. 사실, 다가오는 파이버
 라이브러리 제안은 의도적으로 많은 `std::thread` API를 모방하고
 있다. 제안은 파이버 로컬 스토리지를 제공한다. 파이버 뮤텍스의 여러
 변종도 제공한다. `condition_variables`와 `barriers`도
 제공한다. 바운드/언바운드 큐도 제공한다. `future`, `shared_future`,
 `promise`와 `packaged_task`도 제공한다. 이런 파이버 지향 동기화
 메커니즘은 그와 대응하는 쓰레드 메커니즘과는 다른데, 예를 들어
 뮤텍스가 그 호출자를 차단할 때는, 파이버가 실행 중인 쓰레드 전체가
 아니라 호출한 파이버만 차단한다.

---

 When a fiber blocks, it cannot assume that the scheduler will awaken
 it the moment its wait condition has been satisfied. Satisfaction of
 that condition marks the waiting fiber ready-to-run; eventually the
 scheduler will select that ready fiber for dispatch.

 파이버가 차단될 때는, 나중에 조건이 충족될 때 스케쥴러가 그 파이버를
 깨워줄거라고 가정해서는 안된다. 조건을 만족하면 그 파이버가 실행될
 준비가 되었다고 표시할 뿐이다. 결국에는 스케쥴러가 그 파이버를
 파견하긴 할 것이다.

---

 The key difference between fibers and kernel threads is that fibers
 use cooperative context switching, instead of preemptive
 time-slicing. Two fibers on the same kernel thread will not run
 simultaneously on different processor cores. At most one of the
 fibers on a particular kernel thread can be running at any given
 moment.

 파이버와 커널 쓰레드 간의 핵심 차이점은 파이버는 선점적인 시간 배분
 대신에 협력적인 컨텍스트 스위칭을 사용한다는 것이다. 같은 커널
 쓰레드에 있는 두 개의 파이버는 서로 다른 프로세서 코어에서 동시에
 실행되지 않는다. 어떤 주어진 순간에는 특정 커널 쓰레드에 있는 최대
 하나의 파이버만 실행될 수 있다.

---

 This has several implications:
 - Fiber context switching does not engage the kernel: it takes place
   entirely in user space. This permits a fiber implementation to
   switch context significantly faster than a thread context switch.
 - Two fibers in the same thread cannot execute simultaneously. This
   can greatly simplify sharing data between such fibers: it is
   impossible for two fibers in the same thread to race each
   other. Therefore, within the domain of a particular thread, it is
   not necessary to lock shared data.
 - The coder of a fiber must take care to sprinkle voluntary context
   switches into long CPU-bound operations. Since fiber context
   switching is entirely cooperative, a fiber library cannot guarantee
   progress for every fiber without such precautions.
 - A fiber that calls a standard library or operating-system function
   that blocks the calling thread will in fact block the entire thread
   on which it is running, including all other fibers on that same
   thread. The coder of a fiber must take care to use asynchronous I/O
   operations, or operations that engage fiber blocking rather than
   thread blocking.

 이는 몇 가지 결과를 낳는다:
 - 파이버 컨텍스트 스위칭에는 커널 쓰레드가 관여하지 않는다. 전적으로
   유저 공간에서 일어난다. 이는 파이버 구현체의 컨텍스트 스위치를
   쓰레드보다 엄청나게 빠르게 만든다.
 - 같은 쓰레드에 있는 두 개의 파이버는 동시에 실행될 수 없다. 이는
   이런 파이버들 사이에서 데이터를 공유하는 것을 아주 간단하게
   만든다. 같은 쓰레드 위의 두 파이버가 데이터 레이스를 일으키는 것은
   불가능하다. 따라서, 특정 쓰레드의 도메인 안에서는, 공유 데이터에
   락을 걸 필요가 없다.
 - 파이버 코드를 짤 때에는 반드시 긴 CPU 연산 작업 도중에 간간이
   자발적인 컨텍스트 스위치를 섞어야 함에 주의하자. 파이버 컨텍스트
   스위치는 전적으로 협력적이기 때문에, 파이버 라이브러리는 이런
   예방책이 없이는 모든 파이버가 진행된다는 것을 보장할 수 없다.
 - 한 파이버가 호출한 쓰레드를 차단하는 표준 라이브러리 또는 운영체제
   함수를 호출하면, 이는 곧 그 파이버가 실행되고 있는 쓰레드 전체와
   거기 속한 모든 다른 파이버를 차단하게 된다. 파이버 코드를 짤 때에는
   비동기 입출력 연산을 사용하거나, 쓰레드 차단이 아니라 파이버 차단이
   일어나는 연산을 쓰도록 주의해야 한다.

---

 In effect, fibers extend the concurrency taxonomy:
 - on a single computer, multiple processes can run
 - within a single process, multiple threads can run
 - within a single thread, multiple fibers can run.

 사실상, 파이버는 동시성 분류 체계를 확장한다:
 - 하나의 컴퓨터 위에서는 여러 개의 프로세스를 실행할 수 있다.
 - 하나의 프로세스 안에서는 여러 개의 쓰레드를 실행할 수 있다.
 - 하나의 쓰레드 안에서는 여러 개의 파이버를 실행할 수 있다.


### A Few Fiber Use Cases

 A fiber is useful when you want to launch a (possibly complex)
 sequence of asynchronous I/O operations, especially when you must
 iterate or make decisions based on their results.

 파이버는 (아마도 복잡한) 일련의 비동기 입출력 연산을 실행할 때
 유용한데, 특히 그 결과 값에 따라 반복하거나 결정을 내려야 하는 경우에
 더욱 그렇다.

---

 Distinct fibers can be used to perform concurrent asynchronous fetch
 operations, aggregating their results into a fiber-specific queue for
 another fiber to consume.

 별개의 파이버는 동시성 비동기 Fetch 연산을 수행하는데 쓰여서 그 결과
 값들을 파이버 특화 큐에 집계해서 다른 파이버가 소비하도록 할 수 있다.

---

 Fibers are useful for organizing response code in a event-driven
 program. Typically, an event handler in such a program cannot block
 its calling thread: that would stall handlers for all other events,
 such as mouse movement. Handlers must use asynchronous I/O instead of
 blocking I/O. A fiber allows a handler to resume upon completion of
 an asynchronous I/O operation, rather than breaking out subsequent
 logic as a completely distinct handler.

 파이버는 이벤트 기반 프로그램에서 응답 코드를 정리하는데
 유용하다. 일반적으로, 이런 프로그램의 이벤트 핸들러는는 호출 쓰레드를
 차단할 수 없다. 그러면 마우스 움직임과 같은 다른 모든 이벤트에 대한
 핸들러가 중단되기 때문이다. 핸들러는 차단 입출력 대신 비동기 입출력을
 사용해야 한다. 파이버를 사용하면 후속 로직을 완전히 별개의 핸들러로
 분리하는 것이 아니라, 비동기 입출력 작입어 완료되면 핸들러를 재개할
 수 있다.

---

 Fibers can be used to implement a task handling framework to address
 the [C10k-problem](http://www.kegel.com/c10k.html). For instance
 *strict fork-join task parallelism* with its two flavours -
 *fully-strict computation* (no task can proceed until it joins all of
 its child-tasks) and *terminally-strict computations* (child-tasks
 are joined only at the end of processing) - can be
 supported. Furthermore, different scheduling strategies are possible:
 work-stealing and continuation-stealing. For work-stealing, the
 scheduler creates a child-task (child-fiber) and immediately returns
 to the caller. Each child-task (child-fiber) is executed or stolen by
 the scheduler based on the available resources (CPU etc.). For
 continuation-stealing, the scheduler immediately executes the spawned
 child-task (child-fiber); the rest of the function (continuation) is
 stolen by the scheduler as resources are available.


## Coroutines
### A Quick Recap of the Coroutine Library

 A coroutine is instantiated and called. When the invoker calls a
 coroutine, control immediately transfers into that coroutine; when
 the coroutine yields, control immediately returns to its caller (or,
 in the case of symmetric coroutines, to the designated next
 coroutine).

---

 A coroutine does not have a conceptual lifespan independent of its
 invoker. Calling code instantiates a coroutine, passes control back
 and forth with it for some time, and then destroys it. It makes no
 sens to speak of 'detaching' a coroutine. It makes no sense to speak
 of 'blocking' a coroutine: the coroutine library provides no
 scheduler. The coroutine library provides no facilities for
 synchronizing coroutines: coroutines are already synchronous.

---

 Coroutines do not resemble threads. A coroutine much more closely
 resembles an ordinary function, with a semantic extension: passing
 control to its caller with the expectation of being resumed later at
 exactly the same point. When the invoker resumes a coroutine, the
 control transfer is immediate. There is no intermediary, no agent
 deciding which coroutine to resume next.


### A Few Coroutine Use Cases

 Normally, when consumer code calls a producer function to obtain a
 value, the producer must return that value to the consumer,
 discarding all its local state in so doing. A coroutine allows you to
 write producer code that 'pushes' values (via function call) to a
 consumer that 'pulls' them with a function call.

 일반적으로, 소비자 코드가 생성자 코드를 호출해서 값을 가져올 때,
 생성자는 반드시 그 값을 만드는데 쓰였던 모든 로컬 상태를 버리고 그
 값을 소비자에게 리턴해야 한다. 코루틴은 (함수 호출을 통해) 소비자
 코드에게 값을 '전달'해서 소비자가 함수 호출로 그 값을 '가져'올 수
 있도록 생성자 코드를 작성할 수 있도록 해준다.

---

 For instance, a coroutine can adapt callbacks, as from a SAX parser,
 to values explicitly requested by the consumer.

 예를 들어, 코루틴은 소비자가 명시적으로 요청한 값을 위해서 콜백을
 적용할 수 있고 그 예시는 SAX 파서에서 볼 수 있다.

---

 Moreover, the proposed coroutine library provides iterations over a
 producer coroutine so that a sequence of values from the producer can
 be fed directly into an STL algorithm. This can be used, for example,
 to flatten a tree structure.

 게다가, 제안된 코루틴 라이브러리는 생성자 코루틴을 훑으면서
 생성자로부터 곧바로 STL 알고리즘에 먹일 수 있는 일련의 값을 가져오는
 반복문을 제공한다. 이 기능은 예를 들어서 트리 구조를 1차원적으로
 펴는데 사용할 수 있다.

---

 Coroutines can be chained: a source coroutine can feed values through
 one or more fiber coroutines before those values are ultimately
 delivered to consumer code.

 코루틴은 또한 체이닝될 수 있다. 시작 코루틴은 값이 궁극적으로 소비자
 코드에게 전달되기 전에 그 값을 하나 이상의 파이버 코루틴에 먹일 수
 있다.

---

 In all the above examples, as in every coroutine usage, the handshake
 between producer and consumer is direct and immediate.

 모든 위의 예시에서 보듯이, 모든 코루틴 사용처에서 생성자와 소비자
 간의 핸드셰이크는 직접적이고 즉각적이다.


## Relationship

 The authors have a reference implementation of the forthcoming fiber
 library from `boost.fiber`. The reference implementation is entirely
 coded in portable `C++`; in fact its original implementation was
 entirely in `c++03`. This is possible because the reference
 implementation of the fiber library is built on `boost.coroutine`,
 which provides context management. The fiber library extends the
 coroutine library by adding a scheduler and the aforementioned
 synchronization mechanisms.

---

 Of course it would be possible to implement coroutines on top of
 fibers instead. But the concepts map more neatly to implementing
 fibers in terms of coroutines. The corresponding operations are:
 - a coroutine yields;
 - a fiber blocks.

 When a coroutine yields, it passes control directly to its caller
 (or, in the case of symmetric coroutines, a designated other
 coroutine). When a fiber blocks, it implicitly passes control to the
 fiber scheduler. Coroutines have no scheduler because they need no
 scheduler.
