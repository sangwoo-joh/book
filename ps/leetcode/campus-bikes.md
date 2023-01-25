---
layout: page
tags: [problem-solving, leetcode, python, backtracking, bitwise, heap]
title: Campus Bikes
last_update: 2022-12-16 17:18:13
---

# [Campus Bikes](https://leetcode.com/problems/campus-bikes/)

# [Campus Bikes II](https://leetcode.com/problems/campus-bikes-ii/)

 2차원 평면에 `n`명의 작업자와 `m`개의 자전거가 뿌려져있다. `n <=
 m`이다.

 각각의 자전거는 딱 한명의 작업자에게 할당되야 한다. 이때, 작업자와
 자전거 사이의 맨하탄 거리의 합이 최소가 되어야 한다.

 이렇게 자전거를 할당했을 때, 가능한 맨하탄 거리의 합의 최소값을
 구하자.

 두 점 `p1`과 `p2`의 맨하탄 거리는 `Manhattan(p1, p2) = |p1.x -
 p2.x| + |p1.y - p2.y|`로 정의된다.

 - $$ 1 \leq n \leq m \leq 10 $$
 - 각 좌표는 정수이고 좌표의 범위는 0~1000
 - 모든 작업자와 자전거의 위치 좌표는 유일함이 보장된다.

## 탐욕법 + 백트래킹

 1. 각각의 작업자가 모든 자전거를 다 확인하면서, 가장 가깝고 아직
    할당되지 않은 자전거를 할당한다. 할당한 자전거를 기록한다.
 2. 맨하탄 거리의 합을 업데이트하고 다음 작업자를 확인하기 위해서
    재귀호출한다.
 3. 재귀호출이 끝나면, 즉 다음 작업자에 대한 확인이 끝나면, 해당
    작업자에게 할당했던 자전거를 원복한다.
 4. 만약 모든 자전거를 할당했다면, 지금까지 누적된 맨하탄 거리의 합을
    이전 최소합과 비교해서 업데이트한다.
 5. 자전거를 작업자한테 할당하기 전에, 지금까지 누적된 맨하탄 거리의
    합이 이미 이전 최소합을 넘겼는지를 확인하면 좋다. 이미 넘겼다면
    나머지 작업자에 대해서는 확인할 필요가 없기 때문이다.

```python
def assignBikes(workers: List[List[int]], bikes: List[List[int]]) -> int:
    def dist(p1, p2):
        return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1])

    n, m = len(workers), len(bikes)
    assigned = [False] * m
    answer = float('inf')

    def assign(wi, acc):
        nonlocal answer
        if wi >= n:
            answer = min(answer, acc)
            return

        if acc >= answer:
            return

        for bi in range(m):
            if assigned[bi]:
                continue
            assigned[bi] = True
            worker, bike = workers[wi], bikes[bi]
            assign(wi + 1, acc + dist(worker, bike))
            assigned[bi] = False

    assign(0, 0)
    return answer
```

 - 이렇게하면 $$ O(M! / (M-N)!) $$ 라는 굉장한 시간 복잡도가 나와서
   (...) 파이썬은 타임아웃난다.
