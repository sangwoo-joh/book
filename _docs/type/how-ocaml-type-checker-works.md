---
layout: page
title: How OCaml Type Checker Works
---

{: .no_toc }
# [How OCaml Type Checker Works - or What Polymorphism and Garbage Collection Have In Common](https://okmij.org/ftp/ML/generalization.html)

 힌들리-밀너 타입 추론에는 알고리즘 W 말고도 좀 더 많은 것이
 있다. 1988년에, 디디어 레미(Didier Remy)는 Caml의 타입 추론 속도를
 높일려고 하고 있었는데, 타입 일반화(type generalization)를 위한
 우아한 방법을 발견했다. 타입 환경(type environment)을 스캐닝하지
 않아도 되서 빠를 뿐만이 아니다. 이 방법은 로컬에 선언되었지만
 보편적(universal; $$ \forall $$) 또는 존재적(existential; $$ \exists
 $$) 양화로 빠져나가는(escape) 타입을 잡을 수 있게 스무스하게
 확장된다.

 OCaml 타입 체커의 알고리즘과 구현은 모두 거의 알려져있지 않고 또 거의
 문서화되어 있지 않다. 이 페이지는 레미의 알고리즘을 설명하고 널리
 알리려 한다. 또, OCaml 타입 체커의 일부를 해석하려는 시도다. 레미의
 알고리즘의 역사 또한 보존하고자 한다.

 레미의 알고리즘의 매력은 타입 일반화를 일종의 의존성 추적으로 바라본
 통찰력에 있다. 이는 (메모리) 구역과 세대별 가비지 콜렉션과 같은 자동
 메모리 관리에서 쓰이는 추적 방법과 같은 종류이다. (타입) 일반화는
 노드에는 타입을 어노테이트하고 엣지는 공유된 타입을 나타내도록 표현한
 AST에서 도미네이터를 찾는 일로 볼 수 있다.


## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

## Introduction
 이 페이지는 원래 광범위하고, 복잡하고, 거의 문서화가 안된 OCaml 타입
 체커 코드를 이해하기 위해서 작성하던 노트로 시작했다. 코드를 파고
 들어가 보니 엄청난 보물이 발견되었다. 그 중 하나인 효율적이고 우아한
 타입 일반화 방법을 여기서 소개한다.

 OCaml의 타입 일반화는 이른바 타입의 *레벨(levels)* 추적
 기반이다. 완전히 같은 레벨은 모듈 안에 정의된 타입이 더 넓은 범위로
 빠져나가는(escape) 것을 막아준다. 따라서 레벨은 지역적으로 도입된
 타입 생성자에게 구역 규율(region discipline)을 강제한다. 일반화와
 구역이 아주 균일한 방법으로 처리되는 것은 굉장히 흥미롭다. OCaml 타입
 체커에서 레벨은 더 많은 쓰임새가 있는데, 폴리모픽 필드와 존재
 양화사(existential)를 가진 레코드에도 쓰인다. MetaOCaml은 미래에 쓰일
 (future-stage) 바인딩 범위를 추적하기 위해서 레벨에 간접적으로
 의존하고 있었다. 이런 모든 어플리케이션에는 공통적인 불평이 있었는데,
 의존성을 추적하는 일과 구역 억제 또는 데이터 의존 그래프의
 도미네이터를 계산하는 일이었다. 하나는 곧바로 Tofte와 Talpin의 구역
 기반의 메모리 관리를 떠올리게 한다. Fluet과 Morrisett이 보여줬듯이,
 구역을 위한 Tofte와 Taplin 타입 시스템은 할당된 데이터가 그 구역에서
 빠져나가는 것을 정적으로 막기 위해서 보편 양화사에 의존하여 System
 F에서 인코딩될 수 있다. 이것과 듀얼하게, 레벨 기반 일반화는 타입
 변수의 구역을 결정하기 위해서 타입 변수가 빠져나가는 것을 추적하는
 것에 의존하고, 따라서 보편 양화사를 위한 장소이다.

 OCaml의 일반화는 1988년에 디디어 레미에 의해 발견된 알고리즘의
 (부분적인) 구현이다. 이 아이디어는 타입이 명시된 AST 위에서 타입의
 공유를 명시적으로 표현하는 것이다. 타입 변수는 오직 그 변수의 모든
 발생(all occurrences)을 도미네이트하는 노드에서만 양화될 수
 있다. 타입 일반화는 그래프 도미네이터의 증분 계산에 해당한다. 레미의
 MLF는 이 아이디어의 자연스러운 결과물이다.

 아쉽게도, 레미의 일반화 알고리즘과 그 기저의 아이디어는 거의 알려져
 있지 않다. OCaml에 있는 것과 같은 구현은 OCaml 소스 코드에 아주 짧고
 헷갈리게 작성된 주석 외에는 전혀 문서화되어 있지 않는 것 같다. 이건
 널리 알려져야 한다. 이를 위해서, (1) 알고리즘에 대한 동기 부여와
 설명을 해서 그 직관과 뼈대 구현을 드러내고, (2) OCaml 타입 체커를
 해석한다.

 이 글의 두 번째 파트는 OCaml 타입 체커의 일부분에 주석을 다는 것이
 목적이고, 따라서, 꽤 기술적이다. OCaml 4.00.1 버전의 타입 체킹 코드를
 참조하고 있다. `typing/` 디렉토리 안에 있다. `typecore.ml` 파일이
 타입 체커의 핵심이다. AST의 노드를 타입과 타이핑 환경으로
 어노테이트한다. 정확히는, `parsing/parsetree.mli`에 정의된
 `Parsetree`를 `Typedtree`로 변환한다. `ctype.ml` 파일은 유니피케이션
 알고리즘과 레벨 조작 함수를 구현하고 있다.

## Generalization

 이 배경 설명에서는 힌들리 밀너 타입 시스템의 타입 일반화를 설명하고
 나이브한 구현의 미묘한 점과 비효율적인 점을 강조한다. 이 비효율은
 레미가 레벨 기반 일반화 알고리즘을 발견하는 동기가 되었다.

 타입 환경 `G`에 대한 타입 `t`의 *일반화(generalization)* `GEN(G,
 t)`가 `G`에서 자유로 나타나지 않는 `t`의 자유 타입 변수를 양화하는
 것임을 떠올려보자. 즉, `GET(G, t) = ` $$ \forall \alpha_1
 ... \alpha_n .$$ `t` where $$ { \alpha_1, ..., \alpha_n} = $$
 `FV(t) - FV(G)`. 힌들리 밀너 식으로 얘기하면, 이 양화는 타입을 이른바
 타입 스키마(type schema)로 바꾼다. 일반화는 `let` 표현식의 타입
 체킹에 쓰인다.

```
G ㅏ e : t     G, (x: GEN(G, t)) ㅏ e2 : t2
---------------------------------------------
G ㅏ let x = e in e2 : t2
```

 즉, `let`에 묶인 변수에 추론된 타입은 `let` 표현식의 바디를 타입
 체킹할 때 일반화된다. ML은 일반화에 조건을 추가하는데, 이른바 값
 제약(value restriction)이다. `let`에 묶인 표현식 `e`는 겉보기에는
 반드시 눈에 보이는 사이드 이펙트가 없어야 한다. 기술적으로는, `e`는
 반드시 *비확장성(nonexpansive)*이라는 문법 테스트를 통과해야
 한다. OCaml은 이 값 제약을 완화하는데, 뒤에서 나온다.

 일반화의 단순한 예시는 다음과 같다.

