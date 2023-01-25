---
layout: page
tags: [problem-solving, leetcode, python]
title: Parsing a Boolean Expression
last_update: 2023-01-25 18:33:46
---

# [Parsing a Boolean Expression](https://leetcode.com/problems/parsing-a-boolean-expression/)

 문자열로 주어진 불리언 표현식 `expression`을 평가해서 결과를 구하자.

 표현식은 다음으로 구성된다:
 - `"t"`: 참
 - `"f"`: 거짓
 - `"!(expr)"`: 논리적 NOT. 피연산자는 1개이다.
 - `"&(expr1,expr2,...)"`: 논리적 AND, 괄호 안의 피연산자는 2개 이상일
   수 있다.
 - `"|(expr1,expr2,...)"`: 논리적 OR, 괄호 안의 피연산자는 역시 2개
   이상이다.

 표현식의 길이 범위는 $$ 1 \sim 2 \times 10 ^4 $$ 이고 표현식은 오직
 `'(', ')', ',', '!', '&', '|', 't', 'f'` 글자로만 구성된다. 항상
 유효한 표현식이 입력으로 들어옴이 보장된다.

## 폴린드 표기법, 혹은 전위 표기법 - Polish Notation, or Prefix Notation

 문법이 주어진 형태부터가 [폴란드
 표기법](https://en.wikipedia.org/wiki/Polish_notation)이다. 적당히
 컴마만 무시한 다음 폴란드 표기법의 정의에 따라 스택을 이용해서 파싱과
 동시에 평가하면 될 것 같다.

 먼저 표현식을 토큰 리스트로 짜르는 함수를 구현하자. 얘는 컴마를
 무시한다.

```python
def tokenize(expr):
    tokens = []
    for tok in expr:
        if tok != ',':
            tokens.append(tok)
    return tokens
```

 이렇게 구한 토큰 배열은 이미 그 자체로 폴란드 표기법이라고 할 수
 있다. 이제 이걸 스택을 이용해서 적당히 파싱하는 함수를 만들자.

```python
def parse(tokens):
    CONST = {'t': True, 'f': False}
    OPS = {'!', '&', '|'}
    stack = []
    for tok in tokens:
        if tok in CONST:
            stack.append(CONST[tok])
        elif tok in OPS:
            stack.append(tok)
        elif tok == ')':
            operands = []
            while isinstance(stack[-1], bool):
                operands.append(stack.pop())
            op = stack.pop()
            if op == '!':
                stack.append(not operands.pop())
            elif op == '&':
                stack.append(all(operands))
            elif op == '|':
                stack.append(any(operands))
    return stack.pop()
```

 이전에 했던 역폴란드 표기법의 `parse` + `eval`함수와 거의 유사하지만,
 여기서는 굳이 두 스텝을 나눌 필요가 없어서 곧바로 평가하고
 있다. 괄호의 시작은 무시해도 되고, 만약 괄호의 끝에 도달했다면,
 스택에서 첫번째 연산자를 만나기 전까지 추가된 모든 값(불리언)은
 피연산자이고, 피연산자 바로 다음에 있는게 바로 연산자가 된다. 이때
 유효한 표현식만 들어옴이 보장되므로 굳이 `!` 연산자를 평가할 때
 피연산자 개수를 체크해주지 않아도 된다. `&`와 `|`의 경우 파이썬의
 `all`과 `any`를 이용해서 피연산자 전체에 대해서 빠르게 평가할 수
 있다.

 그러면 실제 구현은 다음과 같다.

```python
def parseBoolExpr(expression):
    return parse(tokenize(expression))
```


## 해킹

 그런데 위의 풀이 방법을 보면 알겠지만, 애초에 들어오는 표현식 자체가
 항상 유효한 폴란드 표기법임이 보장되기 때문에, 다음과 같은 해킹이
 가능하다:
 - `!(expr)` -> `not (expr)`로 바꿈
 - `&(exprs)` -> `all([exprs])`로 바꿈
 - `|(exprs)` -> `any([exprs])`로 바꿈

 파이썬에서도 리스트 구분자는 `,` 이기 때문에, 이렇게 바꾼 식은 그
 자체로 유효한 파이썬 표현식이 되고, 곧바로 파이썬의 `eval`을 먹일 수
 있다 (...). 이때 한 가지 해킹으로, `!`의 경우 `not (expr)`로 바꾸면
 안의 `expr`이 복잡한 식인 경우 유효하지 않은 파이썬 표현식이 될 수
 있으므로, `not (expr) == not any([expr]) == not all([expr])` 임을
 이용해서 `not &` 또는 `not |`으로 바꾸는 해킹을 하면 된다. 또한 닫힌
 괄호도 잘 바꿔주는 것을 잊지 말자.

```python
def parseBoolExpr(expression):
    hacked = expression.replace('t', 'True').replace('f', 'False').replace('!', 'not &').replace('&(', 'all([').replace('|(', 'any([').replace(')', '])')
    return eval(hacked)
```
