---
layout: page
title: 2. Combinator parsers
---

# 2. 컴비네이터 파서
 먼저 옛 현인들의 컴비네이터 파싱에 대한 기본 아이디어를 리뷰하는
 것부터 시작하자. 구체적으로는 일단 파서와 세 개의 원시 파서, 더 큰
 파서를 만들기 위한 두 개의 원시 컴비네이터에 대한 타입부터 정의한다.

## 2.1. 파서의 타입
 먼저 "파서"란 문자열을 입력으로 받아서 어떤 종류의 트리를 결과로
 내놓는 함수로 생각하는 것부터 시작하자. 트리는 문자열의 문법적 구조를
 명시적으로 드러낸다.

```ocaml
type parser = string -> tree
```

 첫 번째 아이디어는 바로 파서가 입력 문자열을 전부 소모(consume)하지
 않을 수도 있다는 것이다. 그러므로, 결과 트리만 리턴하기 보다는 입력
 문자열에서 **아직 소모되지 않은 접두사 부분**을 같이 리턴할 수
 있다. 따라서 파서의 타입은 다음과 같다.

```ocaml
type parser = string -> (string * tree)
```

 두 번째 아이디어는 바로 파서가 어떤 입력 문자열에 대해서는 *실패*할
 수도 있다는 것이다. 이럴 때 런타임 에러를 던지는 것보다는, 파서가
 어느 부분에서 왜 실패했는지를 알려주면 디버깅에 유용할
 것이다. `Result` 타입을 이용하면 좋을 것 같다.

```ocaml
type parser = string -> string * (tree, string) result
```

 명시적인 *실패* 표현을 가지며 입력 문자열에서 *소모되지 않은 부분*을
 리턴하는 일은 작은 파서로부터 더 큰 파서를 만들기 위한 컴비네이터를
 정의할 수 있게 해준다.

 서로 다른 파서는 서로 다른 종류의 트리를 리턴하기 마련인데, 따라서
 구체적인 트리의 타입을 추상화해서 파서의 타입을 파라미터화 하는 것이
 좋다.

```ocaml
type 'a parser = string -> string * ('a * string) result
```

 입력을 좀더 세분화해서 "어디까지"를 같이 기록하면 좋을 것 같다.

```ocaml
type input =
  { text : string
  ; pos : int
  }

let make_input (s: string) : input = { text = s; pos = 0 }
```

 마지막으로, 우리는 파서가 항상 클로저를 갖고 있길 원한다. 따라서
 최종적인 우리의 파서 타입은 다음과 같다.

```ocaml
type 'a parser =
  { run : input -> input * ('a, string) result
  }
```

## 2.2. 원시(Primitive) 파서
 컴비네이터 파싱의 기본 구성 요소인 네 개의 원시 파서를 볼 것이다.

 첫 번째 파서는 `return v`로 입력 문자열을 아무것도 소모하지 않고
 성공하고 하나의 결과 `v`를 리턴한다.

```ocaml
let return (v: 'a) : 'a parser = { run = fun input -> input, Ok v }
```

 두 번째 파서는 항상 실패하는 `fail`이다. 디버깅을 위한 에러 메시지를
 함께 받는다.

```ocaml
let fail (err: string) : 'a parser = { run = fun input -> input, Error err }
```

 세 번째 프리미티브는 `any_char`으로, 입력 문자열에 대해서 첫 번째
 글자를 항상 소모하거나, 문자열이 비어있으면 실패하는 함수이다. 우리의
 입력 타입인 `input`을 좀더 손쉽게 다루기 위해서 먼저 입력에서 일부만
 소모하는 함수 `consume_input`을 만들자. `consume_input input pos
 len`은 주어진 입력 `input`의 `text`의 `pos`부터 `len`만큼의 문자를
 소모하고 남은 입력을 리턴한다.

```ocaml
let consume_input (input: input) (pos: int) (len: int) : input =
  { text = String.sub (input.text) pos len
  ; pos = input.pos + pos
  }
```

 이를 이용해 `any_char`를 구현할 수 있다.