```ocaml
fun x -> let y = fun z -> z in y
(* 'a -> ('b -> 'b) *)
```

 타입 체커는 `fun z -> z`에 대해서 새로운, 그래서 유니크한 타입 변수
 $$ \beta $$를 도입하여 $$ \beta \to \beta $$ 타입을 추론한다. 표현식
 `fun z -> z`는 문법적으로는 값이고, 일반화가 진행되고, 그래서 `y`는
 타입 $$ \forall \beta. \beta \to \beta$$를 갖는다. 폴리모픽 타입이기
 때문에, `y`는 다른 타입 문맥에서 등장할 수도 있다. 즉, 다른 타입의
 아규먼트에 적용될 수도 있다. 예를 들면 다음과 같다.

```ocaml
fun x ->
  let y = fun z -> z in
  (y 1, y true)
(* 'a -> int * bool *)
```

 일반화 `GEN(G, t)`는 `G`에 나타나지 않는 `t`의 자유 타입 변수에
 대해서*만* 양화한다. 이 조건은 미묘하지만 아주 중요하다. 이게 없으면,
 $$ \alpha \to \beta $$ 같은 불안전한 타입이 다음 함수에 대해서 추론될
 수 있다.

```ocaml
fun x -> let y = x in y
```

 함수 타입을 추론하려면, 먼저 함수의 바디 `let y = x in y`의 타입을
 새로운 타입 변수 `'a`($$\alpha$$)가 도입된 타입 환경 `x:'a`에서
 추론한다. 위의 `let` 규칙에 의해서 `y`에 타입이 추론되는데,
 결과적으로 타입 `GEN(x:'a, 'a)`를 추론한다. 분명히 `'a`는 타입 환경
 `x:'a`에서 나타난다. 그럼에도 불구하고 여기에 양화를 해버리면, `y`는
 폴리모픽 타입 $$ \forall \alpha. \alpha$$를 받게 되고, 따라서 어떤
 타입으로든 인스턴스화 될 수 있다. 그 결과 함수는 표면적으로
 아규먼트를 그 어떤 타입으로 바꿀 수 있게 된다.

 따라서, 양화할 각각의 타입 변수에 대해서 우리는 반드시 **타입 환경에
 나타나지 않음**을 확인해야 한다. 나이브하게 생각하면, 그냥 타입
 환경을 다 스캔해서 모든 바인딩의 타입을 살펴볼 수 있다. 사실, 원래
 Caml이 정확히 이걸 구현했었다. 하지만 타입 환경은 엄청나게 커질 수
 있다. 일반적으로 ML 함수들은 아주 긴 `let` 표현식 시퀀스를 담고
 있다. 일반적인 `let`은 이전에 나타난 모든 `let`들의 바인딩을 타입
 환경에 갖고 있다. 재귀적인 `let`의 환경은 모든 `let` 형제(sibling)의
 바인딩을 갖고 있다. 하나의 `let`에 대한 일반화의 일부로 이 환경을
 스캔하면 함수 크기에 대해 선형 시간이 걸린다. 그러면 전체 프로그램의
 타입 체킹은 제곱이 된다. 레미가 회상하기로 비효율적인 일반화는 Caml
 컴파일의 느린 속도의 주된 이유 중 하나였다. 컴파일러를
 부트스트래핑하면서 패턴과 표현식을 컴파일하기 위해서 두 개의 상호
 재귀 함수를 타입 체킹하는 일은 거의 20분 걸렸다.

 타입 환경을 스캔하지 않는 방법이 있어야 한다.

## Unsound generalization as memory mismanagement

 여기서는 먼저 레미의 알고리즘 뒤에 있는 아이디어를 구역 기반 메모리
 관리와 관련지어 소개한다. 구체성을 위해서 토이 힌들리 밀너 타입
 추론기를 쓸 것이다. 여기서 추론기는 타입 환경을 고려하지 않고 타입의
 자유 타입 변수를 양화하는 *불안전한(unsound)* 일반화 함수를 갖고
 있다. 세 가지 간단한 예시를 타입 체크할 것이고, 불안전한 타입을
 추론하는 일을 수동 메모리 관리에서의 일반적인 문제와 연관지을 것이다:
 여전히 사용 중인 메모리를 해제하는 일이다. 불안전한 일반화는 이 다음
 섹션에서 수정되는데, 자원의 성급한 해제를 막는 표준적인 방법에서
 영감을 얻었다.

 우리의 힌들리 밀너 타입 추론기가 장난감이긴 하지만, 진짜 OCaml 타입
 체커의 많은 구현적인 결정(그리고 몇몇 함수 이름)을 공유한다. 이걸
 이해하면 나중에 OCaml 내부를 살펴볼 때 많은 도움이 된다.

 우리의 토이 언어는 표준적인 순수 람다 대수에 `let`을 추가한 것이다.

```ocaml
type exp =
    | Var of varname
    | App of exp * exp
    | Lam of varname * exp
    | Let of varname * exp * exp
```

 타입은 (자유 또는 묶인) 타입 변수, 양화된 타입 변수, 함수 타입으로
 구성된다.

```ocaml
type qname = string
type typ =
    | TVar of tv ref
    | QVar of qname
    | TArrow of typ * typ
and tv = Unbound of string | Link of typ
```

 `QVar` 타입은 타입 스키마이다. 즉, 단순 타입이 아니다. 힌들리 밀너
 시스템에서의 타입 스키마, 또는 양화된 타입은 전치형(prenex form), 즉
 보편 양화사가 모두 바깥에 붙는데, 그래서 양화사를 명시적으로
 표현해주지 않아도 된다.

 프롤로그 언어로부터 내려온 전통에 따라, 타입 변수는 레퍼런스 쎌로
 표현된다. 안묶인 변수(자유 변수)는 널 또는 셀프 포인터를 담고
 있다. 또는, 우리의 경우, 쉬운 출력을 위해서 변수 이름을 담고
 있다. 자유 타입 변수가 다른 타입 `t'`과 합쳐질 때(unified), 레퍼런스
 쎌은 `t'` 포인터로 덮어 써진다. 원형 타입(즉, 불안전한 타입)을 막기
 위해서, "나타나는지 체크(occur check)"를 먼저 수행한다. `occurs tv
 t'`는 `t'`를 탐색하면서 만약 타입 변수 `tv`를 만나면 예외를
 발생시킨다.

```ocaml
let rec unify : typ -> typ -> unit = fun t1 t2 ->
    if t1 == t2 then ()  (* t1 and t2 are physically the same *)
    else match (t1, t2) with
    | (TVar ({contents= Unbound _} as tv), t')
    | (t', TVar ({contents= Unbound _} as tv)) ->
        occurs tv t' ;
        tv := Link t'
    | (TVar {contents= Link t1}, t2) | (t1, TVar {contents= Link t2}) ->
        unify t1 t2
    | (TArrow (tyl1, tyl2), TArrow (tyr1, tyr2)) ->
        unify tyl1 tyr1 ;
        unify tyl2 tyr2
    (* everything else is error *)
```

 타입 체커는 완전히 표준적인 구현이다. 타입 환경 `env`에서의 표현식
 `exp`의 타입을 추론한다.

```ocaml
type env = (varname * typ) list
let rec typeof : env -> exp -> typ = fun env -> function
    | Var x -> inst (List.assoc x env)
    | Lam (x, e) ->
        let ty_x = newvar () in
        let ty_e = typeof ((x, ty_x) :: env) e in
        TArrow (ty_x, ty_e)
    | App (e1, e2) ->
        let ty_fun = typeof env e1 in
        let ty_arg = typeof env e2 in
        let ty_res = newvar () in
        unify ty_fun (TArrow (ty_arg, ty_res)) ;
        ty_res
    | Let (x, e, e2) ->
        let ty_e = typeof env e in
        typeof ((x, gen ty_e) :: env) e2
```

 `newvar` 함수는 새로운 `TVar`를 유니크한 이름으로 할당한다. `inst`
 함수는 타입 스키마를 인스턴스화하는데, 즉 모든 `QVar`를 새로운
 `TVar`로 대체한다. 이것도 표준적 구현이다. 일반화 함수는
 불안전(unsound)하다: 타입 환경과 상관없이 타입에 있는 모든 자유
 변수를 양화해버린다.

