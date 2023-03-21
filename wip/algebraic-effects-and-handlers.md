---
layout: page
tags: [ocaml, effect-handler, wip]
title: An Introduction to Algebraic Effects and Handlers
---

# An Introduction to Algebraic Effects and Handlers

 *대수적 효과(Algebraic effects)*는 순수하지 않은(impure) 동작이 가변
 저장 연산인 `get`과 `set`, 인터랙티브 입출력 연산인 `read`와 `print`,
 또는 예외 처리 연산인 `raise`와 같은 일련의 *연산*에서 발생한다는
 전제에 기반한 계산 효과에 대한 접근 방식입니다. 이는 자연스럽게 예외
 처리 뿐만 아니라 모든 다른 효과를 위한 *핸들러*를 필요로 하는데, 다른
 무엇보다도 스트림 재지정(redirection), 백트래킹, 협력적 멀티 쓰레딩,
 그리고 구분된 컨티뉴에이션을 캡쳐할 수 있는 새로운 개념을 떠올리게
 합니다.

 대수적 효과나 핸들러에 관심이 있어하지만 무엇부터 시작해야하는지
 모르는 사람들이 많습니다. 이 튜토리얼이 그걸 제공했으면
 좋겠습니다. 대수적 효과와 핸들러를 이용해서 어떻게 프로그램을 짜는지,
 어떻게 모델링하는지, 어떻게 이해해야 하는지를 살펴봅니다.

## 1. 언어

 핸들러를 살펴보기 전에 일단 쓸 언어를 먼저 정합시다. 효과를 다룰 때
 평가의 순서는 중요하기 때문에, 우리는 언어의 터미널을 불변의
 *값(values)*과 잠재적으로 효과가 있는 *계산(computations)*으로
 나누어서 *고운 값 호출(fine-grained call-by-value)* 접근을 따를
 것입니다. 몇 가지 언급해야 하는 것들이 있습니다:

```
value v := x                                                  variable
          | true | false                                      boolean constans
          | fun x -> c                                        function
          | h                                                 handler
handler h := handler { return x -> cr,                       (optional) return clause
             op1(x; k) -> c1, ..., opn(x; k) -> cn }      operation clauses
computation c := return v                                     return
               | op(v; y.c)                                   operation call
               | do x <- c1 in c2                             sequencing
               | if v then c1 else c2                         conditional
               | v1 v2                                        application
               | with v handle c                              handling
```

### 연속 계산
 연속 계산 (sequencing) `do x <- c1 in c2`는 먼저 `c1`을 평가하고, 그
 결과로 값이 리턴되면, `x`에 그 값을 묶은(bind) 다음 `c2`를
 평가합니다. 만약 `c2`에 `x`가 나타나지 않으면, 문법을 `c1; c2`와 같이
 요약해서 연속적인 계산을 표현할 수 있습니다.

### 연산 호출
 `op(v; y.c)` 호출은 *매개변수* 값 `v`(예를 들면 읽을 메모리 주소)를
 연산 `op`에 전달하고, `op`가 효과를 수행(perform) 하고, 그 *결과*
 값(예를 들면 메모리 주소의 내용물)이 `y`에 묶이고(bound),
 *컨티뉴에이션(continuation)*이라고 불리는 `c`의 평가를
 재개합니다. 하지만, 주변의 핸들러가 이 동작을 덮어쓸 수 (override)
 있음을 주의합시다.

### 제네릭 효과
