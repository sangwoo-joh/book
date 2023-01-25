---
layout: page
tags: [problem-solving, leetcode, python, linked-list, heap]
title: Merge k Sorted Lists
---

# [Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/)

 `k`개의 정렬된 링크드 리스트가 입력으로 들어왔을 때, 이 리스트를 전부
 합쳐서 하나의 정렬된 링크드 리스트로 만들자.

 `k`는 0~10,000 이고 리스트의 길이는 최대 500이다. 노드의 값의 범위는
 -10,000~10,000이다.

## Brute Force
 가장 쉽게 떠오르는 방법은, 모든 리스트를 다 하나의 배열에다 잡아 넣은
 다음에 정렬하는 것이다. k, n이 생각보다 작기 때문에 이 경우에
 파이썬의 정렬은 엄청 빠르게 동작한다.

```python
"""
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next
"""
def mergeKLists(lists: List[ListNode]):
    vals = []
    for node in lists:
        while node:
            vals.append(node.val)
            node = node.next

    sentinel = ListNode()
    node = sentinel
    for v in sorted(vals):
        node.next = ListNode(v)
        node = node.next
    return sentinel.next
```

 - 이론적인 복잡도는 O(nlogn)인데, 문제의 k, n이 작기 때문에 엄청
   빠르게 동작한다.


## Merge
 [두 개의 정렬된 리스트를 합치는 방법](../merge-two-sorted-lists)을
 그대로 적용해볼 순 없을까? 물론 가능하다. 단, k가 최대 10,000이기
 때문에, 좋지 못한 복잡도를 얻게 된다.

 그래도 일단 두 개를 합치는 방법과 같은 방법으로 합쳐보자. 몇 개인진
 모르겠지만, 아무튼 합칠려는 노드 중에서 가장 값이 작은 노드를 찾고,
 그 값을 추가하고, 이후 반복하면 된다. 노드의 값의 범위가 -10,000 ~
 10,000 사이 이기 때문에 이를 이용해서 최소 값의 위치를 구하면 되겠다.

```python
def mergeKLists(lists: List[ListNode]):
    sentinel = ListNode()
    node = sentinel

    while True:
        min_val = float('inf')
        min_idx = -1
        for i, n in enumerate(lists):
            if n and n.val < min_val:
                min_idx = i
                min_val = n.val

        if min_idx == -1:
            break

        node.next = ListNode(min_val)
        lists[min_idx] = lists[min_idx].next
        node = node.next

    return sentinel.next
```

 - 역시 리스트 문제에는 센티넬 노드를 활용해야 코드가 깔끔해진다.
 - 매번 노드의 리스트를 돌면서 최소 값을 가진 노드의 위치와 값을
   찾아낸다. 그리고 해당 값으로 새 리스트에 노드를 추가하고, 노드와 새
   리스트를 모두 다음 단계로 전진한다. 이때 주의할 점은, 새 리스트를
   만드는데 쓰이는 노드 변수 `node`와 대상 노드 리스트 중 최소 값을
   찾기 위해 쓰이는 노드 변수 `n`에 같은 이름을 쓰면 안된다는
   점이다. 파이썬의 시맨틱 상 `n`이 `for` 루프 범위에서만 살아있지
   않고 루프가 끝나도 계속 살아있기 때문에, 자칫하면 `node`를 덮어버릴
   수 있어서 무한 루프에 빠지게 된다.
 - 이론적인 복잡도는 O(nk)이지만, 문제에서 k가 생각보다 크기 때문에
   5~7초라는 어마어마한 시간이 소요된다.

## Heap

 좀더 빠르게 병합할 수 있는 방법은 없을까? 첫 번째 방법에서는 최소의
 원소를 찾기 위해서 매번 k번의 반복을 돌아야 했는데, 이걸 줄일 수 있게
 해주는 데이터 타입이 바로 힙이다. 힙의 성질을 이용하면 O(nlogk) 의
 복잡도를 얻을 수 있다.

 파이썬에는 두 종류의 힙이 있는데, 하나는 `collections`에 있는
 `heapq`이고 다른 하나는 `queue`에 있는
 `PriorityQueue`이다. `PriorityQueue`가 내부적으로 `heapq`을 이용해서
 구현되어 있다. 힙의 성질을 구현한 자료 구조는 `heapq`이고, 실제
 쓰레드나 프로세스 간 메시지 패싱에 사용되는 라이브러리는
 `PriorityQueue`이다. 실제 사용 상에서 살짝 차이가 나는 부분이 있지만
 거의 유사하기 때문에 여기서는 둘 다 구현해보자.

 방법은 O(nk)에서 최소 값을 구하는 O(k)의 로직을 힙을 이용한 O(logk)의
 로직으로 바꾸는 것이다.

```python
import heapq
def mergeKLists(lists):
    sentinel = ListNode()
    node = sentinel

    setattr(ListNode, "__lt__", lambda self, other: self.val < other.val)
    heap = []
    for n in lists:
        if n:
            heapq.heappush(heap, n)

    while heap:
        top = heapq.heappop(heap)
        node.next = ListNode(top.val)
        node = node.next
        if top.next:
            heapq.heappush(heap, top.next)

    return sentinel.next
```

 - `heapq`는 따로 생성자가 있는 자료구조가 아니라, 파이썬의 리스트를
   힙으로 만들어주는 라이브러리이다.
 - 힙에 넣을 오브젝트는 반드시 **비교 가능**해야 한다. 특히 `<` 연산을
   지원해야 하는데, 문제의 `ListNode`에는 해당 어트리뷰트가 없다. 이걸
   우회하는 방법은 두 가지가 있는데, 하나는 `ListNode`를 상속받아서
   wrapper 클래스를 만들어서 이걸 사용하는 것이고, 다른 하나는 위의
   코드처럼 `setattr` 함수를 이용해서 `ListNode`에 직접 `__lt__`
   메소트 어트리뷰트를 박는 것이다. 추가로, `None`은 비교 가능하지
   않기 때문에, 힙에는 절대 `None`을 추가하면 안된다. 그래서 힙에
   추가하기 전에 널체크를 해야 한다.


 `PriorityQueue`로 하는 구현은 위와 살짝 다르다.

```python
from queue import PriorityQueue
def mergeKLists(lists):
    sentinel = ListNode()
    node = sentinel

    setattr(ListNode, '__lt__', lambda self, other: self.val < other.val)
    pq = PriorityQueue()
    for n in lists:
        if n:
            pq.put(n)

    while not pq.empty():
        top = pq.get()
        node.next = ListNode(top.val)
        node = node.next
        if top.next:
            pq.put(top.next)

    return sentinel.next
```

 - `PriorityQueue`는 생성자가 있는 클래스 자료구조이다.
 - `heapq`의 empty check는 리스트 자체를 사용했지만, `PriorityQueue`는
   생성하는 순간 메모리에 올라가기 때문에 empty check을 하려면
   `PriorityQueue.empty()` 메소드를 호출해야 한다.