```ocaml
let rec gen : typ -> typ = function (* unsound! *)
    | TVar {contents= Unbound name} -> QVar name
    | TVar {contents= Link ty} -> gen ty
    | TArrow (ty1, ty2) -> TArrow (gen ty1, gen ty2)
    | ty -> ty
```

 양화는 `TVar`를 해당하는 `QVar`로 대체한다. 따라서 원래의 `TVar`는
 암묵적으로 해제(deallocated)된다: 자유 변수가 묶일 때, 말 그대로
 "사라지고(disappears)", 바인더를 가리키는 포인터로 대체된다. 즉,
 - `TVar`를 할당 (`newvar ()`) <-> 메모리 할당
 - `TVar`를 `QVar`로 대체 (양화, 즉 일반화) <-> 메모리 해제

 의 비유가 성립한다.

 타입 변수의 관점에서 보면, `typeof`는 자유 변수를 할당하고, 이것들을
 합친 다음, 양화를 한 다음 다시 해제한다. 자유 타입 변수에 영향을 주는
 이 세 가지 메인 연산의 시퀀스를 관찰할 수 있는 단순한 예시를 타입
 체크해보자. 첫 번째 예시는 아무 문제가 없어야 하는 예이다.

```ocaml
fun x -> let y = fun z -> z in y
```

 타입 체킹의 트레이스에서 타입 변수와 관계된 연산만 보여주면 다음과
 같다.

```ocaml
1 ty_x = newvar ()         (* fun x -> .... *)
2   ty_e =                 (* let y = fun z -> z in y *)
3     ty_z = newvar ();    (* fun z -> ... *)
3     TArrow (ty_z, ty_z)  (* inferred for: fun z -> z *)
2   ty_y = gen ty_e        (* ty_z remains free, and so *)
2   deallocate ty_z        (* quantified and disposed of *)
1 TArrow (ty_x, inst ty_y) (* inferred for: fun x -> ...*)
```

 각 줄에 있는 번호는 `typeof` 재귀 함수의 호출 깊이이다. `typeof`가
 AST의 리프가 아닌 각 노드에 대해서 재귀하기 때문에, 재귀 호출의
 깊이는 곧 아직 타입 체킹되지 않은 AST 노드의 깊이와 같다. 추론된
 타입은 예상대로 `'a -> 'b -> 'b` 이다. 아무 문제가 없다.

 두 번째 예시는 앞에서 본 것인데, 불안전한 일반화가 불안전한 타입 `'a
 -> 'b`를 추론하는 것이다.

```ocaml
fun x -> let y = x in y
```

 마찬가지로 `TVar` 연산 트레이스를 살펴보면 문제점이 드러난다.

```ocaml
1 ty_x = newvar ()         (* fun x -> .... *)
2   ty_e =                 (* let y = x in y *)
3     inst ty_x            (* inferred for x, same as ty_x *)
2   ty_y = gen ty_e        (* ty_x remains free, and is *)
2   deallocate ty_x        (* quantified and disposed of *)
1 TArrow (ty_x, inst ty_y) (* inferred for: fun x -> ...*)
```

 타입 변수 `ty_x`가 깊이 1에서 쓰였고 리턴 타입의 일부이다. 그런데
 양화되고 나서 깊이 2에서 버려진다. 여전히 쓰이고 있는 변수가 버려진
 것이다!

 세 번째 예시도 문제가 있다. 불안전한 일반화가 또 불안전한 타입 `('a
 -> 'b) -> ('c -> 'd)`를 추론해버린다.

```ocaml
fun x -> let y = fun z -> x z in y
```

 이 트레이스는 메모리 관리 문제를 또 보여준다.

```ocaml
1 ty_x = newvar ()           (* fun x -> .... *)
2   ty_e =                   (* let y = ... *)
3     ty_z = newvar ()       (* fun z -> ... *)
4       ty_res = newvar ()   (* typechecking: x z *)
4       ty_x :=              (* as the result of unify *)
4         TArrow (ty_z, ty_res)
4       ty_res               (* inferred for: x z *)
3     TArrow (ty_z, ty_res)  (* inferred for: fun z -> x z*)
2   ty_y = gen ty_e          (* ty_z, ty_res remain free *)
2   deallocate ty_z          (* quantified and disposed of *)
2   deallocate ty_res        (* quantified and disposed of *)
1 TArrow (ty_x, inst ty_y)   (* inferred for: fun x -> ... *)
```

 타입 변수 `ty_z`와 `ty_res`가 양화되고 난 후 깊이 2에서 버려지는데,
 여전히 `TArrow (ty_z, ty_res)` 타입의 일부로 할당되어 있는 채로
 `ty_x`에 할당되고 결과의 일부로 리턴된다.

 모든 불안전한 예시는 여전히 사용 중인 메모리(`TVar`)를 해제하는
 이른바 "메모리 관리 문제"를 보여준다. 타입 변수가 양화될 때, 나중에
 그 어떤 타입이든 간에 이것과 함께 인스턴스화 될 수 있다. 하지만, 타입
 환경에 나타나는 타입 변수는 나머지 타입 체킹에 영향을 주지 않고서는
 어떤 타입으로도 대체될 수 없다. 비슷하게, 우리가 메모리를 해제할 때,
 우리는 런타임에 그 메모리를 재할당해서 임의의 데이터로 덮어쓸 수 있는
 권한을 준다. 프로그램의 나머지 부분은 해제된 메모리에 어떤 식으로든
 의존해서는 안된다. 마치 정말로 해제된 것처럼 가정해서, 프로그램에서
 더 이상 필요하지 않은 것처럼 다뤄야 한다. 사실, "사용하지 않는
 메모리"는 프로그램의 나머지 부분에 영향을 미치지 않는 메모리에 대한
 임의의 변경으로 정의할 수 있다. 여전히 사용 중인 메모리를 해제하는
 것은 프로그램의 나머지 부분에 영향을 미쳐서, 크래시를 내기도
 한다. 덧붙여서, 위의 예시에서 추론된 불안전한 타입은 종종 동일한
 결과를 초래하기도 한다 (즉, 크래시 난다).

### 참조: 불안전한 타입 체커 전체 코드

