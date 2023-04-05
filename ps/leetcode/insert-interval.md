---
layout: page
tags: [problem-solving, leetcode, python, interval]
title: Insert Interval
---

# [Insert Interval](https://leetcode.com/problems/insert-interval/)

 범위란 시작점과 끝점의 튜플 `(start, end)` 이고 `start <= end`
 이다. 범위의 리스트 `intervals`는 **겹치지 않는** 범위들이 `start`의
 오름차순으로 정렬되어 있다.

 추가할 범위 `newInterval`을 `intervals`에 삽입해서 새로운 범위
 리스트를 만들어야 하는데, 원래의 범위 리스트와 마찬가지로 겹치는 부분
 없이 오름차순이어야 한다.

## O(N) - 1

 범위 리스트가 서로 겹치지 않는 것이 보장되어 있기 때문에, 삽입할
 범위를 기준으로 둘로 나눌 수 있다. 즉,

```python
left < (newInterval.start, newInterval.end) < right
```

 요런 느낌으로 왼쪽과 오른쪽으로 나눠볼 수 있다. 이러면 두 가지
 케이스가 생기는데,

 1. `len(left) + len(right) == len(intervals)`인 경우: 즉 삽입할
    범위를 기준으로 반 짤랐는데, 자른 두 길이를 합친 것이 원래 길이와
    같다는 것은 원래 범위 리스트 중 삽입할 범위와 겹치는 것이 아무것도
    없다는 뜻이다. 이때는 그냥 `left`와 `right` 사이에 `newInterval`을
    집어넣으면 된다.
 2. 아닌 경우: 이 때는 `left`와 `right` 사이에 `newInterval`과 범위가
    겹치는 부분이 있다는 뜻이다. 그러면 겹치는 부분을 어떻게 알 수
    있을까?

### 겹치는 부분 파악하기

 왼쪽을 먼저 생각해보자. 범위 리스트에서 `len(left)`만큼을 제외하고
 처음 나타나는 범위의 시작점과 삽입할 `newInterval`의 시작점 중 더
 작은 것이 삽입할 범위의 시작점이 될 것이다. 그래야 범위를 다 커버할
 수 있기 때문이다. 즉, `len(left)-1 +1` 인덱스의 범위와 비교하면
 된다.

 다음으로 오른쪽을 생각해보자. 범위 리스트에서 **거꾸로** `len(right)`
 만큼을 제외하고 처음 나타나는 범위의 끝점과 삽입할 `newInterval`의
 끝점 중 더 큰 것이 삽입할 범위의 끝점이 될 것이다. 역시 이것도 범위를
 다 커버하기 위함이다. 이때, 파이썬에서는 음수 인덱스를 활용할 수
 있는데, 양수와는 달리 0이 아니라 -1 부터 시작하므로 `-len(right) -1`
 인덱스의 범위와 비교하면 된다.

---

 이 아이디어를 구현하면 다음과 같다.

```python
def insert(intervals, newInterval):
    start, end = newInterval
    left = [itv for itv in intervals if itv[1] < start]
    right = [itv for itv in intervals if end < itv[0]]
    if len(left) + len(right) != len(intervals):
        start = min(start, intervals[len(left)][0])
        end = max(end, intervals[-len(right)-1][1])
    return left + [(start, end)] + right
```
