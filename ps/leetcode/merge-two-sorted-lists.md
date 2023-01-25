---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Merge Two Sorted Lists
---

# [Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/)

 두 개의 정렬된 리스트가 입력으로 들어온다. 이 두 개의 리스트를 합쳐서
 하나의 정렬된 리스트로 만들자.

 노드의 개수는 둘 다 0~50이다. 두 리스트는 모두 비내림차순으로
 정렬되어 있다. 즉 같은 수가 있을 수 있다.


## 센티넬 + 병합

 병합 정렬에서 하던 것처럼 그냥 병합을 잘 구현하면 된다. 비내림차순
 정렬이므로 같은 원소가 있을 수 있는 것에 주의하면 된다.

 리스트를 다룰 때의 한가지 팁은 늘 센티넬 노드를 활용하라는
 것이다. 그러면 대부분의 리스트 코드가 깔끔해진다. 여기서도 센티넬
 노드를 활용하면 둘 중 빈 리스트가 어떤 것인지를 특별히 확인하지
 않아도 된다는 장점이 있다.

 아이디어를 코드로 구현해보자.

```python
"""
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next
"""
def mergeTwoLists(l1, l2):
    sentinel = ListNode()
    n = sentinel
    n1, n2 = l1, l2
    while n1 and n2:
        if n1.val < n2.val:
            n.next = ListNode(n1.val)
            n1 = n1.next
        else:
            n.next = ListNode(n2.val)
            n2 = n2.next
        n = n.next
    while n1:
        n.next = ListNode(n1.val)
        n, n1 = n.next, n1.next
    while n2:
        n.next = ListNode(n2.val)
        n, n2 = n.next, n2.next
    return sentinel.next
```

 - non-decreasing order 이므로 `n1 < n2` 일 때 `n1`의 값을 택한다.
 - 센티넬을 이용해서 새로운 리스트의 루트를 `sentinel.next`에 담도록
   한 덕분에 리스트가 비어있는지 확인하지 않아도 된다. 코드가
   깔끔해졌다.
