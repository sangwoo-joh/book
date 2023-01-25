---
layout: page
tags: [problem-solving, boj, python, stack]
title: Stack
last_update: 2023-01-25 23:47:24
---

# Stack

 파이썬 리스트는 내부적으로는 가변 길이 배열로 되어 있고, `-1`로
 배열을 거꾸로 인덱싱하는 기능을 제공해줘서 스택으로 활용하기 좋다.


## 스택 응용 문제 - 괄호 쌍
 올바른 괄호 쌍을 판단하는 문제는 스택을 응용한 아주 기초적인
 문제이다. 우리는 스택에 *여는 괄호*를 추가하고, *닫는 괄호*를
 만난다면 아래 세 가지 중 하나를 수행한다:
  - 스택이 비어있는 경우: 짝이 맞지 않는 경우
  - 스택의 꼭대기와 짝이 맞지 않는 경우: 짝이 맞지 않는 경우
  - 스택의 꼭대기와 짝이 맞는 경우: pop

 이렇게 하고 난 후 스택에 괄호가 남아있으면 짝이 맞지 않는 경우이고,
 스택이 비어있는 경우에만 모든 괄호 쌍이 올바른 경우이다.

 이 사실은 다음과 같은 예시로부터 확인할 수 있다.

### 짝이 맞지 않는 경우 1

```
({)}

stack: ({
```

 스택에 앞의 두 여는 괄호가 추가된 상태에서, 세 번째 원소인 `)`를
 만나면 스택의 꼭대기인 `{`과 짝이 맞지 않으므로 틀린 경우임을 알 수
 있다.

### 짝이 맞지 않는 경우 2

```
{()

stack: {
```

 처음부터 끝까지 다 훑고 나면 스택에는 `{` 하나가 남는다. 입력을 다
 처리했는데 스택에 남는 여는 괄호랑 짝이 맞는 닫는 괄호가 없으므로
 틀린 경우임을 알 수 있다.

### 짝이 맞지 않는 경우 3

```
()}

stack: (empty)
```

 앞의 두 괄호는 짝이 맞으므로 스택에 `(`가 들어갔다가 `)`를 만나
 스택이 비어버린다. 이때 닫는 괄호 `}`를 만난다면 우리가 이때까지 만난
 여는 괄호가 없기 때문에 틀린 경우임을 알 수 있다.

---

 따라서, 이런 코너 케이스를 잘 처리하면서 스택의 성질을 응용하면 된다.

### [4949: 균형잡힌 세상](https://www.acmicpc.net/problem/4949)

```python
import sys
m = {'(': ')', '[': ']'}  # matching parentheses infor
for line in sys.stdin:  # fast scanner
    line = line.rstrip()  # strip out right-most newline
    if line == '.':
        break
    stack, valid = [], True
    for char in line:  # must consider characters only!!
        if char in m:
            stack.append(char)
        elif char in m.values():
            if not stack or char != m[stack[-1]]:
                valid = False
                break
            stack.pop()
    if stack:
        valid = False
    print('yes' if valid else 'no')
```


### [10799: 쇠막대기](https://www.acmicpc.net/problem/10799)

```python
import sys
stack, laserable, count = [], False, 0
for p in sys.stdin.readline().rstrip():
    if p == '(':
        if not laserable:
            laserable = True
        stack.append(p)
    else:
        stack.pop()
        count += len(stack) if laserable else 1
        laserable = False

print(count)
```

 - 레이저는 오직 `()`에서만 발사된다는 사실을 고려해야 한다.
 - 레이저가 발사되면, 그 순간 스택에 쌓여있는 `(`의 개수만큼 막대기가
   짤린다.
 - 레이저가 발사될 수 있는 구간이 아닌데 `)`를 만나면 이는 곧 막대기
   하나가 끝났다는 뜻으로 다르게 말해 막대기가 하나 짤렸다는 것과
   동치이다. 따라서 이를 고려해서 카운트를 세면 된다.

### [2504: 괄호의 값](https://www.acmicpc.net/problem/2504)

```python
import sys
stack, valid, temp, answer = [], True, 1, 0
line = sys.stdin.readline().rstrip()
for i in range(len(line)):
    p = line[i]
    if p == '(':
        temp *= 2
        stack.append(p)
    elif p == '[':
        temp *= 3
        stack.append(p)
    elif p == ')':
        if not stack or stack[-1] != '(':
            valid = False
            break
        # accumulate answer iff exact previous matching
        if i > 0 and line[i - 1] == '(':
            answer += temp
        # restore temp
        stack.pop()
        temp //= 2
    elif p == ']':
        if not stack or stack[-1] != '[':
            valid = False
            break
        if i > 0 and line[i - 1] == '[':
            answer += temp
        stack.pop()
        temp //= 3

if stack:
    valid = False

print(answer if valid else 0)
```

 전체적인 구조는 괄호 균형 체크하는 문제랑 거의 같다. 다만 점수를
 계산하는 방법을 떠올리는 게 좀 까다로웠다.

 예시를 보면 `(()[[]])`의 점수를 계산할 때 `(2 + 3*3)*2` 와 같이
 계산했는데, 이렇게 계산하는 순서는 괄호를 제일 안쪽부터 세어나가는
 방법과 같아서 비효율적이다. 따라서 이걸 풀어서 생각해보면 `2*2 +
 2*3*3`이 되는데, 즉 분배법칙이 적용됨을 알 수 있다. 이 아이디어에
 착안해서 다음과 같이 할 수 있다.
  - 정답을 누적할 `answer`와 중간 임시값 `temp`를 유지한다.
  - 스택에 여는 괄호를 쌓을 때, 괄호의 종류에 따라 `temp`에 `2` 또는
    `3`을 곱한다.
  - 닫힌 괄호를 만났을 때, **입력의 바로 직전과 짝이 맞을 때에만**
    `answer`에 `temp`를 누적한다. 그 후 스택을 팝함과 동시에 `temp`
    값을 원복한다.

 즉, `(()[[]])`에서 처음 `((`를 지나면 `temp`는 `2*2`가 되고, 이 값은
 제일 첫 `()`일 때에만 누적하도록 한다. 이후 `[[]]`를 만날 때에는
 `temp = 2 * 3 * 3`이 되고 제일 안쪽 `]`을 만날 때에만 이 값이
 누적된다. 이렇게 분배법칙만을 고려하면 닫힌 괄호일 때 복잡한 점수
 계산을 하지 않아도 된다.
