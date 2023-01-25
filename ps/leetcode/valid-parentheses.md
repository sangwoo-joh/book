---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Valid Parentheses
---

# [Valid Parentheses](https://leetcode.com/problems/valid-parentheses/)

 `(){}[]` 괄호만 담고있는 문자열이 주어졌을 때, 이 입력 문자열이
 유효한지 검사하자.
 - 열린 괄호는 반드시 같은 종류의 닫힌 괄호와 짝이 맞아야 한다.
 - 괄호는 반드시 열린 순서대로 닫혀야 한다.

 문자열의 길이는 1~10,000이다.

 예를 들어, `()`는 유효하고 `{]`는 유효하지 않다.

## 스택

 괄호 문제는 스택과 문자열을 섞은 근본있는 문제다. 스택에는 열린
 괄호만 추가하면서 지금 커서가 닫힌 괄호를 만났을 때 짝이 맞으면
 제거한다. 그렇지 않으면 다음 세 가지 예외 케이스를 처리하면서
 짝맞추기를 해나가면 된다.
 1. 스택은 비었는데 닫힌 괄호를 만난 경우 (예: `())`)
 2. 스택의 꼭대기에 있는 괄호랑 짝이 맞지 않는 경우 (예: `(]`)
 3. 모든 문자열을 다 검사했는데도 스택이 비어있지 않은 경우 (예: `()(`)

```python
def isValid(s):
    stack = []
    opens = set(["(", "[", "{"])
    closedmap = {"(": ")", "[": "]", "{": "}"}
    for p in s:
        if p in opens:
            stack.append(p)
        else:
            if not stack or closedmap[stack[-1]] != p:
                # handle 1 and 2
                return False
            else:
                stack.pop()
    return not stack # handle 3
```

 - 조금이라도 빠르게 열린 괄호인지 확인하기 위해서 해시 셋을 썼다.
 - 스택의 꼭대기에 있는 열린 괄호와 지금 만난 닫힌 괄호가 짝이
   맞는지를 빠르고 읽기 쉽게 확인하기 위해서 해시 테이블을 썼다.
 - 마지막 리턴 시에 스택이 비어있는지를 확인해야 하는데, 파이썬에서는
   `not` 키워드를 붙여서 강제로 불리언으로 타입 캐스팅을 했다.
