---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Paint House
---

# [Paint House](https://leetcode.com/problems/paint-house/)

 `n`개의 집이 일렬로 서있다. 각각의 집은 빨강, 파랑, 초록 셋 중 하나의
 색으로 칠할 수 있다. 각 집을 어떤 색으로 칠하는지에 따라서 비용이
 다르다. 서로 인접한 두 집 끼리는 같은 색이 아니도록 모든 집을 칠하고
 싶다.

 각 집을 특정 색으로 칠하는 비용 정보는 `n x 3` 행렬인 `costs`에
 담겨있다. 예를 들어, `costs[0][0]`은 `0`번 집을 빨강으로 칠하는
 비용이고, `cost [1][2]`는 `1`번 집을 초록으로 칠하는 비용이다.

 모든 집을 칠하기 위한 **최소의 비용**을 구하자.

 집의 수는 1 ~ 100, 비용의 범위는 1 ~ 20 이다.

## 탐색 공간을 다이나믹 프로그래밍 하기

 순서대로 `0`번 집부터 칠해나아간다고 생각해보자. 그러면, 다음 두 가지
 정보를 상태로 유지하고 진행해야 한다는 것을 깨달을 수 있다.
 - 지금 칠해야 할 집 인덱스 `cur`
 - 이전 집에 칠한 색깔 `prev_color`

 그러면 다음 관계를 알 수 있다: 이전 집 색깔 `prev_color`에 대해서
 현재 집 `cur`를 칠하는 최소 비용 = (이전 집 색과 다른 모든 색에
 대해서 현재 집을 칠할 비용 + 이 색에 대해서 `cur + 1`를 칠할 최소
 비용) 중 최소.

 그리고 자연스럽게, 이 중에서 반복되는 부분 문제가 발생함을 알 수
 있고, 이를 메모아이즈하면 풀린다.

```python
from functools import cache
def minCost(costs):
    total = len(costs)

    @cache
    def paint(cur:int, prev_color:int) -> int:
        if cur == total:
            return 0

        min_cost = float('inf')
        for color, cost in enumerate(costs[cur]):
            if color == prev_color:
                continue
            cur_cost = cost + paint(cur + 1, color)
            min_cost = min(min_cost, cur_cost)
        return min_cost
    return paint(0, -1)
```

 - 재귀 함수의 베이스 케이스는 집을 끝까지 칠했을 때, 즉 마지막 집에
   도달했을 때이고, 이때의 최소 비용은 아무것도 칠하지 않아도 되므로
   0이다.
 - 재귀 함수를 처음 호출할 때, 이전 집을 칠한 색깔 `prev_color`는
   빨강, 파랑, 초록인 `0, 1, 2`만 아니면 다 괜찮다. 색깔들이 `costs`의
   인덱스로 표현되고 있어서, 여기서는 `-1`을 넘겨주었다.