```ocaml
let any_char : char parser = {
  run = fun input ->
    let n = String.length input.text in
    try
      consume_input 1 (n - 1) input, Ok (String.get input.text 0)
    with Invalid_argument _ -> input, Error "expected any character"
}
```

 마지막으로, 입력을 직접 소모하지 않고 글자를 하나만 살펴보는 이른바
 룩어헤드(Lookahead) 파서인 `peek_char`가 있다. `any_char`와는 달리
 조건부 파싱에 쓰일 수 있다.

```ocaml
let peek_char : char parser = {
  run = fun input ->
    try
      input, Ok (String.get input.text 0)
    with Invalid_argument _ -> input, Error "empty input"
}
```

## 2.3. 파서 컴비네이터
 앞서 정의한 원시 파서들은 그 자체로는 그다지 쓸모있지는
 않다. 여기서는 더 유용한 파서를 만들기 위해서 이 파서를 어떻게 이어
 붙일 수 있는지(glue)를 살펴본다. 특히, 고차 함수(=컴비네이터)를
 이용해서 코드를 깔끔하고 읽기 쉽게 만들 수 있다. 함수 적용과 유사한
 *시퀀싱(sequencing; 여러 개의 함수를 연달아 적용)* 컴비네이터,
 *선택(choice; 여러 개의 함수 중 성공한 것을 적용)* 컴비네이터, 앞
 쪽을 버리는 컴비네이터, 뒷 쪽을 버리는 컴비네이터 등을 살펴볼
 것이다. 이렇게 정의된 컴비네이터들은 실제 BNF 문법의 구조와 거의
 유사한 구조로 파서를 합치는 것을 도와준다.

 모나드 방식이 아닌 초창기의 컴비네이터 파싱에서, 파서의 시퀀싱 연산은
 보통 다음 타입을 가졌었다:

```ocaml
let seq : 'a parser -> 'b parser -> ('a * 'b) parser
```

 즉, 두 파서를 번갈아 적용해서 두 파서의 결과를 튜플로 묶는
 연산이다. 얼핏 보기에 `seq` 컴비네이터는 자연스러운 합성 연산으로
 보인다. 하지만 실제로는 `seq`을 계속 사용하다 보면 그 결과로 엄청나게
 중첩된 튜플을 갖게 되는데, 이를 다루는 것은 굉장히 지저분한 일이다.

 중첩된 튜플 문제는 *모나드식* 시퀀싱 컴비네이터를 적용해서 피할 수
 있다. 흔히 `바인드(bind)` 연산으로 알려진 것으로, 한 파서의 결과 값을
 처리해서 파서들을 시퀀싱하여 합치는 방식이다.

```ocaml
let bind (p: 'a parser) (f: 'a -> 'b parser) : 'b parser =
  { run = fun input ->
      match p.run input with
      | input', Ok x -> (f x).run input'
      | input', Error err -> input', Error err
  }
```

 `bind`의 정의는 다음과 같이 이해할 수 있다. 먼저, 파서 `p`를 입력
 문자열에 적용해서 결과로 소모되지 않은 입력과 결과 값을
 가져온다. 만약 실패했다면 (`match`의 `Error err` 케이스), 실패를
 그대로 리턴한다. 성공했다면 `'a` 타입의 값을 얻을텐데 (`match`의 `Ok
 x` 케이스), `f`가 `'a` 타입의 값을 받아 `'b` 타입의 파서를 리턴하는
 함수이므로 이제 `x`에 `f`를 적용해서 새로운 파서를 만들 수 있다. 이때
 남은 입력에 대해서 적용해야 함을 잊지말자.

 참고로 `bind` 컴비네이터는 `bind` 라는 함수 그 자체로 호출되기 보다는
 주로 다음과 같이 중위 연산자로 재정의 되어 쓰이는 것이 일반적이다.

```ocaml
let (>>=) = bind
```

 `bind` 컴비네이터는 결과의 중첩된 튜플 문제를 피하게 해준다. 왜냐하면
 첫 번째 파서의 결과가 나중에 처리될 결과와 튜플로 묶이지 않고 곧바로
 두 번째 파서에 의해서 처리될 수 있기 때문이다.

 `bind` 컴비네이터 (중위 연산자)를 이용한 아주 전형적인 예시를 하나
 살펴보자. 두 파서를 튜플로 묶는 `pair`를 `bind`로 구현하면 다음과
 같다.