```ocaml
type varname = string

type exp =
    | Var of varname
    | App of exp * exp
    | Lam of varname * exp
    | Let of varname * exp * exp

type qname = string
type typ =
    | TVar of tv ref
    | QVar of qname
    | TArrow of typ * typ
and tv = Unbound of string | Link of typ

let gensym_counter = ref 0
let reset_gensym : unit -> unit =
    fun () -> gensym_counter := 0

let gensym : unit -> string = fun () ->
    let n = !gensym_counter in
    let () = incr gensym_counter in
    if n < 26 then String.make 1 (Char.chr (Char.code 'a' + n))
        else "t" ^ string_of_int n

let newvar : unit -> typ =
    fun () -> TVar (ref (Unbound (gensym ())))

let rec occurs : tv ref -> typ -> unit = fun tvr -> function
    | TVar tvr' when tvr == tvr' -> failwith "occurs check"
    | TVar {contents= Link ty} -> occurs tvr ty
    | TTArrow (t1, t2) ->
        occurs tvr t1 ;
        occurs tvr t2
    | _ -> ()

let rec unify : typ -> typ -> unit = fun t1 t2 ->
    if t1 == t2 then ()
    else match (t1, t2) with
    | (TVar ({contents= Unbound _} as tv), t')
    | (t', TVar ({contents= Unbound _} as tv)) ->
        occurs tv t' ;
        tv := Link t'
    | (TVar {contents= Link t1}, t2) | (t1, TVar {contents= Link t2}) -> unify t1 t2
    | (TArrow (tyl1, tyl2), TArrow (tyr1, tyr2)) ->
        unify tyl1 tyr1 ;
        unify tyl2 tyr2
    (* everything else is error *)

type env = (varname * typ) list

let rec gen : typ -> typ = function
    | TVar {contents= Unbound name} -> QVar name
    | TVar {contents= Link ty} -> gen ty
    | TArrow (ty1, ty2) -> TArrow (gen ty1, gen ty2)
    | ty -> ty

let inst : typ -> typ =
    let rec loop subst = function
        | QVar name ->
            (try (List.assoc name subst, subst)
             with Not_found ->
                 let tv = newvar () in
                 (tv, (name, tv) :: subst))
        | TVar {contents= Link ty} -> loop subst ty
        | TArrow (ty1, ty2) ->
            let (ty1, subst) = loop subst ty1 in
            let (ty2, subst) = loop subst ty2 in
            (TArrow (ty1, ty2), subst)
        | ty -> (ty, subst)
    in
    fun ty -> fst (loop [] ty)

let rec typeof : env -> exp -> typ = fun env -> function
    | Var x -> inst (List.assoc x env)
    | Lam (x, e) ->
        let ty_x = newvar () in
        let ty_e = typeof ((x, ty_x)::env) e in
        TArrow (ty_x, ty_e)
    | App (e1, e2) ->
        let ty_fun = typeof env e1 in
        let ty_arg = typeof env e2 in
        let ty_res = newvar () in
        unify ty_fun (TArrow (ty_arg, ty_res)) ;
        ty_res
    | Let (x, e, e2) ->
        let ty_e = typeof env e in
        typeof ((x, gen ty_e)::env) e2
```

## Efficient generalization with levels

 여기서는 레미의 알고리즘 뒤에 있는 아이디어를 계속해서 설명한다. 이제
 우리는 불안전한 일반화가 아직 사용 중인 메모리를 해제하는 것과 어떻게
 관련되는지 보았기 때문에, 성급한 해제에 대한 표준적인 해결책인
 소유권(또는 구역; owership or regions) 추적을 적용해서 많은 오버헤드
 없이 이를 해결하려고 한다. 레미의 알고리즘의 주요 특징을 포착한
 최적의 방법인 `sound_lazy`는 다음에 나온다.

 분명히, 메모리를 해제하기 전에 메모리가 여전히 사용 중인지 반드시
 확인해야 한다. 나이브하게 구현하면, 우리는 해제 후보의 참조를 찾기
 위해서 지금 사용 중인 모든 메모리를 스캔할 수도 있다. 즉, 일종의 GC의
 전체 마킹 페이즈를 수행해서 후보가 마킹됐는지 확인할 수 있다. 이런
 식으로 하면, 이 확인 방법은 엄청나게 비쌀 것이다. 최소한 우리는
 가비지가 쌓일 때까지는 기다려야 한번에 수집할 수 있다. 아, 힌들리
 밀너 타입 시스템에서 우리는 양화를 임의로 지연할 수 없는데, 왜냐하면
 일반화된 타입은 아마 곧바로 쓰일 수 있기 때문이다.

 좀더 괜찮은 방법은 이른바 소유권(ownership) 추적이다: 할당된 자원을
 소유자, 개체, 또는 함수 활성화(activation)과 연결한다. 오직
 소유자만이 자원을 해제할 수 있다. 이것과 유사한 전략은 이른바 구역,
 즉 `letregion` 프리미티브로 사전적 범위로 지정된 힙 메모리의
 영역이다(areas of heap memory created by a lexically-scoped so-called
 `letregion` primitive). `letregion`이 범위를 벗어나면, 그 전체 영역이
 즉시 해제된다. 이 아이디어는 일반화와도 잘 맞는다. 힌들리 밀너
 시스템에서 일반화는 항상 `let`의 일부이다. `let x = e in e2` 에서의
 `let` 표현식은 `e`의 타입을 추론할 때 할당되는 모든 타입 변수의
 자연스러운 소유자이다. `e`의 타입이 발견되면, `let` 표현식이 소유하고
 있는 모든 자유 타입 변수는 버려질 수 있다. 즉, 양화될 수 있다.

 이러한 직관은 안전하고 효율적인 일반화 알고리즘의 기초가 된다. 먼저
 `sound_eager`를 설명한다. 이 방법의 구현은 이전의 작은 힌들리 밀너
 추론기에서 조금만 다르지만, 굉장히 중요하다. 여기서는 이 차이점만
 설명한다. 전체 코드는 밑에 있다. 주요한 차이점은 자유 타입 변수가
 안묶여있을(자유) 지라도, 이제 소유자에게 소유되어 소유자를 참조한다는
 것이다. 소유자는 항상 `let` 표현식이고, 이는 `level` 이라고 불리는
 양의 정수로 식별된다. 이것은 드 브루인(De Bruijin) 레벨 또는 해당
 `let` 표현식의 중첩되는 깊이를 나타낸다. 레벨 1은 암묵적으로 최상위의
 `let`에 해당한다. 참고로, `(let x = e1 in eb1, let y = e2 in eb2)`에
 있는 두 `let`은 모두 레벨 2를 갖지만, 두 `let` 모두 서로의 범위에
 없으므로 구역이 분리되어 있기 때문에 혼동이 발생할 수 없다. `let`
 중첩 깊이는 `let` 표현식의 타입 체킹 재귀 깊이와 동일하고 이는 하나의
 레퍼런스 쎌만 있으면 알아내기 쉽다.

```ocaml
type level = int
let current_level = ref 1
let enter_level () = incr current_level
let leave_level () = decr current_level
```

 타입 추론기는 이제 `let` 표현식을 타입 체킹할 때 깊이를 유지한다.

```ocaml
let rec typeof : env -> exp -> typ = fun env -> function
    ... (* the other cases are the same as before *)
    | Let (x, e, e2) ->
        enter_level () ;
        let ty_e = typeof env e in
        leave_level () ;
        typeof ((x, gen ty_e) :: env) e2
```

 메인 타입 추론 함수에서 바뀐 점은 `enter_level`과 `leave_level`
 함수를 호출해서 레벨을 추적하는 것 뿐이다. 나머지 부분은 그대로다.

 자유 타입 변수는 이제 그 소유자를 확인할 수 있는 레벨과 같이
 간다. 새로 할당된 타입 변수는 `current_level`을 통해 가장 최근에 타입
 체킹된 `let` 표현식, 즉 소유자를 알 수 있다. 구역 기반 메모리
 관리에서, 모든 새로운 메모리는 가장 안쪽의 살아있는 구역에 할당되는
 것과 같다.

```ocaml
type typ =
    | TVar of tv ref
    | QVar of qname
    | TArrow of typ * typ
and tv = Unbound of string * level | Link of typ

let newvar = fun () -> TVar (ref (Unbound (gensym (), !current_level)))
```

 대입 연산이 할당된 메모리 조각의 소유자를 바꿀 수 있는 것처럼,
 유니피케이션도 자유 타입 변수의 레벨(소유자)을 바꿀 수 있다. 예를
 들어, 만약 `ty_x` (레벨 1)과 `ty_y` (레벨 2)가 둘다 자유 변수이고
 `ty_x`가 `TArrow(ty_y, ty_y)`와 합쳐진다면, 이 함수 타입과 그
 구성요소는 구역 1로 내보내지고 따라서 `ty_y`의 레벨이 1로 바뀐다. 이
 유니피케이션이 모든 `ty_x`가 나타나는 것을 `TArrow(ty_y, ty_y)`로
 바꾸는 것이라고 볼 수도 있다. `ty_x`가 더 작은 레벨을 가지고 있고
 따라서 안쪽 구역인 레벨 2의 `let`보다 더 바깥에 나타나기 때문에, 안쪽
 `let` 표현식이 타입 체크되고 난 이후에도 `ty_y`는 해제되어서는
 안된다. `ty_y` 레벨이 업데이트되었다면 그렇지 않다. 대체로, 자유 타입
 변수 `ty_x`와 `t`를 합치려면 각각의 자유 타입 변수 `ty_y`의 레벨을
 `ty_y`와 `ty_x` 레벨 중 작은 값으로 업데이트해야 한다. 자유 타입
 변수를 `t`와 합치려면 또한 occurs check도 해야하는데, 이것도 타입
 트리를 탐색한다. 이 두 탐색은 합쳐질 수 있다. 새로운 `occurs` 함수는
 occurs check와 레벨 갱신을 동시에 한다.

