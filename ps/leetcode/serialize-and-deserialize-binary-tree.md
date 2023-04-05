---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Serialize and Deserialize Binary Tree
last_update: 2023-04-05 09:47:06
---

# [Serialize and Deserialize Binary Tree](https://leetcode.com/problems/serialize-and-deserialize-binary-tree/)

 바이너리 트리를 어떤 형태로든 시리얼라이즈해서 문자열로 만들고, 이후
 해당 문자열을 디시리얼라이즈 해서 원본 바이너리 트리를 복원하는
 문제다.

 실제 시리얼라이제이션과 디시리얼라이제이션은 바이너리로 떨어지는 것이
 맞지만 여기서는 문제의 편의를 위해서 문자열로 제한된다.

 노드의 개수는 0~10,000 이고 노드 값은 -1,000~1,000이다.

## 재귀

 트리를 재귀적으로 방문하면 루트로부터의 DFS와 동일하고 이는 곧 트리의
 Pre-order 순회와 같다. 이 방문 순서대로 트리를 시리얼라이즈 하면 아래
 예시와 같다.

![tree](https://assets.leetcode.com/uploads/2020/09/15/serdeser.jpg)

```python
1 -> 2 -> null -> null -> 3 -> 4 -> null -> null -> 5 -> null -> null
```

 그러면 이 순서를 다시 원래의 트리 구조로 복원하려면 어떻게 하면 될까?
 이 역시 시리얼라이즈된 데이터를 하나씩 방문하면서 재귀적으로 트리를
 구축해가면 된다.

```python
def serialize(root):
    buffer = []
    def deconstruct(node):
        nonlocal buffer
        if node:
            buffer.append(str(node.val))
            deconstruct(node.left)
            deconstruct(node.right)
        else:
            buffer.append("None")

    deconstruct(root)
    return ";".join(buffer)
```

 - 노드의 값을 차례대로 버퍼에 추가한 다음 구분자로 `;`를 줘서 하나의
   문자열로 합쳤다. 디시리얼라이즈 하는 부분에서는 이 정보를 바탕으로
   `;`를 기준으로 데이터를 잘라내면 된다.
 - 노드가 null 일 때에는 어떤 값이든 null 임을 알려줄 수 있는 데이터로
   시리얼라이즈하면 된다. 여기서는 그냥 `None` 문자열 자체로 주었다.

```python
def deserialize(data):
    raw = iter(data.split(";"))

    def construct(value):
        if value == "None":
            return None
        node = TreeNode(int(value))
        node.left = construct(next(raw))
        node.right = construct(next(raw))
        return node

    return construct(next(raw))
```

 - 데이터를 `;`를 기준으로 잘라내면 원본 버퍼가 복원된다. 트리의
   재구축은 이 원본 버퍼를 하나씩 까보면서 진행하게 되는데, 이때
   파이썬의 `iter()`와 `next()`를 활용하면 좋다.
 - `construct`는 재귀적으로 값으로부터 트리 노드를 복구한다. 아래
   그림을 보면 좀더 이해가 쉽다. 트리의 노드 옆 괄호 안의 숫자는
   `construct` 함수가 재귀적으로 방문하는 순서이다.

```python
1 -> 2 -> null -> null -> 3 -> 4 -> null -> null -> 5 -> null -> null


                    1(0)
                     |
          +----------+------------+
        2(1)                    3(4)
          |                       |
   +------+-------+         +-----+-----------+
 null(2)       null(3)     4(5)              5(8)
                            |                 |
                       +----+----+      +-----+-----+
                    null(6)   null(7) null(9)    null(10)
```

 - 시리얼라이즈 함수에서 모든 null인 자식 노드들까지 전부 덤핑했기
   때문에, 디시리얼라이즈 하는 부분에서 `next()` 함수의 호출 횟수가 딱
   들어맞는다. 즉, `next()`를 호출하는 시점에 `StopInteration` 예외가
   발생하지 않는다는 것이 보장된다.

## BFS

 트리 문제에서 리트코드 사이트의 입력 포맷을 보면 기묘한 리스트 형태로
 되어있는 것을 볼 수 있다. 잘 살펴보면 이 형식은 트리를 루트로부터 BFS
 한 결과와 일치한다(실제로는 trailing null을 다 삭제해도 잘 동작하도록
 되어있다). 이 형식을 한번 시도해보자.

 트리의 BFS는 결국 [레벨 오더
 순회](../binary-tree-level-order-traversal)와 같다. 큐를 이용해서
 구현해보자.

```python
from collections import deque
def serialize(root):
    q = deque()
    q.append(root)
    buffer = []
    while q:
        node = q.popleft()
        if node is None:
            buffer.append("nil")
        else:
            buffer.append(str(node.val))
            q.append(node.left)
            q.append(node.right)
    return ",".join(buffer)
```

 - 여기서는 약간의 변주를 줘서 `None`은 `nil`로, 구분자는 `,`로
   주었다. 나머지는 트리의 BFS와 동일하다.

```python
def deserialize(data):
    raw = data.split(",")
    if raw[0] == "nil":
        return None

    nodes = iter(None if v == "nil" else TreeNode(int(v)) for v in raw)

    root = next(nodes)
    q = deque()
    q.append(root)
    while q:
        node = q.popleft()
        left = next(nodes)
        if left:
            node.left = left
            q.append(left)
        right = next(nodes)
        if right:
            node.right = right
            q.append(right)

    return root
```

 - 여기서는 루트 노드가 `nil`인지를 스페셜 케이스로 처리해주는게
   편하다. 안그러면 큐를 훑는 코드가 지저분해진다.
 - 이번에도 약간 변주를 줘서 버퍼로부터 아예 트리 노드를
   만들었다. `nil`일 때는 `None`으로 만들어 두면 자식 노드를 연결할 때
   아무런 문제가 없다.
 - 여기서도 `iter()`와 `next()`를 활용하고 있고, 시리얼라이즈와 짝을
   맞추고 있기 때문에 `StopIteration` 예외가 발생하지 않음이 보장된다.

 BFS를 이용한 구축은 아래 그림과 같다.

```python
1 -> 2 -> 3 -> nil -> nil -> 4 -> 5 -> nil -> nil -> nil -> nil


                    1(0)
                     |
          +----------+------------+
        2(1)                    3(2)
          |                       |
   +------+-------+         +-----+-----------+
 nil(3)       nil(4)      4(5)               5(6)
                            |                 |
                       +----+----+      +-----+-----+
                    nil(7)   nil(8)   nil(9)    nil(10)
```
