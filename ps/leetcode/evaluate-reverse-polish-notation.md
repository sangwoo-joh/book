---
layout: page
tags: [problem-solving, leetcode, python, stack]
title: Evaluate Reverse Polish Notation
---

# [Evaluate Reverse Polish Notation](https://leetcode.com/problems/evaluate-reverse-polish-notation/)

 역 폴란드 표기법으로 작성된 수식을 평가하고 결과 값을 계산하자.

 연산은 사칙연산만 주어지며, 나눗셈은 소숫점을 버림하여 계산한다.

 입력으로 주어지는 식은 모두 유효한 역 폴란드 표기법임이 보장된다.

## RPN

 [계산기 문제](../basic-calculators)의 `eval` 함수를 그대로 구현하면
 된다. 단, 여기서는 이항 연산자 `-`와 단항 연산자 `-`가 아예
 구분되어서 입력으로 들어온다. 즉, `[2, 1, -]`는 이항 연산이고,
 `[-1]`은 단항 연산이다. 수식을 파싱할 때 양수인지 음수인지를 확인해야
 한다. 파이썬에서는 문자열을 곧바로 `int()`로 파싱하면 양수/음수 모두
 가능한데, 이때 숫자가 아니라면 `ValueError` 예외가 발생한다. 이
 성질을 이용해서 구현하면 다음과 같다.

```python
def evalRPN(tokens):
    stack = []
    binop = {
        '+': lambda x, y: x+y,
        '-': lambda x, y: x-y,
        '*': lambda x, y: x*y,
        '/': lambda x, y: int(x/y),
    }

    for tok in tokens:
        try:
            stack.append(int(tok))
        except ValueError:
            y = stack.pop()
            x = stack.pop()
            stack.append(binop[tok](x, y))
    return stack.pop()
```