```ocaml
let rec occurs : tv ref -> typ -> unit = fun tvr -> function
    | TVar tvr' when tvr == tvr' -> failwith "occurs check"
    | TVar ({contents= Unbound (name, l')} as tv) ->
        let min_level =
            (match !tvr with Unbound (_, l) -> min l l' | _ -> l') in
        tv := Unbound (name, min_level)
    | TVar {contents= Link ty} -> occurs tvr ty
    | TArrow (t1, t2) -> occurs tvr t1 ; occurs tvr t2
    | _ -> ()
```

 원래의 `occurs`와 다른 부분은 두 번째 패턴 매치 부분
 뿐이다. 유니피케이션 코드는 수정될 필요가 전혀 없다. 마지막으로,
 일반화 함수를 수정해서 안전하게 만들자.

```ocaml
let rec gen : typ -> typ = function
    | TVar {contents= Unbound (name, l)} when l > !current_level -> QVar name
    | TVar {contents= Link ty} -> gen ty
    | TArrow (ty1, ty2) -> TArrow (gen ty1, gen ty2)
    | ty -> ty
```

 아주 작은 수정인 `when l > !current_level` 조건만 추가되었다. 새로운
 `typeof` 코드를 다시 떠올려 보자.

```ocaml
let rec typeof : env -> exp -> typ = fun env -> function
    ...
    | Let (x, e, e2) ->
        enter_level () ;
        let ty_e = typeof env e in
        leave_level () ;
        typeof ((x, gen ty_e) :: env) e2
```

 `e`의 타입 체킹을 위해서 만든 구역에서 빠져나간 이후에 `gen`을
 호출하고 있다. 그 구역이 여전히 소유하고 있는 자유 타입 변수는 현재
 레벨보다 더 큰 레벨을 가질 것이다. 구역이 이제 죽었기 때문에, 그러한
 자유 변수는 해제될 수 있는데, 이는 곧 양화될 수 있다는 뜻이다.

 이게 불안전했던 알고리즘을 수정한 `sound_eager`의 전부이다. 이제
 불안전한 타입 추론을 해결했다. 이전에 문제가 되었던 예시를 다시
 살펴보자.

```ocaml
fun x -> let y = x in y
```

 `TVar` 연산과 관련된 흐름을 보면 이제 문제가 없다.

```ocaml
1  1  ty_x/1 = newvar ()           (* fun x -> ... *)
2  2    ty_e =                     (* let y = x in y *)
3  2      inst ty_x/1              (* inferred for x, same as ty_x *)
2  1    ty_y = gen ty_e            (* ty_x/1 remains free, but is level = current, can't quantify, can't dispose *)
1  1  TArrow(ty_x/1, inst ty_y)    (* inferred for: fun x -> ... *)
```

 한 가지 정보가 추가되었다. 컬럼의 첫 번째 숫자는 `typeof`의 재귀 깊이
 또는 아직 타입 체크되지 않은 AST 노드의 깊이를 나타내고, 두 번째
 숫자는 `current_level`, 즉 `let` 중첩 깊이를 나타낸다. 자유 타입
 변수의 레벨은 `ty_x/1`와 같이 슬래쉬 뒤에 표시한다. `ty_x/1`이 현재
 레벨, 즉 여전히 살아있는 구역 1에 속하기 때문에, 해당 변수는 더 이상
 깊이 2(레벨 1)의 `gen`에 의해 양화되지 않는다. 따라서, 추론된 타입은
 예상대로 `'a -> 'a`가 된다.

 좀더 복잡한 예시를 살펴보면

```ocaml
fun x -> let y = fun z -> x in y
```

 `x`의 타입을 위한 타입 변수 `ty_x`는 레벨 1에서 할당되는 반면,
 `ty_z`는 레벨 2에서 할당된다. 안쪽의 구역 2인 `let`이 끝난 이후에,
 `ty_z/2`는 양화되어 버려지지만, `ty_x/1`는 아니다. 따라서 추론된
 타입은 `'a -> 'b -> 'a`가 된다. 다이어그램을 그려보면 이게 안전하게
 추론된 타입이라는 것을 알 수 있다.

 레벨 추적은 레퍼런스 카운팅과 비슷하게 생겼을 수도 있다. 하지만, 자유
 타입 변수의 모든 사용자 수를 세는 것이 아니라, 우리는 딱 한명의
 유저만 추적하는데, 바로 가장 넓은 범위이다. 레벨 추적은 따라서 세대간
 가비지 콜렉션과 더 많이 닮아 있다: 메모리는 마이너 세대에서 할당되고,
 다른 부모가 할당되거나 스택이 참조하지 않는 이상 마이너 콜렉션에서
 한번에 버려진다. 메이저 세대는 새로운 세대에 대한 참조를 스캔할
 필요가 없는데, 왜냐하면 메이저 데이터 구조의 필드를 가리키는 마이너
 값(또는 이에 대한 포인터)의 대입 연산이 없는 이상 그런 참조는 없을
 것으로 예상되기 때문이다. OCaml GC와 같은 세대간 가비지 콜렉터는
 마이너 세대에서 메이저 세대로의 대입 연산을 추적한다. 마이너
 콜렉션에서, 메이저 데이터에서 참조된 마이너 데이터가 메이저 세대로
 승격된다. 타입 일반화는 실제로 마이너 GC와 매우 유사하다.

