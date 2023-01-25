---
layout: page
tags: [ocaml, concurrency, parallelism, cooperative-multitasking]
title: Lwt in 5 Minutes
---

# [Lwt in 5 minutes](https://ocsigen.org/tuto/latest/manual/lwt)


## 원칙
 Lwt 라이브러리는 협력형 쓰레드를 구현한다. 협력형 쓰레드는 선점형
 쓰레드에서 겪게 되는 대부분의 이슈를 해결해준다. Lwt를 이용하면
 데드락의 위험이 거의 없고 락도 거의 필요없다. Lwt 쓰레드는 심지어
 `Js_of_ocaml`로 컴파일된 자바스크립트 프로그램에서도 쓰일 수
 있다(왜냐면 Promise랑 거의 유사하기 때문에).

 Lwt는 대부분의 프로그램이 키, 소켓에서 읽어 들일 데이터, 마우스
 이벤트 등 입력을 기다리는데 대부분의 시간을 쓴다는 사실에
 근거한다. 임의의 시점에 쓰레드 사이를 스위치해버리는 선점형 쓰레드와
 달리, Lwt는 이런 기다리는 시간을 *협력 포인트(cooperation points)*로
 이용한다. 즉, `read` 함수처럼 블로킹을 하지 않고, Lwt는 계속할 준비가
 되어 있는 준비된 쓰레드 중 하나를 재개(resume) 시킨다. 우리가 해야 할
 일은 각 블로킹 함수의 협력형 버전을 사용하는 것이다. 예를 들면
 `Unit.sleep` 대신 `Lwt_unix.sleep`, `Unix.read` 대신
 `Lwt_unix.read`를 호출하는 것이다. 계산 중 하나가 오랜 시간이
 걸린다면, `Lwt_main.yield`를 호출해서 직접 협력 포인트를 삽입하는
 것도 가능하다.

## Promises

 Lwt는 `'a Lwt.t` 타입으로 프로미스를 정의한다. 예를 들어, 다음 함수

```ocaml
val f : unit -> int Lwt.t
```

 는 `int`의 프로미스를 곧바로 리턴하는데, 즉 뭔가 계산이 끝나기만
 한다면 결국에는 하나의 정수 값을 가진다는 의미이다.

 다음 코드는 `f ()`의 계산을 (비동기적으로) 시작한다. 코드가 협력
 포인트에 도달하면 (예를 들어 정수 값이 네트워크를 통해 요청되거나
 하는 등), 프로그램은 계속 진행되어 `print_endline "hello"`를
 수행하고, 데이터를 사용할 수 있을 때 이후의 협력 포인트에서 재개된다.

```ocaml
let g1 () =
    let p = f () in
    print_endline "hello"
```

## Bind: 프로미스의 값을 사용하기

 프로미스가 완료되고 나면 함수를 사용하도록 하는 것이 가능하다. 다음
 함수를 이용하면 된다.

```ocaml
Lwt.bind : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
```

 예를 들면 `Lwt.bind p h`는 프로미스 `p`의 리턴 값을 알게 되자마자 이
 값을 이용해서 함수 `h`를 호출한다. 표현식 `(Lwt.bind p h)` 역시
 프로미스 타입이라서 완료하는데 시간이 걸릴 수 있다. 함수 `h`는 반드시
 프로미스를 리턴해야 한다.

 값으로부터 완료된 프로미스를 생성하기 위해서는 `Lwt.return` 함수를
 쓰면 된다.

```ocaml
let g2 () =
    let p = f () in
    Lwt.bind p (fun i -> print_int i; Lwt.return ())
```

 위 코드에서 함수 `g2`는 함수 `f`를 호출해서 프로미스를
 생성한다. 그러고나서 (협력적인 방식으로) 결과를 기다리고, 그 결과를
 출력한다. `g2 ()`는 `unit Lwt.t` 타입이다.

## 문법 확장

 문법 확장도 가능하다.

```ocaml
let%lwt i = f () in
...
```

 이는 아래 코드와 동일하다.

```ocaml
Lwt.bind (f ()) (fun i -> ...)
```


## 예시
### 매 초마다 "tic"를 영원히 출력하지만 프로그램의 나머지 부분은 블로킹 되지 않는 함수

```ocaml
let rec tic () =
    print_endline "tic";
    let%lwt () = Lwt_unix.sleep 1.0 in
    tic ()
```

 여기서 `Lwt_unix.sleep`을 `Lwt_js.sleep`으로 바꾸면 브라우저에서
 실행할 수 있다.

### 동시성 쓰레드를 시작하고 각각의 결과를 기다리기

 아래 타입의 두 협력 쓰레드가 있다고 하자.

```ocaml
val f : unit -> unit Lwt.t
val g : unit -> unit Lwt.t
```

 다음 코드는 `f ()`와 `g ()`를 차례로 호출한다.

```ocaml
let%lwt () = f () in
let%lwt () = g () in
...
```

 다음 코드는 `f ()`와 `g ()`를 동시에 시작하고, 계속하기 전에 두
 쓰레드가 모두 종료될 때까지 기다린다.

```ocaml
let p1 = f () in
let p2 = g () in
let%lwt () = p1 in
let%lwt () = p2 in
...
```

 쓰레드를 분리(detach)하려면 다음과 같이 쓰는 것을 추천한다. 그래야
 예외를 적절히 잡을 수 있다.

```ocaml
Lwt.async (fun () -> f ())
```

 아래와 같이 쓰지 말자.

```ocaml
ignore (f ())
```

### 순차적인 리스트 매핑과 동시적인 리스트 매핑

 다음 `map` 함수는 모든 리스트 원소에 대해서 모든 계산을 동시에
 진행한다.

```ocaml
let rec map f l =
    match l with
    | [] -> Lwt.return []
    | v :: r ->
        let t = f v in
        let rt = map f r in
        let%lwt v' = t in
        let%lwt l' = rt in
        Lwt.return (v' :: l')
```

 반면에 아래 함수는 다음번 계산을 시작하기 전에 지금 계산하고 있는
 것이 완료될 때까지 기다려야 한다.

```ocaml
let rec map_serial f l =
    match l with
    | [] -> Lwt.return []
    | v :: r ->
        let%lwt v' = f v in
        let%lwt l' = map_serial f r in
        Lwt.return (v' :: l')
```
