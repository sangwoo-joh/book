---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Remove Nth Node from End of List
---

# [Remove Nth Node from End of List](https://leetcode.com/problems/remove-nth-node-from-end-of-list/)

 링크드 리스트의 헤드 노드가 주어졌을 때, 끝에서 `n` 번째 뒤에 있는
 노드를 삭제하자.

 예를 들어 `1 -> 2 -> 3 -> 4 -> 5` 가 주어졌을 때, 끝에서 2번째 노드는
 `4` 이므로 이를 삭제하면 `1 -> 2 -> 3 ---> 5`가 된다.

 노드의 개수는 1~30이고, 끝에서 n번째의 n 값은 노드의 개수보다 작거나
 같음이 보장된다.

## O(N) - Two Pass

 가장 쉬운 방법은 일단 리스트를 전체 다 훑어서 노드의 개수를 모두 센
 다음, 여기서 n을 뺀 만큼만 한번 더 가는 것이다. 즉, 끝에서 n번째라는
 말은 앞에서 `len(list) - n` 번째와 같다는 성질을 이용한다.

 여기서도 센티넬 노드를 활용하면 코드가 깔끔해진다. 어떤 경우냐면,
 리스트 크기가 1일때 1번째 노드를 지우는 경우를 생각해볼 수
 있다. 센티넬이 없으면, 삭제가 일어난 후에 리스트가 비었는지를 스페셜
 케이스로 따로 처리해줘야 한다. 하지만 센티넬이 있으면, 알고리즘을
 통해 `sentinel.next`에 올바르게 `None`이 들어가기 때문에 깔끔해진다.

```python
"""
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next
"""
def removeNthFromEnd(head, n):
    node, size = head, 0
    while node:
        node, size = node.next, size + 1

    sentinel = ListNode(next=head)
    node = sentinel
    togo = size-n
    while togo > 0:
        node, togo = node.next, togo - 1

    node.next = node.next.next
    return sentinel.next
```

 - 리스트 사이즈를 계산한 뒤, 앞에서 부터 얼만큼 가야하는지를 `togo`에
   계산해서 한번 더 간다.
 - 센티넬 노드는 루트 노드의 이전에 있는 가상의 노드인데, 마침
   여기서는 어떤 노드를 삭제하기 위한 이전 노드를 가리키는데 쓰기에
   최적이다. 즉, 어떤 노드를 삭제한다는 것은 그 이전 노드가 해당
   노드의 다음 노드를 가리키도록 하면 되므로, 우리는 삭제할 노드
   *이전* 노드를 찾으면 되는데, 센티넬을 통해서 이를 쉽게 구할 수
   있다.
 - `n`의 값이 항상 리스트 크기보다 작거나 같음이 보장되기 때문에, 두
   번째 반복문을 통해 삭제할 노드 이전 노드를 찾았다면, 해당 노드는
   항상 `node.next`가 있음이 보장된다.
 - 센티넬 노드 덕분에 최종적으로 `sentinel.next`를 리턴하기만 하면,
   노드 삭제 후 리스트가 빈 경우도 잘 처리할 수 있다.

## O(N) - One Pass

 첫 번째 방법은 리스트의 크기를 계산하기 위해서 노드 전체를 한번, 그
 후 실제 노드 삭제를 위해 한번, 리스트를 총 두 번 훑어야
 한다. 리스트를 한번만 훑을 순 없을까?

 여기서 센티넬과는 다른 종류의 새로운 팁, 이른바 *개척자 노드*를
 도입할 수 있다. 개척자 노드는 항상 탐색할 노드보다 일정 부분 앞서
 나가도록 하는 노드이다. 여기서는 개척자 노드가 항상 n 만큼 앞서있다고
 하자. 그러면, 개척자 노드가 리스트의 끝에 도달했을 시점에, 탐색
 노드는 개척자 노드보다 n 만큼 뒤에 있게 되고, 이게 바로 우리가 원하는
 삭제 지점이 된다. 즉, 개척자 노드를 통해 리스트를 한번만 훑게 된다.

 이 아이디어를 도입해서 센티넬과 개척자 노드를 모두 활용하여 한번만
 훑는 구현은 다음과 같다.


```python
def removeNthFromEnd(head, n):
    sentinel = ListNode(next=head)
    pioneer = sentinel
    while n > 0:
        pioneer, n = pioneer.next, n - 1
    node = sentinel
    while pioneer.next
        node, pioneer = node.next, pioneer.next
    node.next = node.next.next
    return sentinel.next
```

 - 개척자 노드를 끝까지 보낼 때, 리스트의 완전 끝(None)까지 보내버리면
   탐색 노드가 삭제할 노드에 위치해버리므로 우리가 원하는 것이
   아니다. 대신, 리스트의 마지막 노드까지만 탐색하게 하면, 탐색 노드가
   삭제할 노드 바로 직전에 위치할 수 있고, 덕분에 `node.next`가 항상
   유효한 값을 갖고 있다.