```ocaml
let pair (p: 'a parser) (q: 'b parser) : ('a * 'b) parser =
  p >>= fun x ->
  q >>= fun y ->
  return (x, y)
```

 이걸 해석하면 이렇다. 우리는 파서 `p`와 파서 `q`를 합쳐서 다음과 같은
 동작을 하는 파서를 만들 것이다: 먼저 파서 `p`를 적용한다. 성공한
 경우에는 결과 값 `x`를 사용할 수 있다(`fun x -> ..`).  그 다음 파서
 `q`를 나머지 입력에 대해서 적용한다. 역시 성공한 경우 결과 값 `y`를
 곧바로 사용할 수 있다(`fun y -> ..`). 최종적으로 두 결과를 튜플로
 리턴하는 **파서를 리턴한다(`return (x, y)`)**. `p`, `q` 둘 중 어느
 파서든 파싱에 실패할 경우 곧바로 해당 에러를 리턴한다. 모나드식 접근
 덕분에 코드가 아름답고 이해가 잘 된다.


 `bind` 컴비네이터를 이용하면 간단하지만 유용한 파서들을 정의할 수
 있다. 예를 들어, `any_char` 파서는 하나의 글자를 *무조건적*으로
 파싱했는데, 실제 상황에서는 보통 "특정 글자"에만 관심있기
 마련이다. 따라서 룩어헤드를 위한 `peek_char`와 `any_char`를 이용해서
 새로운 컴비네이터 `satisfy`를 만들 수 있다. 이 컴비네이터는 조건
 함수(predicate)를 받아서 해당 조건을 만족하는 글자만 파싱하고 그렇지
 않으면 실패한다.

```ocaml
let satisfy (f: char -> bool) : char parser =
  peek_char >>= fun x -> if f x then any_char else fail "Predicate not satisfied."
```

 이제 `satisfy`를 이용해서 특정 글자, 숫자, 소문자, 대문자 등을 파싱할
 수 있다:

```ocaml
let char (c: char) : char parser = satisfy (fun x -> x = c)

let digit : char parser = satisfy (fun x -> '0' <= x && x <= '9')

let lower : char parser = satisfy (fun x -> 'a' <= x && x <= 'z')

let upper : char parser = satisfy (fun x -> 'A' <= x && x <= 'Z')
```

 예를 들어 `upper` 파서를 입력 문자열 `"Hello"`에 적용하면 다음과 같은
 결과를 리턴하며 성공할 것이다:

```ocaml
upper.run (make_input "Hello") ;;
- : input * (char, string) result = ({text = "ello"; pos = 1}, Ok 'H')
```

 즉 첫글자 대문자 `H`를 성공적으로 파싱한 결과 `Ok 'H'`와, 입력
 문자열에서 아직 소모되지 않은 나머지 부분에 대한 정보를 잘 갖고 있다.

 만약 `digit` 파서를 입력 문자열 `"Hello"`에 적용한다면, 파싱에
 실패하게 되고 다음과 같이 입력 문자열을 하나도 소모하지 않는다.

```ocaml
digit.run (make_input "Hello") ;;
- : input * (char, string) result =
({text = "Hello"; pos = 0}, Error "predicate not satisfy")
```

 이제 위에서 만든 파서를 가지고 더 강력한 파서를 만들 수 있는
 선택(choice) 컴비네이터를 살펴보자. 예를 들어, 우리는 소문자 파서
 `lower`와 대문자 파서 `upper` 중 어느 것을 만족해도 상관없는 글자를
 파싱하는 `letter` 파서를 정의할 수 있다. 이를 위해서, 우리는 다음과
 같은 선택 컴비네이터가 필요하다.

```ocaml
let choice (p1: 'a parser) (p2: 'a parser) : 'a parser =
  { run =
      fun input ->
        let input', result = p1.run input in
        match result with
        | Ok x -> input', Ok x
        | Error err -> p2.run input
  }
```

 즉, `choice` 컴비네이터는 먼저 첫 번째 파서를 입력 문자열에
 적용해보고 성공한 경우 남은 입력과 그 결과를 리턴한다. 실패한 경우 두
 번째 파서를 마저 적용해본다. 둘 중 어느 것이든 만족하면 그만인
 것이다. 참고로 선택 컴비네이터는 파서가 *실패*했을 때 뭔가를 더
 해야하므로 `bind` 컴비네이터로는 구현할 수 없다.

 보통 `choice` 컴비네이터도 다음과 같이 중위 연산자로 정의해서 쓰는
 것이 편리하다.

