---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Palindrome Linked List
last_update: 2023-01-25 18:33:03
---

# [Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/)

 싱글 링크드 리스트의 헤드 노드가 주어졌을 때, 이 리스트가
 팰린드롬인지 아닌지를 확인하자.

 노드의 개수는 1~100,000 사이이고 노드의 값은 0~9사이이다.

## 접근 1
 - 팰린드롬은 정방향과 역방향이 같은 것
 - 역방향을 구하는 가장 쉬운 방법은 스택
 - 정방향을 훑어서 순서대로 스택에 쌓고, 다시 정방향을 한번 더
   훑으면서 스택을 순서대로 꺼내어 비교
 - 시간, 공간 복잡도 모두 O(N)

```python
def isPalindrome(head):
    stack = []
    node = head
    while node:
        stack.append(node)
        node = node.next
    node = head
    while node:
        if node.val != stack[-1].val:
            return False
        node = node.next
        stack.pop()
    return True
```

## 접근 2
 - 공간 복잡도를 O(1)로 할 수 있을까?
 - 리스트를 직접 제자리에서 수정하는 방법 밖에 없다.
 - 두 가지 아이디어가 필요하다:
   - O(1) Space로 리스트의 중간을 찾는 방법
   - O(1) Space로 리스트를 뒤집는 방법
 - 즉, 리스트를 두 개로 나눠서 앞쪽 절반과 뒤집은 뒤쪽 절반을 비교하면
   팰린드롬 여부를 확인할 수 있다.
 - O(1) 중간 지점 찾기는 토끼와 거북이 포인터를 이용하면 된다.
 - O(1) 뒤집기가 좀 까다로운데, 이전에 방문한 포인터, 현재 방문 중인
   포인터, 다음에 방문할 포인터를 적절히 유지하면서 일일이 뒤집는 수
   밖에 없다.
 - 이때, 팰린드롬 여부를 구한 후에 다시 뒷쪽 절반을 뒤집어서 링크드
   리스트를 원래 모습으로 되돌리는 것도 잊지말자.

```python
def half_of(node):
    fast, slow = node, node
    while fast.next and fast.next.next:
        fast = fast.next.next
        slow = slow.next
    return slow

def reverse(node):
    prev, cur = None, node
    while cur:
        to_visit = cur.next
        cur.next = prev
        prev = cur
        cur = to_visit
    return prev

def isPalindrome(head):
    if head is None:
        return True

    half = half_of(head)
    reversed_half = reverse(half.next)
    result = True
    first, second = head, reversed_half
    while result and second:
        if first.val != second.val:
            result = False
        first = first.next
        second = second.next

    half.next = reverse(reversed_half)
    return result
```
