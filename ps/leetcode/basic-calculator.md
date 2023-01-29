---
layout: page
tags: [problem-solving, leetcode, python, stack]
title: Basic Calculators
---

# Basic Calculators
 - [Basic Calculator](https://leetcode.com/problems/basic-calculator/)
 - [Basic Calculator II](https://leetcode.com/problems/basic-calculator-ii/)
 - [Basic Calculator III](https://leetcode.com/problems/basic-calculator-iii/)

 수식을 표현하는 문자열을 평가하고 그 결과 값을 구하는 문제들이다.

 정수 나눗셈은 버림하여 정수로 계산한다.

 모든 수식이 유효한 수식이라고 가정해도 된다. 수식을 계산하는 과정에서
 생기는 모든 중간 결과와 최종 결과 값은 32비트 정수 범위 안에 포함됨이
 보장된다.

 문자열 수식을 곧바로 평가할 수 있는 파이썬의 `eval()`같은거 쓰지말고
 정정당당하게 계산하자.

## 역폴란드 표기법, 또는 후위 표기법 - Reverse Polish Notation, or Postifx Notation

 Basic Calculator 문제들은 모두 하나의 궁극적인 솔루션이
 존재한다. 중위 표기법으로 들어오는 수식을 [역폴란드
 표기법](https://en.wikipedia.org/wiki/Reverse_Polish_notation)으로
 바꾼 후에 스택 머신을 통해 계산하는 것이다.

 중위 표기법은 사람이 쓰고 이해하기에는 직관적이고 편리하지만,
 기계적으로 처리하기에는 모호한 부분이 많다.
 - `1 + 2 * 3`과 같은 수식은 `(1 + 2) * 3` 또는 `1 + (2 * 3)`으로
   해석될 수 있는 모호함이 있다. 이를 해결하기 위해서 괄호나 연산자
   우선순위가 도입되지만, 기계적으로 처리하기 귀찮다.
 - 반면 RPN으로는 위의 첫 번째 수식은 `1 2 + 3 *`으로, 두 번째 수식은
   `1 2 3 * +`으로 표기되기 때문에 모호함이 없다.
 - 또한 RPN은 스택 머신을 통해 평가하기가 매우 쉽다. RPN 토큰을
   훑으면서 숫자(피연산자)는 스택에 넣는다. 연산자를 만나면 스택에서
   피연산자를 꺼내서 계산(평가)한 후 다시 스택에 넣으면 된다. 모든
   수식을 다 훑고 나면 스택에 있는 값이 바로 계산 결과가 된다. 참고로
   많은 가상 머신들이 스택 머신 모델을 사용하고 있다.

 그래서, 일단 수식이 RPN으로 들어왔다고 가정하면, 이 수식을 평가하는
 함수는 매우 자명하다.

```python
def eval_(rpn):
    stack = []
    for tok in rpn:
        if isinstance(tok, int):
            stack.append(tok)
        elif tok in binary_operators:
            x2 = stack.pop()
            x1 = stack.pop()
            y = binary_operator[tok](x1, x2)
            stack.append(y)
        elif tok in unary_operators:
            x = stack.pop()
            y = unary_operator[tok](x)
            stack.append(x)
    return stack.pop()
```
 - 이항 연산과 단항 연산을 구분하고 있는 점을 눈여겨보자. 단항 연산의
   예는 `-`가 있다. 다만, `-` 토큰만으로는 이항 연산 `-`와 단항 연산
   `-`를 구분하기 힘들기 때문에, 전처리(파싱) 단계에서 이 둘을
   구분하도록 하는 것이 좋다.
 - 이항 연산의 경우, 피연산자의 순서에 주목하자. 스택(메모리)은
   FILO이므로 꺼내는 순서의 역순으로 함수에 넘겨줘야 한다. `+`나 `*`는
   교환법칙(Commutative Law)가 성립하기 때문에 상관없지만, `-`와 `/`는
   교환법칙이 성립하지 않기 때문에 이 순서를 틀리면 결과가 어그러진다.

---

 이렇게 RPN을 가정한 평가 함수를 만들고 나면, 남은 작업은 입력으로
 들어온 중위 표기법 수식을 후위 표기법으로 바꾸는 것 뿐이다. 킹갓
 다익스트라님께서 이미 알고리즘을 만들고 증명해두셨으니 우리는 이걸
 가져다 쓰면 된다. 바로 [차량기지 알고리즘(Shunting yard
 algorithm)](https://en.wikipedia.org/wiki/Shunting_yard_algorithm)이다. 알고리즘이
 동작하는 (중간에 연산자를 넣어뒀다가 다시 꺼내는) 방식이 차량 기지가
 동작하는 방식을 닮아서 이름붙여졌다고 한다.


 위키 문서의 방법을 거의 그대로 가져다 코드로 쓰면 된다. 여기서는
 함수가 따로 없으므로 사칙연산과 괄호만 수도 코드로 가져왔다. 참고로,
 이렇게 뭔가 순서를 뒤집거나 하는 데에는 항상 스택이 필수로 쓰인다.

```
입력: 중위 표기법 수식의 토큰 리스트
중간 데이터: 연산자 스택
출력: 후귀 표기법 수식 큐

while 토큰이 아직 남아있는 동안:
    토큰을 읽는다.
    match 토큰 with
    | 숫자 -> 출력 큐에 넣는다.
    | 연산자 o1 ->
        while (연산자 스택 꼭대기에 여는 괄호가 아닌 연산자 o2가 있고
            && o2가 o1보다 우선순위가 높거나
            || 둘의 우선순위가 같고 o1이 왼쪽 결합인 동안):
            연산자 스택에서 o2를 팝해서 출력 큐에 넣는다.
        o1을 연산자 스택에 넣는다.
    | 여는 괄호 -> 연산자 스택에 넣는다.
    | 닫는 괄호 ->
        while 연산자 스택의 꼭대기가 여는 괄호가 아닌 동안:
            연산자 스택에서 연산자를 팝해서 출력 큐에 넣는다.
        여는 괄호를 팝해서 버린다.

while 연산자 스택에 연산자가 남아 있는 동안:
    연산자를 팝해서 출력 큐에 넣는다.
```

 전체적인 알고리즘의 모습은 이것과 동일하다. 즉, 토큰을 읽어서, 토큰의
 종류에 따라 연산자 스택을 적절히 이용해서 우선순위에 맞게 후위
 표기법으로 바꾼다.

 여기서 위키에서 다루지 않는 내용이 바로 **단항 연산자**의
 경우이다. 예를 들어, `- 3 + 5`는 후위 표기법으로 바꾸면 `3 - 5 +`가
 되는데, 이는 `-`가 단항 연산자이기 때문이다. 그럼 단항 연산자는
 어떻게 처리하면 될까? 먼저 어떤 경우에 단항 연산자인지를 생각해보면
 다음 세 가지 케이스밖에 없다는 것을 알 수 있다.
 1. 중위 표기법 토큰 스트림의 가장 처음에 나온다. e.g. `-1`
 2. 다른 연산자 바로 다음에 나온다. e.g. `1 + -1`
 3. 여는 괄호 바로 다음에 나온다. e.g. `(-1)`

 그럼 단항 연산자 일때는 어떻게 하면 될까? 그냥 바로 연산자 스택에
 넣으면 된다. 예를 들어, 1의 경우는 `-`가 스택에 들어가고, `1`이 큐에
 쌓이고, 그 후 마지막 `while` 루프에서 스택에 있는 단항 연산자가 큐에
 들어가 정상적인 `1 - `가 된다. 3의 경우도 자명하다.

 2의 경우는 두 가지 더 고려해야 할 것이 있는데, (1) 단항 연산자와 이항
 연산자를 구분해야하고 (2) 두 연산자의 우선순위를 비교해야 한다. 단항
 연산자의 우선순위는 어떻게 될까? 자연스럽게, 우리는 단항 연산자의
 우선순위가 더 높음을 안다. 따라서 (2)는 해결된다. (1)을 위해서, 위의
 세 가지 케이스일 때, 연산자 스택에 그냥 `-`를 넣으면 안되고 이것이
 단항 연산자임을 알리기 위한 특별한 토큰을 넣어야 한다. 여기서는
 `u-`로 표기하겠다. 이러면 (1)과 (2)는 해결된다. 그러면 계속해서 2의
 경우를 살펴보자. 루프를 몇 번 거치고 나면 출력 큐는 `1 1`이고
 스택에는 `[+, u-]`가 들어간다. 그러면 마지막 `while` 루프를 통해 `1 1
 u- +`가 되고 이는 우리가 원하는 올바른 후위 표기법이다.

 이 아이디어를 코드로 구현해서 중위 표기법 수식을 파싱하여 RPN 수식의
 리스트로 돌려주는 함수를 작성하면 다음과 같다.

```python
def parse(infix_exp):
    binary_operators = ['+', '-', '*', '/']
    precedences = {
        '+': 1, '-': 1,
        '*': 2, '/': 2,
        'u-': 3,
    }
    rpn, opstack = [], []
    lexer = re.compile(r"[-+*/()]|\d+")
    tokens = lexer.findall(infix_exp)
    for idx, tok in enumerate(tokens):
        if tok.isdigit():
            rpn.append(int(tok))
            continue

        if tok == '-' and (idx == 0 or tokens[idx-1] in binary_operators + ['(']):
            opstack.append('u-')
        elif tok in binary_operators:
            while opstack and opstack[-1] != '(' and precedences[opstack[-1]] >= precedences[tok]:
                rpn.append(opstack.pop())
            opstack.append(tok)
        elif tok == '(':
            opstack.append(tok)
        else: # tok == ')'
            while opstack:
                top = opstack.pop()
                if top == '(':
                    break
                rpn.append(top)
    while opstack:
        rpn.append(opstack.pop())
    return rpn
```

 - 입력이 문자열이기 때문에 이를 토큰으로 쪼개기 위해서 파이썬의
   `re`를 이용해 정규식으로 쪼개었다. 정규식 사용법은
   [여기](../../theory/regexp)를 참조하자.
 - 단항 연산자의 처리를 위해서 토큰의 인덱스가 필요하다.


---

 이렇게 두 가지를 얻었다:
 - 중위 표기법 수식 문자열을 후위 표기법 토큰 리스트로 변환하는 함수
   `parse`
 - 후위 표기법 토큰 리스트를 평가하고 결과 값을 계산하는 함수 `eval_`

 그러면, 모든 Basic Calculator 문제는 다음 두 줄로 풀린다:

```python
def calculate(s):
    rpn = parse(s)
    return eval_(rpn)
```