## Even more efficient level-based generalization

 여기서는 레미의 알고리즘의 핵심 아이디어를 계속해서 살펴보고
 `sound_lazy`를 설명한다. 이는 이전 섹션에서 살펴본 `sound_eager`의
 최적화된 버전이다. `sound_lazy` 알고리즘은 유니피케이션, 일반화,
 인스턴스화 도중 발생하는 반복되는 불필요한 타입 탐색을 피하고,
 일반화하거나 인스턴스화 하기 위해 변수를 포함하지 않는 부분을
 복사하는 것을 피해서 데이터 공유를 개선한다. 이 알고리즘은 occurs
 check과 레벨 갱신을 늦춰서 자유 타입 변수와의 유니피케이션이 상수
 시간이 걸리도록 한다. 레벨은 점진적으로 필요할 때에만
 갱신된다. `sound_lazy`는 레미의 알고리즘의 핵심 아이디어를 구현하고
 있다. 이 중 일부는 실제 OCaml 타입 체커에 구현되어 있다.

 최적화를 위해서 먼저 타입의 문법을 수정해야 한다. `sound_eager`에서는
 타입이 자유(`Unbound`) 또는 묶인(`Link`) 타입 변수 `TVar`,
 (암묵적으로 보편적) 양화된 타입 변수 `QVar`, 그리고 함수 타입
 `TArrow`로 구성되었던 것을 기억하자. 먼저, 겉보기에는 무의미한
 수정인데, `QVar`를 제거해서 별개의 대안인 아주 큰 양의 정수
 `generic_level`을 도입하는데, 이는 접근할 수 없는 서수 $$ \omega $$를
 의미한다. `generic_level`에 있는 자유 타입 변수 `TVar` 양화된 타입
 변수로 간주된다. 그리고, 이제 자유 타입 변수뿐만 아니라 모든 타입이
 레벨을 갖는다. 복합 타입(우리의 경우 `TArrow`)의 레벨은, 반드시
 정확하지는 않지만, 그 구성 요소의 레벨의 상한(Upper Bound)이
 된다. 즉, 만약 타입이 살아있는 구역에 속해있다면, 그 구성 요소도 모두
 살아있어야 한다. 따라서 (복합) 타입이 `generic_level`에 있으면, 이는
 양화된 타입 변수를 포함할 수 있다. 반대로, 만약 타입이
 `generic_level`에 없으면, 어떤 양화된 변수도 포함하지 않는다. 따라서,
 이런 타입을 인스턴스화 하면 타입을 탐색하지 않고 그대로 리턴해야
 한다. 마찬가지로, 타입의 레벨이 현재 레벨보다 더 크면, 일반화할 자유
 타입 변수를 포함하고 있을 수 있다. 반면에, 일반화 함수는 레벨이 현재
 레벨보다 작거나 같은 타입을 탐색해서는 안된다. 이것이 바로 레벨이
 어떻게 과도한 탐색과 타입의 재구축을 제거해서 공유를 개선하는데
 도움이 되는 첫 번째 예시이다.

 타입을 자유 타입 변수와 합칠 때는 타입의 레벨을 타입 변수의 레벨이 더
 작으면 해당 레벨로 업데이트해야 한다. 합성 타입에 대해서는 이런
 업데이트가 곧 타입의 모든 구성요소의 레벨을 재귀적으로 업데이트해야
 한다는 뜻이다. 이런 비싼 탐색을 늦추기 위해서, 우리는 합성 타입에 두
 개의 레벨을 저장해 둔다: `level_old`는 타입의 구성요소의 레벨에 대한
 상한이고; `level_new`는 `level_old`보다 작거나 같은 값으로 타입이
 업데이트 이후에 가져야하는 레벨 값이다. 만약 `level_new < level_old`
 라면, 타입은 보류 중인 레벨 갱신이 있다. `sound_lazy`의 타입 문법은
 따라서:

```ocaml
type level = int
let generic_level = 100_000_000  (* as in OCaml typing/btype.ml *)
let marked_level = -1            (* for marking a node, to check for cycles *)

lype typ =
    | TVar of tv ref
    | TArrow of typ * typ * levels
and tv = Unbound of string * level | Link of typ
and levels = {mutable level_old: level; mutable level_new: level}
```

 아직 `marked_level`은 설명하지 않았다. 각각의 자유 타입 변수와의
 유니피케이션에서 occurs check는 비싼 연산이라서 유니피케이션과 타입
 체킹 알고리즘의 복잡도를 올린다. 우리는 이제 이 체크를 전체 표현식이
 타입 체크될 때까지 늦출 것이다. 그러는 동안, 유니피케이션이 타입에서
 싸이클을 만들 수 있다. 타입 탐색은 이 싸이클을 탐색해야
 한다. `marked_level`은 임시로 합성 타입의 `level_new`로 할당되어
 타입이 탐색 중이라는 것을 알린다. 탐색 도중 `marked_level`을 만난다는
 것은 싸이클을 발견했다는 뜻이고, occurs check는 에러를
 알린다. 덧붙여서, OCaml 타입은 일반적으로 싸이클릭하다: 오브젝트와
 폴리모픽 배리언트를 타입 체킹할 때 재귀적인 타입이 발생하고,
 `-rectypes` 컴파일러 옵션이 켜져있으면 된다. OCaml 타입 체커는
 `marked_level`과 비슷한 트릭을 이용해서 싸이클을 찾아서 에러를
 막는다.

 `sound_lazy`의 유니피케이션은 몇 가지 중요한 차이점이 있다:

```ocaml
let rec unify : typ -> typ -> unit = fun t1 t2 ->
    if t1 == t2 then ()
    else match (repr t1, repr t2) with
    | (TVar ({contents= Unbound (_, l1)} as tv1) as t1,
      (TVar ({contents= Unbound (_, l2)} as tv2) as t2)) ->
          (* unify two free vars *)
          if l1 > l2 then tv1 := Link t2 else tv2 := Link t1
    | (TVar ({contents= Unbound (_, l)} as tv), t')
    | (t', TVar ({contents= Unbound (_, l)} as tv)) ->
        update_level l t' ;
        tv := Link t'
    | (TArrow (tyl1, tyl2, ll), TArrow (tyr1, tyr2, lr)) ->
        if ll.level_new = marked_level || lr.level_new = marked_level then
            failwith "cycle: occurs check" ;
        let min_level = min ll.level_new lr.level_new in
        ll.level_new <- marked_level ;
        lr.level_new <- marked_level ;
        unify_lev min_level tyl1 tyr1 ;
        unify_lev min_level tyl2 tyr2 ;
        ll.level_new <- min_level ;
        lr.level_new <- min_level ;
and unify_lev l ty1 ty2 =
    let ty1 = repr ty1 in
    update_level l ty1 ;
    unify ty1 ty2
```

 여기서 `repr`은 OCaml의 `Btype.repr`과 비슷하게 자유 변수 또는 생성된
 타입을 리턴하는 묶인 변수의 링크를 따라간다. OCaml과 다르게, 우리는
 경로 압축(유니온 파인드의 최적화 방법)을 적용한다. 유니피케이션
 함수는 더 이상 occurs check을 하지 않는다. 따라서, 우연히 만들어진
 싸이클을 찾도록 노력해야 한다. 자유 변수를 합치는 일은 이제 얕은
 `update_level` 이후에 변수를 바인드하여 상수 시간이 걸린다.

 `update_level` 함수는 최적화 알고리즘의 핵심 부분 중 하나이다. 이것은
 그저 타입의 레벨을 주어진 레벨로 업데이트할 것을 약속한다. 이것은
 상수 시간에 동작하고 타입 레벨이 오직 감소하기만 할 수 있는 불변식을
 유지한다. 타입 변수의 레벨은 즉각 갱신된다. 합성 타입에 대해서는
 `level_new`가 필요한 새로운 (더 작은) 레벨로 업데이트된다. 추가로,
 만약 이전의 `level_new`와 `level_old`가 같다면, 타입은
 `to_be_level_adjusted` 큐에 추가되어 구성 요소의 레벨을 나중에
 업데이트한다. 이런 작업 큐는 세대간 가비지 콜렉터의 마이너 세대로부터
 메이저 세대로의 대입 연산의 리스트와 닮아있다.

