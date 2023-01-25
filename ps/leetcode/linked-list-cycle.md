---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Linked List Cycle
---


# [Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)

 링크드 리스트의 헤드 노드가 주어졌을 때, 해당 리스트에 싸이클이
 있는지를 확인하자.

 노드 개수는 최대 10000개 이다.

## 접근 1 - DFS
 - DFS 하다가 이전에 방문한 적 있는 노드를 또 방문한 경우 싸이클이다.
 - 공간, 시간 복잡도 모두 O(N)


```python
"""
class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None
"""
def hasCycle(head):
    if not head:
        return False
    stack = []
    visited = set()
    stack.append(head)
    while stack:
        node = stack.pop()
        if node in visited:
            return True
        visited.add(node)
        if node.next:
            stack.append(node.next)

    return False
```

## 접근 2 - 거북이와 토끼 포인터
 - 거북이 포인터와 토끼 포인터를 동시에 리스트를 여행할 때, 만약
   싸이클이 있으면 둘은 항상 만나게 된다.
 - 공간 복잡도가 O(1)

```python
def hasCycle(head):
    if not head:
        return False
    fast, slow = head, head
    while fast.next and fast.next.next:
        fast = fast.next.next
        slow = slow.next
        if slow == fast:
            return True
    return False
```