```ocaml
let (<|>) = choice
```

 그러면 우리는 다음과 같이 대/소문자 글자를 파싱하는 파서 `letter`와,
 알파벳과 숫자를 파싱하는 파서 `alphanum`을 정의할 수 있다.

```ocaml
let letter = lower <|> upper

let alphanum = letter <|> digit
```

 마지막으로 조건을 만족하는 *단어*를 파싱하는 파서를 만들어보자. 크게
 두 종류의 컴비네이터를 사용해볼 수 있는데,
  - 조건(predicate)을 만족하는 동안 계속 파싱하는 컴비네이터,
  - 파서가 파싱에 성공하는 동안 계속 파싱하는 컴비네이터,

 두 가지를 모두 살펴볼 것이다.

 먼저 조건을 만족하는 동안 계속 파싱하는 컴비네이터 `take_while`은
 `satisfy`와 유사하다.

```ocaml
let take_while (f: char -> bool) : string parser =
  { run =
      fun input ->
        let n = String.length input.text in
        let i = ref 0 in
        while !i < n && String.get input.text !i |> f do
          incr i
        done ;
        consume_input !i (n - !i) input, Ok (String.sub input.text 0 !i)
  }
```

 문자 그대로 주어진 조건 `f`를 만족하는 동안 계속 입력 문자열을
 소모하여 최종 파싱 결과를 리턴한다. 이 컴비네이터를 이용해서 단어를
 파싱하는 파서를 만들면 다음과 같다.

```ocaml
let word : string parser = take_while (fun x -> ('a' <= x && x <= 'z') || ('A' <= x && x <= 'Z') || ('0' <= x && x <= '9'))
```

 즉, 앞의 `lower`, `upper`, `digit`의 조건식으로 들어갔던 함수를
 합쳐서 전달해주면 된다.

 두 번째 방법은 `letter`, `upper`, `digit`과 같은 미리 만들어둔 파서를
 조합할 수 있는 방식이다. 먼저 마찬가지로 파서가 파싱 가능한 만큼
 파싱하고 그 결과를 리스트(어떤 값일지 모르기 때문에 곧바로 문자열로
 바꾸기는 어렵다)로 모아주는 컴비네이터 `many`를 정의하자.

```ocaml
let many (p : 'a parser) : 'a list parser =
  { run =
      fun input ->
        let acc = ref [] in
        let rec loop input =
          let input', result = p.run input in
          match result with
          | Ok x ->
            acc := x :: !acc ;
            loop input'
          | Error _ -> input
        in
        let input' = loop input in
        input', Ok (List.rev !acc)
  }
```

 입력으로 받은 파서 `p`를 실패할 때까지 계속 적용하면서 결과를
 리스트에 쌓아뒀다가 최종적으로 파서가 파싱한 값의 리스트를 돌려주는
 컴비네이터이다. 이 친구를 이용해서 단어 파서를 만들면 다음과 같다.

```ocaml
let string : string parser =
  many (lower <|> upper <|> digit) >>=
  fun chars ->
    let s = String.of_seq (List.to_seq chars) in
    return s
```

 즉, `lower` 또는 `upper` 또는 `digit` 파서를 이용해서 입력을 계속
 파싱하여 결과를 리스트에 모아두고, 최종적으로 이 (글자의) 리스트를
 문자열로 합쳐서 돌려주는 파서다.

 그 외에 유용한 컴비네이터로는 앞쪽의 결과를 버리는 컴비네이터 `*>`가
 있다. 예를 들어 문법에서 공백이나 중괄호를 무시하고 싶을 때 사용할 수
 있다. 이 친구는 `bind`를 이용해서 깔끔하게 구현 가능하다.

```ocaml
let ( *> ) (p1: 'a parser) (p2: 'b parser) : 'b parser = p1 >>= fun _ -> p2
```

 즉 첫 번째 파서의 결과 값은 버리고, 남은 입력만을 취하는 것이다.
