---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Middle of the Linked List
---

# [Middle of the Linked List](https://leetcode.com/problems/middle-of-the-linked-list/)

 링크드 리스트의 헤드 노드가 주어졌을 때, 리스트의 중간에 있는 노드를
 찾는 문제다. 만약 중간이 두 개라면(즉, 리스트 길이가 짝수) 두 번째
 노드를 리턴하자. 리스트의 크기는 1~100 사이이다.

## 배열에 저장

 가장 떠올리기 쉬운 방법은, 순서대로 전부 배열에다 저장한 다음에 그냥
 배열 인덱스 계산으로 중간에 있는 것을 돌려주는 것이다. 중간에 두 개
 있을 때 두 번째 걸 리턴하는 건 배열 길이가 짝수일 때 2로 나눈 값과
 같으므로 trivial 하다.

```python
def middleNode(head):
    array = []
    while head:
        array.append(head)
        head = head.next
    return array[len(array)//2]
```

## 투 포인터 - Fast and Slow

 다른 방법도 있다. 두 개의 포인터로 동시에 리스트를 훑을 건데, 하나는
 한 칸씩 가고 다른 하나는 한번에 두 칸씩 간다. 즉, 속도가 두 배
 차이나게 간다. 그러면 두 칸씩 가는 애가 끝에 도달했을 때 한 칸씩 가는
 애가 있는 위치가 중간이 된다. 그림을 보면 좀더 이해가 쉽다. 한 칸씩 가는 애를 `slow`, 두 칸씩 가는 애를 `fast`라고 하면 다음과 같다.

```
(홀수)
  | 1 -> 2 -> 3 -> 4 -> 5
--+----------------------
0 |s,f
1 |      s    f
2 |           s         f

(짝수)
  | 1 -> 2 -> 3 -> 4 -> 5 -> 6
--+---------------------------
0 |s,f
1 |      s    f
2 |           s         f
3 |                s              f
```


 즉, `fast.next`가 있을 때 두 칸씩 가면 `slow`는 우리가 원하는 지점에
 있게 된다.

```python
def middleNode(head):
    slow, fast = head, head
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
    return slow
```
