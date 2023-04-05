---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Reorder List
last_update: 2023-04-05 09:46:45
---

# [Reorder List](https://leetcode.com/problems/reorder-list/)

 링크드 리스트가 주어졌을 때, 다음과 같이 표현할 수 있다.

```python
Node(0) -> Node(1) -> ... -> Node(n-1) -> Node(n)
```

 이걸 다음과 같은 형식으로 재정렬하자. 이때, **값을 바꾸면 안되고**,
 노드의 포인터만 바꿔야 한다. 리스트를 새로 만들어서도 안되고, 원래의
 리스트를 제자리에서(in-place) 수정해야 한다.

```python
Node(0) -> Node(n) -> Node(1) -> Node(n-1) -> Node(2) -> Node(n-2) -> ...
```

## 리스트를 요리조리

 문제를 잘 읽어야 한다. ~~처음에는 짝수/홀수 번째 리스트 노드를
 교차하는 건줄 알았는데 그게 아니었다.~~ 잘 보면 논리적으로 다음
 스텝을 밟는다는 것을 알 수 있다:
 1. [리스트의 중간 지점을 찾는다.](../middle-of-the-linked-list)
 2. [중간부터 끝까지를 뒤집는다.](../reverse-linked-list)
 3. 처음~중간까지의 리스트와 중간~끝까지 뒤집힌 [리스트를 합친다.](../merge-two-sorted-lists)

 각각이 이미 이전에 나온 문제들이다. 따라서 이전 방법들을 조합해서 풀
 수 있다.

```python
def reorderList(head):
    # find middle
    slow, fast = head, head
    while fast and fast.next:
        slow, fast = slow.next, fast.next.next

    # reverse from middle to end
    stack = []
    node = slow
    while node:
        stack.append(node)
        node = node.next
    sentinel = ListNode()
    node = sentinel
    while stack:
        node.next = stack.pop()
        node = node.next
    reversed_list = sentinel.next

    # should unlink in the middle!
    slow.next = None

    # merge them
    n1, n2 = head, reversed_list
    n = ListNode()
    flag = True
    while n1 and n2:
        if flag:
            n.next = n1
            n1 = n1.next
        else:
            n.next = n2
            n2 = n2.next
        n = n.next
        flag = flag ^ True
```

 - 새로운 루트 노드를 찾는게 아니더라도 중간을 찾는거 빼고
   나머지에서는 센티넬 노드를 활용하는게 좋다.
 - 주의할 점은, 중간을 찾아서 중간부터 끝까지 리스트를 뒤집고 나면
   **반드시 중간 부분에서 리스트를 끊어줘야 한다는 것이다**. 안그러면
   리스트에 싸이클이 생겨서 두 리스트를 병합할 때 무한 루프에 빠진다.
 - 정방향 리스트와 역방향 리스트 모두 마지막 노드는 중간 노드가
   된다. 즉, 아래 그림과 같다. 따라서, 두 리스트를 합칠 때 둘 다
   남아있을 동안만 합치면 된다. 어차피 마지막은 둘다 중간 노드이기
   때문이다.

```python
(홀수)
1 -> 2 -> 3 -> 4 -> 5
n1: 1 -> 2 -> 3
n2: 5 -> 4 -> 3

(짝수)
1 -> 2 -> 3 -> 4 -> 5 -> 6
n1: 1 -> 2 -> 3 -> 4
n2: 6 -> 5 -> 4
```

 - 두 노드를 합칠 때 여기서는 특별히 값의 비교가 필요하지 않다. 대신
   어떤 노드를 합칠 것인지를 정해야하는데, 여기서는 단순한 플래그를
   둬서 참일 때에는 정방향을 합치고 거짓일 때에는 역방향을 합치도록
   했다. 플래그는 XOR의 성질을 이용해서 참과 XOR 해줘서 매번
   뒤집도록(flip) 했다.