```ocaml
let to_be_level_adjusted = ref []

let update_level : level -> typ -> unit = fun l -> function
    | TVar ({contents= Unbound (n, l')} as tvr) ->
        assert (not (l' = generic_level)) ;
        if l < l' then tvr := Unbound (n, l)
    | TArrow (_, _, ls) as ty ->
        assert (not (ls.level_new = generic_level)) ;
        if ls.level_new = marked_level then failwith "occurs check" ;
        if l < ls.level_new then (
            if ls.level_new = ls.level_old then
                to_be_level_adujsted := ty :: !to_be_level_adjusted ;
            ls.level_new <- l
        )
    | _ -> assert false
```

 보류 중인 레벨 갱신은 반드시 일반화 이전에 수행되어야 한다. 결국 보류
 중인 갱신은 타입 변수의 레벨을 감소시킬 수 있는데, 즉 더 넓은
 구역으로 승격되어서 양화로부터 구해준다. 하지만 모든 보류 중인
 업데이트가 강제될 필요는 없다. 오직 `level_old > current_level` 인
 타입만 하면 된다. 그렇지 않으면, 타입은 현재 시점에서 일반화 가능한
 변수가 없게 되고, 레벨 갱신이 더 늦춰질 수 있다. 이런 강제된
 알고리즘은 `force_delayed_adjustments`에 구현되어 있다. 덧붙여, 만약
 합성 타입의 레벨 업데이트가 정말로 수행된다면, 타입은 탐색되어야
 한다. 두 `TArrow` 타입의 유니피케이션은 또한 이들을 탐색해야
 한다. 따라서, 유니피케이션은 원칙적으로는 그 과정에서 레벨을
 업데이트할 수도 있다. 하지만 해당 최적화는 구현되어 있지 않다.

 일반화 함수는 죽은 구역에 속한 (즉, 레벨이 현재 레벨보다 큰) 자유
 `TVar`를 찾고 그들의 레벨을 `generic_level`로 설정해서 변수를
 양화한다. 함수는 오직 타입이 일반화 해야할 타입 변수를 담고 있을 수
 있는 부분만 탐색한다. 만약 타입이 (새로운) 현재 레벨 `current_level`
 또는 이보다 작은 레벨을 갖고 있다면, 그 타입의 모든 구성요소는
 살아있는 구역에 속해있고 따라서 일반화할 게 없다. 일반화가 끝난 뒤에
 만약 양화된 타입 변수를 담고 있으면 합성 타입은 `generic_level`을
 받는다. 나중에 인스턴스화 함수는 따라서 레벨이 `generic_level`인
 타입만 살펴보면 된다.

```ocaml
let gen : typ -> unit = fun ty ->
    force_delayed_adjustments () ;
    let rec loop ty =
        match repr ty with
        | TVar ({contents= Unbound (name, l)} as tvr) when l > !current_level ->
            tvr := Unbound (name, generic_level)
        | TArrow (ty1, ty2, ls) when ls.level_new > !current_level ->
            let ty1 = repr ty1 and ty2 = repr ty2 in
            loop ty1 ;
            loop ty2 ;
            let l = max (get_level ty1) (get_level ty2) in
            (* set the exact level upper bound *)
            ls.level_old <- l ;
            ls.level_new <- l
        | _ -> ()
    in loop ty
```

 테입 체커의 `typeof`는 수정하지 않아도 된다. 여전히 `let` 표현식을
 타입 체킹할 때 새로운 구역에 들어가야 한다.

 여기까지, 최적화된 `sound_lazy` 타입 일반화 알고리즘을 통해
 일반화마다 타입 환경 전체를 스캐닝 하지 않아도 될 뿐만 아니라 각각의
 자유 타입 변수와의 유니피케이션에서 occurs check도 피할 수
 있었다. 결과적으로 유니피케이션에 상수 시간이 소요된다. 알고리즘은
 불필요한 타입 탐색과 복사를 줄여서 시간과 공간을 절약했다. 자유 타입
 변수를 위한 타입 레벨 외에도 두 개의 아이디어가 최적화의 뿌리가
 된다. 하나는 합성 타입의 레벨을 배치해서 타입을 살펴보지 않고도
 타입이 무엇을 담고 있을지를 확인하는 것이다. 다른 하나는 비싼 연산인
 타입 탐색을 늦춰서 나중에 다른 작업이랑 같이 하는 것이다. 즉, 문제를
 해결하는 일이 충분히 미뤄진다면, 어쩌면 사라질 수도 있다: 미루는 것이
 때로는 도움이 된다.

## Inside the OCaml Type Checker
### Generalization with levels in OCaml

 여기서는 OCaml 타입 체커의 타입 레벨 구현과 효율적인 일반화에 대한
 적용을 설명한다.

 OCaml의 타입 일반화 뒤에 있는 아이디어는 이전에 설명한
 `sound_eager`와 `sound_lazy`와 같다. 이 코드들은 일부러 OCaml의 타입
 체커와 닮도록 구현했었다. OCaml 타입 체커는 `sound_eager` 알고리즘을
 구현했고 `sound_lazy` 에서 약간의 최적화를 적용했다. OCaml은 훨씬 더
 복잡하다: 토이 코드에서의 유니피케이션은 몇 줄 안되었지만, OCaml의
 유니피케이션 코드 (`ctype.ml`)는 1,634 줄이다. 그럼에도 불구하고 앞의
 핵심 아이디어를 이해하는 것은 OCaml 타입 체커를 해석하는데 도움이
 된다.

 `sound_eager` 알고리즘과 마찬가지로 OCaml 타입 체커는 occurs check와
 레벨 업데이트를 각각의 자유 변수와의 유니피케이션에서
 수행한다. `Ctype.unify_var` 코드에서 확인할 수 있다. 반면에,
 `sound_lazy`에서 했던 것처럼, OCaml 타입 체커는 모든 타입에 레벨을
 할당한다. `types.mli`의 `type_expr`에서 볼 수 있다. 이러는 이유는
 로컬 타입 생성자가 지역을 벗어나는 것을 감지하기 위함이다. 또
 `sound_lazy`처럼, `generic_level`이 양화된 타입 변수와 양화된 변수를
 담고 있을 수 있는 타입을 구분한다. 즉, 이른바 제네릭 타입이라고
 불리는 녀석이다. 따라서, 스키마 인스턴스화 함수인 `Ctype.instance`와
 `Ctype.copy`는 타입의 제네릭이 아닌 부분을 탐색하거나 복사하지 않고,
 그대로 리턴하여 공유를 개선한다. `generic_level`에 있는 타입 변수는
 `'a`와 같이 출력된다. 다른 레벨은 `'_a`와 같이 출력된다. 우리의 토이
 알고리즘에서 봤듯이, 가변 글로벌 `Ctype.current_level`이 현재 레벨을
 추적하고 새롭게 생성된 타입이나 타입 변수에 할당된다. `Ctype.newty`와
 `Ctype.newvar`에서 볼 수 있다. `current_level`은 `enter_def()` 함수로
 증가되고 `end_def()` 함수로 감소된다. `current_level` 외에도
 `nongen_level`이라는 게 있는데, 클래스 정의를 타입 체킹할 때
 쓰인다. `global_level`은 타입 선언에 있는 타입 변수에 쓰인다.

 `let x = e in body` 표현식을 타입 체킹하는 아주 단순화된 코드는
 다음과 같다.

```ocaml
let e_typed =
    enter_def () ;
    let r = type_check env e_source in
    end_def () ;
    r
in
generalize e_typed.exp_type ;
let new_env = bind env x e_typed.exp_type in
type_check new_env body_source
```

 여기서 `e_source`는 AST 또는 `Parsetree.expression`인데 `e`를 위한
 표현식이다. `e_typed`는 `Typedtree.expression`으로 `exp_type` 필드로
 추론된 타입을 각 노드에 어노테이트하고 있는 AST이다.

 따라서, OCaml 타입 체커에서 자주 보이는 전체적인 타입 일반화 패턴은
 다음과 같다.

```ocaml
let ty =
    enter_def () ;
    let r = ... let tv = newvar () in ... ( ...tv ... )
    end_def () ;
    r in
generalize ty
```

 만약 `tv`가 `enter_def()` 이전에 타입 환경에 존재하는 다른 것과
 합쳐지지 않는다면, 변수는 일반화 될 것이다. 이 코드는 우리의 토이
 코드와 매우 닮았다.

 흥미롭게도, 레벨은 다른 용법이 있는데, 로컬 타입 선언을 위한 구역
 규칙을 강제하는 것이다.

