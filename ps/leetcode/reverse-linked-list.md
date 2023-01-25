---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Reverse Linked List
---


# [Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)

 싱글 링크드 리스트의 루트 노드 `head`가 입력으로 들어왔을 때, 이
 리스트를 뒤집고 뒤집은 리스트의 루트 노드를 리턴하는 함수를 만들자.


## O(N) - 1

 루트 노드부터 끝까지 리스트를 순서대로 생각한다면, 리스트를 뒤집는
 연산은 제일 처음 것이 제일 마지막으로 가는 것이다. 즉 처음 들어온
 것이 가장 나중에 나간다. 이는 곧 FILO(First-In, Last-Out) 구조이므로
 스택을 쓰면 자연스럽다.

 루트 노드부터 순서대로 끝까지 리스트를 스택에 푸시한다. 그 후
 스택에서 하나씩 팝 하면서 노드를 거꾸로 연결해주기만 하면 된다. 이때,
 빈 리스트가 들어오는 경우를 우아하게 처리하기 위해서 센티넬 노드를
 사용하면 좋다.

```python
# class ListNode:
#     def __init__(self, val=0, next=None):
#        self.val = val
#        self.next = next
def reverseList(head):
    stack = []
    while head:
        stack.append(head)
        head = head.next

    sentinel = ListNode()
    node = sentinel
    while stack:
        top = stack.pop()
        node.next = top
        node = node.next
    node.next = None
    return sentinel.next
```

 - 센티넬로 바로 리스트를 순회하면 센티넬을 잃어버리기 때문에 `node`
   변수를 따로 만들어서 업데이트 했다.
 - `while stack` 반복문을 다 돌고 나면 `node`는 뒤집어진 리스트의 제일
   마지막 노드를 가리키게 된다. 따라서 마지막 노드가 될 수 있도록
   `node.next = None`으로 업데이트 해줘야 한다.
 - 최종적으로 뒤집어진 리스트의 루트 노드는 `sentinel.next`가
   된다. 센티넬 노드를 사용한 덕분에 입력에서 굳이 `head is None` 인
   경우를 처리해주지 않아도 된다.

## O(N) - 2

 스택을 사용한 반복문 코드는 재귀함수로도 작성할 수 있다.

 앞에서 센티넬 노드를 도입했던 이유는 입력으로 빈 리스트(`head is
 None`)이 들어올 수 있어서였다. 재귀함수로 이걸 작성하려면 `prev`와
 `cur` 두 개의 노드를 유지하면서 서로 바꿔치기 하면 된다.

```python
def reverseList(head):
    def reverse(prev, cur):
        if cur is None:
            return prev
        _next = cur.next
        cur.next = prev
        return reverse(cur, _next)
    return reverse(None, head)
```

 - 재귀함수 `reverse`는 `prev -> cur` 인 링크드 리스트 노드 순서를
   `cur -> prev`로 재연결 해주는 함수다. 이때, 만약 `cur`가
   `None`이라면 이는 곧 (1) 리스트의 끝에 도달했거나 (2) 빈 리스트가
   입력으로 들어왔거나 두 가지 경우 중 하나인데, 바로 직전 노드인
   `prev`가 새로운 루트 노드가 되면 된다.
 - 위의 (2) 케이스에서 `prev`가 적절한 값을 리턴하기 위해서, `reverse`
   함수를 처음 호출할 때에는 `prev`를 `None`으로 준다.

# [Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/)

 싱글 링크드 리스트의 루트 노드 `head`와 두 개의 정수 `left`,
 `right`가 주어지고 `left <= right`를 항상 만족한다. 이때, `left`
 위치부터 `right` 위치까지를 뒤집자.

 리스트 노드의 개수는 1~500 이고 노드의 값은 -500~500이다.

 예를 들어 `1 -> 2 -> 3 -> 4 -> 5`가 있고 `left = 2`, `right = 4`일
 때, 두 번째 노드부터 네 번째 노드까지를 뒤집은 결과 리스트는 `1 -> 4
 -> 3 -> 2 -> 5`가 된다.

## 스택을 이용하기

 두 노드 `prev -> cur`가 있다고 하자. 그러면 이 두 노드를 뒤집는 것은
 `cur.next = prev`면 된다. `left`부터 `right` 구간 까지를 다 뒤집어야
 하므로, `prev`의 이전 노드를 또 찾아서 `prev.next = prevprev`와 같이
 뒤집어 줘야 한다. 이렇게 쭉 따라가다보면 결국 원하는 구간 내의 모든
 노드를 뒤집을 수 있다. 여기까지만 하면, 구간은 뒤집어졌지만 싸이클이
 발생한다. 바로 `prev <-> cur`와 같은 상황이 생기는 것이다. 따라서,
 구간 내의 노드를 다 뒤집고 나면, 두 가지를 해줘야 한다: 구간의 시작
 위치(`left`)의 노드는 구간이 끝난 위치 다음 노드를 가리키도록
 해야하고, 구간의 끝 위치(`right`)의 노드는 구간이 시작하기 직전
 노드가 가리키도록 해야한다. 이를 그림으로 나타내면 다음과 같다.

```
original:  .. prev.. -> left -> ... -> right -> ..remainings..
reversed:  .. prev.. -> right -> ... -> left -> ..remainings..
```

 뒤집기 연산을 가장 쉽게 할 수 있는 데이터 타입은 바로
 스택이다. 따라서, 여기서는 다음과 같은 단계를 따른다.
 1. `left`, `right` 구간에 속한 노드를 차례로 스택에 넣는다. 이때,
    구간에 진입하기 직전 노드(`prev`)와, 구간이 끝난 바로 다음
    노드(`remaining`)도 유지한다.
 2. 스택에 있는 노드를 하나 씩 뒤집는다.
 3. `prev` 노드와 `remaining` 노드를 구간에 알맞게 이어준다.

```python
def reverseBetween(head, left, right):
    if left == right:
        return head
    node, prev = head, ListNode(next=head)
    i = 1
    stack = []
    while node:
        if i == left:
            while i <= right:
                stack.append(node)
                node = node.next
                i += 1
            break
        i += 1
        prev, node = node, node.next

    # prev -> stack[:] -> node
    prev.next = stack[-1]
    while stack:
        top = stack.pop()
        top.next = stack[-1] if stack else node
    return prev.next if left == 1 else head
```

 - 주의해야 할 코너케이스는 바로 `left = 1`인 경우이다. 이때는 `prev`
   노드가 `head`의 바로 직전을 가리키는 센티넬 노드인 채로 루프가
   끝나기 때문에, 스택의 꼭대기가 새로운 루트 노드가 되어야
   한다. 따라서 이때는 `head`가 `prev.next`와 같다.