# [Paint House II](https://leetcode.com/problems/paint-house-ii/)

 이번에는 3개의 색이 아니라 `k`개의 색을 칠할 수 있고 나머지 조건은
 [Paint House](#)와 같다.

 $$ 2 \leq k \leq 20 $$ 이라서, 그냥 위의 솔루션을 그대로 재활용할 수
 있다.

# [Paint House III](https://leetcode.com/problems/paint-house-iii/)

 작은 도시에 `m`개의 집이 일렬로 있는데 각각의 집을 반드시 `n`개의
 색깔 중 하나로 칠해야 한다. 색깔은 `1` 부터 `n`까지 레이블링 되어
 있다. 이 중 몇몇 집은 작년 여름에 이미 칠해놔서 지금 칠하지 않아도
 된다.

 같은 색깔로 칠해진 집들의 연속적인 그룹을 *이웃*이라고 한다. 예를
 들어, `houses = [1, 2,2, 3,3, 2, 1,1]`은 다섯 개의 이웃 `[{1}, {2,2},
 {3,3,}, {2}, {1,1}]`을 포함하고 있다.

 현재 집의 색깔 배열 `houses`와 `m x n` 행결 `cost`와 정수
 `target`값이 주어진다.
 - `houses[i]`는 `i`번째 집의 현재 색깔이다. `0`이면 아직 칠해지지
   않았다.
 - `cost[i][j]`는 `i`번째 집을 `j + 1`색으로 칠할 때 드는 비용이다.

 이때, 아직 색이 칠해지지 않은 모든 집을 칠해서 정확히 `target` 개의
 이웃이 되도록 하기 위한 최소의 비용을 구하자. 만약 불가능한 경우
 `-1`을 리턴하자.

 `houses`와 `costs` 배열의 길이 `m`은 모두 같고 1 ~ 200
 사이이다. 색깔의 종류(`cost[i]`의 길이)는 1 ~ 20 이다. `target`은 1과
 `m` 사이의 값이다. 각각의 비용 값은 1 ~ 10,000 사이이다.

## 탐색 공간을 다이나믹 프로그래밍 하기

 이전 문제와는 달리 인접한 집끼리 반드시 서로 다른 색일 필요는 없고,
 대신 *이웃*이라는 개념이 새로 추가되었다. 따라서, 추적해야 하는 상태
 값에 하나를 더 추가해야 한다: 바로 *지금까지 생성된 이웃 수*이다. 즉,
 - 지금 칠할지 말지 확인하려는 집의 인덱스 `cur`
 - 이전에 칠한 집의 색깔 `prev_color`
 - 지금까지 만들어진 이웃 수 `neighbor`

 즉, 우리가 각 단계마다 하는 결정은 바로 직전 단계의 상태(위의 세
 가지)에 영향을 받는다.

```python
from functools import cache
def minCost(houses, cost, m, n, target):
    @cache
    def paint(cur, prev_color, neighbor):
        if cur == m:
            return 0 if neighbor == target else float('inf')
        if neighbor > target:
            return float('inf')
        if houses[cur] != 0:
            neighbor = neighbor if houses[cur] == prev_color else neighbor + 1
            return paint(cur + 1, houses[cur], neighbor)

        min_cost = float('inf')
        for color in range(1, n+1):
            new_neighbor = neighbor if color == prev_color else neighbor + 1
            cur_cost = cost[cur][color - 1] + paint(cur + 1, color, new_neighbor)
            min_cost = min(min_cost, cur_cost)
        return min_cost

    answer = paint(0, 0, 0)
    return answer if answe != float('inf') else -1
```

 - 집을 끝까지 칠했다면, 즉 현재 칠할 집의 인덱스가 끝이라면, 최소
   비용을 곧바로 알 수 있다. 여기서는 한 가지 조건을 더 확인해야
   하는데, 바로 지금까지 만들어진 이웃의 수가 `target`과 같은지
   확인하는 것이다. 이웃 수 조건을 만족한다면 최소 비용은 0이 되고,
   그렇지 않으면 무한대가 되어야 한다.
 - 문제의 조건 덕분에 현재 집을 끝까지 봤는지와는 관계 없이 탐색
   공간을 프루닝할 수 있다. 바로 지금까지 만든 이웃의 수가 `target`을
   넘어버린 경우이다. 이때는 집을 끝까지 칠해봐야 소용이 없기 때문에
   곧바로 무한대의 비용을 리턴하면 된다.
 - 이전의 문제와 달리 이번에는 색깔이 `0`일 때 아직 색을 칠하지 않은
   집이다. 그리고 우리는 이런 집만을 칠해야 한다. 따라서, 현재 집의
   색깔이 `0`이 아니라면, 작년 여름에 이미 칠한 집이므로, 이 색깔을
   그대로 이용해서 이웃 수를 새로 계산하고 다음 집을 칠해야 한다.
 - 위의 세 가지 기저 조건을 다 확인하고 나면, 이제 재귀적으로 최소
   비용을 계산할 수 있다. 색깔의 범위가 이번에는 1부터 `n`까지 임에
   주의하면서, 모든 색깔에 대해서 재귀적으로 확인한다. 이때 이전
   색깔과 지금 고른 색깔이 같은지 다른지에 따라 이웃의 수가 증가할 수
   있다는 것을 주의하면서 계산한다.
 - 주어진 이웃의 수 조건을 만족하는 것이 불가능한 경우도 있으므로,
   최종적으로 구한 비용이 무한대인지 아닌지에 따라 `-1`을 리턴할 수도
   있다.
