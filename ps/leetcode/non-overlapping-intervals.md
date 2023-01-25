---
layout: page
tags: [problem-solving, leetcode, python, interval]
title: Non-overlapping Intervals
---

# [Non-overlapping Intervals](https://leetcode.com/problems/non-overlapping-intervals/)

 범위 리스트가 주어졌을 때, 이중 일부 원소를 삭제하면 나머지 리스트
 전체의 범위가 겹치지 않게 만들 수 있다. 이때, 삭제를 위해 필요한
 최소의 범위 수를 구하자.

 예를 들어서 `[(1,2), (2,3), (3,4), (1,3)]`을 생각해보자. 이 중
 `(1,3)`을 삭제하면 나머지 범위가 겹치지 않으므로 답은 1이다.

## O(NlogN)

 유사한 문제인 [범위 합치기](merge-intervals)에서의 방법을 여기서도
 활용해보자. 범위 합치기에서는 시작점을 기준으로 정렬한 다음 끝점을
 비교했는데, 범위를 합칠 때 두 끝점 중 더 큰 끝점을 새로운 끝점으로
 생성했었다. 즉, 여기서도 시작점을 기준으로 정렬을 활용한다면, 끝점도
 함께 봐야하는 귀찮음이 발생한다.

 따라서, 여기서는 *끝점*을 기준으로 정렬하는 방법을 생각해볼 수
 있다. 문제에서 범위를 겹치지 않게 만들기 위해 제거해야 하는 *최소*의
 범위 수를 구하라고 했기 때문에, 탐욕적인 접근을 취할 수 있다. 단,
 이걸 거꾸로 생각해서 범위를 *삭제*하는 것이 아니라 (범위 합치기처럼)
 범위를 **최대한 많이 남기는** 것으로 생각해보자. 이전에 확인한 범위를
 계속 유지하면서 다음 범위를 고를 수 있다면, 즉 겹치는 부분이 없다면
 해당 범위를 선택하고 이전 범위를 지금 범위로 업데이트
 한다. 이런식으로 쭉 겹치지 않는 범위만 고르면 최대한 많은 겹치지 않는
 범위를 선택할 수 있고, 삭제는 이것의 역 연산이니 전체 개수에서 빼면
 된다.

 이 아이디어를 구현하면 다음과 같다.

```python
def eraseOverlapIntervals(intervals):
    ordered = sorted(intervals, key=lambda x: x[1])
    prev = ordered[0]
    picked = 1
    for itv in ordered[1:]:
        if prev[1] <= itv[0]:
            picked += 1
            prev = itv

    return len(intervals) - picked
```
