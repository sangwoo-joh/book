---
layout: page
tags: [problem-solving, leetcode, python, linked-list]
title: Partition List
---

# [Partition List](https://leetcode.com/problems/partition-list/)

 싱글 링크드 리스트의 루트 노드 `head`와 정수 값 `x`가 주어질 때,
 리스트를 나눠서 `x`보다 작은 모든 노드가 `x`보다 크거나 같은 모든
 노드보다 앞에 오도록 하자.

 이때, 리스트의 **원래의 상대적인 노드 순서**는 보존해야 한다.

 예를 들어, `1 -> 4 -> 3 -> 2 -> 5 -> 2`와 `x = 3`이 주어진다면, `3`을
 기준으로 작은 모든 노드는 그 상대적인 순서를 유지하면서 `1 -> 2 ->
 2`와 `4 -> 3 -> 5`로 나눌 수 있다. 따라서 답은 `1 -> 2 -> 2 -> 4 -> 3
 -> 5`가 된다.

 노드의 개수는 0 ~ 200이고 노드의 값은 -100~100이다. `x`는 -200~200
 사이의 값이다.

## 두 개의 센티넬을 이용하기

 핵심은 *원래의 순서*를 유지하는 것이다. 따라서, 일반적인 리스트
 탐색처럼 탐험 노드가 노드를 끝까지 쭉 밀고 나가면서, `x`를 기준으로
 조건에 맞는 부분 리스트를 만들어 나가면 된다. 그러고 나면 마지막에는
 `less` 리스트와 `geq` 리스트로 나누어질텐데, 이 두 리스트를 잘
 이어주면 된다. 이때, 주의할 점은 우리는 리스트의 *탐험 노드*를
 움직이기 때문에, 리스트의 탐색이 끝나는 시점에서 이 노드들의 위치는
 `less`와 `geq` 각 리스트의 **끝**에 있다는 점이다. 따라서 탐험을
 시작하기 전에 이 리스트들의 시작 위치를 기록해줘야 두 리스트를
 올바르게 이어주고, 새로운 리스트의 루트 노드를 올바르게 돌려줄 수
 있다.

```python
def partition(head, x):
    less, geq = ListNode(), ListNode()
    lsentinel, gsentinel = less, geq
    pioneer = head
    while pioneer:
        if pioneer.val < x:
            less.next = pioneer
            less = less.next
        else:
            geq.next = pioneer
            geq = geq.next
        pioneer = pioneer.next

    less.next, geq.next = gsentinel.next, None
    return lsentinel.next
```

 - 역시 여기서도 센티넬 노드를 활용했다. 이러면 리스트가 비었는지
   아닌지 확인하는 작업이 아주 쉬워진다. `less`, `geq`도 모두 센티넬
   노드이므로 이 파티션 리스트들의 시작점을 기록하기 위한
   `lsentinel`과 `gsentinel`도 역시 이름대로 센티넬이다. 따라서 두
   리스트를 연결할 때, 먼저 `less`의 끝 노드를 `geq`의 시작 노드와
   이어주고 (`less -> gsentinel.next`), 그 후 `geq`의 끝 노드를 끊어서
   싸이클을 없애준다 (`geq.next = None`). 이러고나면 `less`의 시작
   노드(`lsentinel.next`)가 새로운 루트가 된다
