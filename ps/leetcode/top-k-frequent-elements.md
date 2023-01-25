---
layout: page
tags: [problem-solving, leetcode, python, heap]
title: Top K Frequent Elements
---

# [Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/)

 정수 배열 `nums`와 정수 `k`가 주어졌을 때, `nums`에 나타나는 수를
 빈번한 순으로 나열했을 때 `k` 순위까지의 숫자를 리턴하자. 순서는
 상관없다.

 예를 들어 `[1,1,1,2,2,3]`이 주어지고 `k=2`일 때, 1은 3번 / 2는 2번 /
 3번 1번 나타나므로 이 중 2순위까지의 수는 `[1,2]`이다. 순서는
 상관없으므로 `[2,1]`도 가능하다.

 배열 크기는 최대 100,000이고 `k`는 배열의 유니크 원소 수보다 작거나
 같음이 보장된다. 그리고 정답은 유니크함이 보장된다. 즉, 동 티어에
 같은 숫자가 여러개인 케이스는 없다.

## 개수 세기

 파이썬에는 카운터라는 편리한 자료구조가 있어서 그냥 이걸 바로
 적용하면 무지성으로 풀 수 있다.

```python
from collections import Counter
def topKFrequent(nums, k):
    c = Counter(nums)
    return [elt[0] for elt in c.most_common(k)]
```

 - `Counter.most_common()` 함수가 하는 일이 문제가 요구하는 사항과
   완전히 일치한다. 단, 리턴값이 key가 아니라 item이기 때문에, 이
   중에서 key 값, 즉 원본 정수 값만 가져와야 한다.
 - 내부적으로는 배열을 싹 훑어서 개수를 세고 개수를 기준으로 정렬을
   하기 때문에, 시간 복잡도는 O(NlogN)일 것이다.

## 힙

 사실 이 문제의 의도는 자료구조 힙을 도입하는 것이다. 최소힙을
 기준으로 설명하자면 힙의 탑은 항상 힙 전체 원소 중 가장 작은 값이
 들어있음이 보장된다. 따라서 배열을 훑어서 개수를 센 다음, 개수에 맞게
 힙을 구성하고, 힙에서 `k`번 탑을 빼내면 구하고자 하는 정답이 된다.

 파이썬의 `heapq`를 이용하거나 `PriorityQueue`를 이용하면 되는데, 나는
 `heapq`를 선호하는 편이다. 어차피 개수를 세야 해서 `Counter`결과를
 가지고 힙을 만들어서 `k`번 팝 하자.

```python
from collections import Counter
import heapq
def topKFrequent(nums, k):
    c = Counter(nums)
    heap = [(-c[1], c[0]) for c in c.items()]
    heapq.heapify(heap)
    answer = []
    for _ in range(k):
        answer.append(heapq.heappop(heap)[1])
    return answer
```

 - `heapq.heapify`는 **in-place**로 입력 리스트를 힙으로 만드는
   함수이므로, 미리 `heap`을 리스트로 만들어놔야 한다. 이때, 원소가
   (1) 그 자체로 비교 가능하면 그걸 쓰고, (2) 인덱싱이 가능하면 첫번째
   값을 키 값으로 비교한다. 여기서는 원소의 개수를 **음수로 취해서**
   키 값을 만들어야 하는데, `heapq`는 최소 힙이기 때문에 가장 많은
   원소의 순서를 유지하기 위함이다.
 - 힙에 들어간 원소가 `(-개수, 정수)`이므로, 정답 배열에는 `정수`만
   들어가도록 한다.

---

 그런데 사실 `Counter.most_common()` 함수가 바로 이 `heapq`를 이용해서
 좀더 간결하고 Pythonic한 방식으로 구현되어 있다.

```python
def topKFrequent(nums, k):
    c = Counter(nums)
    return heapq.nlargest(k, c.keys(), key=c.get)
```

 `heapq.nlargest(n, l, key=None)` 함수를 이용해서, 리스트 `l`에서
 `key`값을 기준으로 가장 큰 값 `n`개를 뽑아올 수 있다. 정확히 우리가
 원하는 함수다.

 먼저 카운터로 개수를 센다. 여기까진 동일하다. 이 다음 `nlargest`
 함수에 넘기는 파라미터들이 미묘한데, 일단 리스트가 `items`가 아니라
 곧바로 `key`이다. 대신, 여기서 비교에 쓰일 키 값을 가져오는 함수로
 `c.get`, 즉 카운터에서 해당 원소의 개수를 가져오는 함수를
 넘겼다. 이렇게하면 굳이 `items`를 가져와서 첫번째에 개수가 들어가도록
 튜플을 만들고... 이런 귀찮은 짓을 하지 않아도 된다.