### Type Regions

 OCaml 타입 체커는 또한 타입이 선언되기 전에 쓰이지 않고 지역적으로
 도입된 타입이 더 넓은 범위로 빠져나가지 않도록 확인하기 위해서 타입
 레벨에 의존하고 있다. 대입 연산과 비슷하게, 유니피케이션은 두 가지를
 모두 용이하게 한다. 우리는 타입 레벨이 구역 기반 메모리 관리와 어떻게
 관계되어 있는지를 봤다. 그래서 레벨이 유니피케이션을 억제하는데
 도움이 되어서 자원의 잘못된 관리를 막는 것은 놀랍지 않다. 이번에는,
 타입 변수가 아니라 타입 상수일 뿐이다.

 SML과 다르게 OCaml 에서는 로컬 모듈 또는 로컬 범위에 정의된 모듈을
 지원한다. 문법은 `let module` 형태이다. 로컬 모듈은 타입을 선언하거나
 심지어는 이 타입을 이스케이프하게 하기도 한다.

```ocaml
let y =
    let module M = struct
        type t = Foo
        let x = Foo
    end
in M.x
   ^^^
Error: This expression has type M.t but an expression was expected of type 'a
       The type constructor M.t would escape its scope
```

 이런 이스케이프는 에러다. 그렇지 않으면 `y`는 `M.t` 타입을 받게
 되는데 `M.t`와 심지어 `M` 마저도 `y`의 범위에 있지 않게 된다. 이
 문제는 마치 C 함수에서 자동 지역 변수의 주소를 리턴하는 것과
 비슷하다.

```c
char * esc_res(void) {
    char str [] = "local string";
    return str;
}
```

 지역적으로 선언된 타입은 결과 타입 뿐만 아니라 존재하는 타입 변수와의
 유니피케이션을 통해서도 빠져나갈 수 있다.

```ocaml
fun y ->
    let module M = struct
        type t = Foo
        let r = y Foo
    end
in ()
                  ^^^
Error: This expression has type t but an expression was expected of type 'a
       The type constructor t would escape its scope
```

 이런 종류의 에러는 C 프로그래머에게는 익숙할지도 모르겠다.

```c
char *y = (char*)0;
void esc_ext(void) {
    char str [] = "local string";
    y = str;
}
```

 심지어 탑 레벨의 모듈도 타입이 빠져나가는 문제가 생길 수 있다. 다음
 예시는 OCaml 타입 체커 코드의 코멘트에서 가져왔다.

```ocaml
let x = ref []
module M = struct
    type t
    let _ = (x : t list ref)
end
```

 변수 `x`는 제네릭이 아닌 타입 `'_a list ref`를 가지고 있다. 모듈
 `M`은 로컬 타입 `t`를 정의한다. 타입 속성은 `t` 이전에 정의된 `x`를
 타입 `x : t list ref`를 갖게 만든다. `t`가 정의되기 전에 쓰인 것처럼
 보인다. 이런 타입 이스케이핑 문제는 심지어 모듈이 아니어도 발생할 수
 있다.

```ocaml
let r = ref []
type t = Foo
let () = r := [Foo]
               ^^^
Error: This expression has type t but an expression was expected of type 'weak1
       The type constructor t would escape its scope
```

 OCaml은 이런 탈출을 그대로 내버려둘 수가 없다. 어떤 경우에도 타입
 생성자는 선언된 범위 밖에서 사용될 수 없다. 타입 레벨은 이런 구역
 같은 원칙을 타입 생성자에 강제한다.

 OCaml 타입 체커는 이미 타입 일반화를 위해서 구역을 지원하는데,
 `begin_def`로 새 구역에 진입하고 `end_def`로 새 구역을
 벗어난다(파괴한다). 그리고 구역의 소유자에게 타입을 연결해서
 유니피케이션이 수행되는 동안 소유권의 변경을 추적한다. 남은 것은 타입
 선언이 새 구역에 들어가고 선언된 타입 생성자가 이 구역과 연결하는
 것이다. 이 타입 생성자가 나타나는 모든 구역은 타입 선언 구역 내의
 구역에 속해야 한다. 타입 생성자의 선언은 모든 사용 이전에 나타나야
 한다(dominate).

 이전에 설명했듯이, 타입 구역은 양의 정수인 타입 레벨로 식별된다. 이는
 구역의 중첩된 깊이이다. 각각의 타입은 `level` 필드가 있어서 소유된
 구역의 레벨을 알 수 있다. 타입 생성자는 이거랑 비슷한 레벨
 어노테이션이 필요하다. OCaml의 다른 기능이 정확히 이 목적을
 제공한다는 것이 밝혀졌다. 타입 생성자, 데이터 생성자, 텀 변수는 OCaml
 프로그램 안에서 재정의 될 수 있다. 타입은 재선언될 수 있고, 변수는
 여러 번 다시 묶일 수 있다. OCaml은 *식별자(identifier)*
 (`ident.ml`)에 의존하는데, 이를 통해 같은 이름으로 나타나지만
 실제로는 다르게 선언되거나 묶인 것들을 구별할 수 있다. 식별자는
 이름과 양의 정수인 타임 스탬프를 갖고 있다. 글로벌 가변
 `Ident.currentstamp`는 현재 시간을 추적하고 새로운 식별자가 선언 또는
 바인딩으로 생성되면 이를 증가시킨다. 식별자의 타임스탬프는 따라서
 그게 바인딩 타임(binding time; 묶인 시간)이다. 바인딩 타임은 식별자를
 타입 구역에 연결하는 자연스러운 방법이다. 만약 현재 시간이 현재
 레벨로 설정되어 있다면, 새로운 식별자는 현재 레벨보다 더 작은 바인딩
 타임을 가질 수 없다. 이들은 현재 타입 구역에 소유된 것으로
 간주된다. 빠져나가지 않는다는 것(non-escaping)은 곧 타입의 레벨이
 타입 안에 있는 각각의 타입 생성자의 바인딩 타임보다 작지 않다는 것을
 뜻한다.

 유니피케이션, 구체적으로는 자유 타입 변수와의 유니피케이션은 할당과도
 비슷한데, 타입의 소유자를 바꿀 수 있어서 이에 따라 타입 레벨을
 업데이트 해줘야 한다. 동시에 이는 빠져나가지 않는 성질(non-escaping
 property)가 여전히 유효한지 검사한다. `Ctype.update_level`에서 볼 수
 있다.

 이제 우리는 로컬 모듈, 즉 `let module name = modl in body` 표현식을
 타입 체킹하기 위한 OCaml 코드를 이해할 수 있다. `typecore.ml`에서
 발췌했다.

```ocaml
    | Pexp_letmodule(name, smodl, sbody) ->
        let ty = newvar () in
        (* remember the original level *)
        begin_def () ;
        Ident.set_current_time ty.level ;
        let context = Typetexp.narrow () in
        let modl = !type_module env smodl in
        let (id, new_env) = Env.enter_module name.txt modl.mod_type env in
        Ctype.init_def (Ident.current_time()) ;
        Typetexp.widen context ;
        let body = type_expect new_env sbody ty_expected in
        (* go back to original level *)
        end_def () ;
        (* Check that the local types declared in modl don't escape
           through the return type of body *)
        begin try
            Ctype.unify_var new_env ty body.exp_type
        with Unify _ ->
            raise (Error (loc, Scoping_let_module (name.txt, body.exp_type)))
        end ;
        re {
            exp_desc = Texp_letmodule (id, name, modl, body) ;
            exp_loc = loc ;
            exp_extra = [] ;
            exp_type = ty ;
            exp_env = env }
```

 타입 변수 `ty`는 표현식의 추론된 타입을 받기 위해서 생성된다. 변수는
 현재 구역에서 생성된다. 그러고 나면 `begin_def()`로 새로운 타입
 구역에 들어가게 되고 식별자 타임스탬프 클럭이 새로운
 `current_level`로 지정된다.

### Discovery of levels
### Creating fresh type variables
### True complexity of generalization
