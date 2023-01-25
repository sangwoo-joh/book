---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming, lru-cache]
title: Minimum Difficulty of a Job Schedule
---

# [Minimum Difficulty of a Job Schedule](https://leetcode.com/problems/minimum-difficulty-of-a-job-schedule/)
 `d` 일의 기간 안에 업무 일정을 스케쥴링 하려고 한다. 업무는 서로
 의존적이다. 즉, `i` 번째 업무를 하려면 모든 `0 <= j < i` 인 `j`
 업무들이 완료되어야 한다.

 매일 하루에 최소한 하나의 업무는 끝내야 한다. 업무 스케쥴의 총
 난이도는 `d` 일 동안의 난이도의 합과 같다. 하루의 난이도는 그 날
 완료할 업무의 난이도 중 가장 높은 난이도와 같다.

 업무 난이도 목록 `jobDifficulty`랑 기간 `d`가 주어진다. `i` 번째
 업무의 난이도는 `jobDifficulty[i]` 이다.

 가능한 업무 스케쥴링의 총 난이도 중 **최소**의 난이도를
 구하자. 불가능하면 `-1`을 리턴한다.

 예를 들어 `jobDifficulty = [6, 5, 4, 3, 2, 1]` 이고 `d = 2` 라고
 하자. 가능한 최소의 난이도는 `7`이 되는데, 그 이유는 첫날 `(2, 3, 4,
 5, 6)` 총 다섯 작업을 완료하고 다음날 `1`의 작업을 하면 된다.

 반면 `jobDifficulty = [9, 9, 9]` 이고 `d = 4`이면, 가능한 스케쥴링이
 없기 때문에 `-1`이다.

## 다이나믹 프로그래밍
 접근 방법이 선뜻 떠오르지 않는 문제였다. 일단 예시를 보면 가장
 간단하게 처리할 수 있는 케이스가 하나있는데, 바로 스케쥴링이 불가능한
 경우다. 업무의 개수가 일정보다 작으면 일정마다 업무 1개를 할당할 수
 없기 때문에 불가능하다.

```python
def min_difficulty(jobDifficulty, d):
    if len(jobDifficulty) < d:
        return -1
```

 그 다음은 어떻게 접근해야할까?

 이 문제는 결국 다음과 같다:

> 주어진 리스트를 `d`개로 나눌건데, 각 부분의 최대 값의 전체 합이
> 최소가 되게 한다.

 그럼 Brute Force를 생각해보면, 가능한 모든 부분을 다 만들어본 다음에,
 각 부분의 최대값들의 합이 최소가 되는 값을 구하면 된다. 예를 들어
 `(a, b, c, d)`의 업무가 있고 이걸 3일에 나눠서 스케쥴링 하는 문제를
 생각해보자. 이는 곧, 이 4개의 업무를 3개로 나누면서 해당 조건을
 만족하게끔 하는거다.

 먼저 첫째날에 가능한 경우를 생각해보자. 주어진 업무가 **순서대로**
 진행되어야 하므로, 갑자기 `c` 를 하거나 할 순 없다. 따라서 첫째날은
 항상 `a` 부터 가능한데, 이는 곧 인덱스 `0`부터를 뜻한다. 그럼 첫째날
 가능한 업무의 인덱스 범위는 어디까지일까? 총 3일에 걸쳐 해야하므로
 첫째날에 4개의 모든 업무를 해버리면 안된다. 따라서 최소 이틀에 하나
 씩 할 양, 즉 `(d - 1)` 만큼의 양은 보장해줘야 한다. 즉 인덱스의
 범위는 `len(jobDifficulty) - (d - 1) - 1`까지 이다.

 이걸 토대로 Brute Force를 구현하면 다음과 같다.

```python
def min_difficulty(jobDifficulty, d):
    if len(jobDifficulty) < d:
        return -1

    def dfs(idx, day):
        if day == d:
            # no more division is possible.
            # return the maximum among all remainings
            return max(jobDifficulty[idx:])

        min_diff = float('inf')  # accum minimum sum of each day's difficulties
        day_diff = 0  # accum day's possible maximum difficulty

        for i in range(idx, len(jobDifficulty) - d + day)):
            day_diff = max(day_diff, jobDifficulty[i])
            min_diff = min(min_diff, day_diff + dfs(i + 1, d + 1))

        return min_diff

    return dfs(0, 1)
```
 - `idx`는 지금 날짜에 배치 가능한 업무의 **시작 인덱스**
   이다. 여기부터 시작해서 가능한 업무의 인덱스 범위 사이 중에서 가장
   큰 난이도를 찾아야 한다. 이때 `1`일 차에서 시작해서 `d`까지
   진행하기 때문에, `len(jobDifficulty) - d + day` 까지의 범위가 되고
   `range`를 썼기 때문에 마지막 `- 1`은 생략된다. 가능한 범위를
   확인하면서 최대값을 누적하고, 동시에 합의 최소값을 누적한다. 이때
   합의 최소는 현재 난이도 + 다음 날짜들의 난이도 합 중 최소가 된다.
 - `day`가 마지막 날이 되버리면, 남은 업무를 더 이상 쪼갤 수 없기
   때문에 이때 가능한 난이도는 현재 인덱스부터 끝까지 중에서 최대
   값이다.

 당연하지만, 이렇게 무식하게 짜면 복잡도가 엄청나다. 그렇다면 과연
 여기에 중복되는 문제가 있을까? `(a, b, c, d, e)` 를 3일로 나누는
 예시를 생각해보자.

 먼저 첫째날 가능한 범위는 `max(a)`와 `max(a, b)`, `max(a, b, c)` 세
 가지이다. 총 5개이고 첫째날이므로, `5 - 3 + 1 = 3`이기 때문이다.

```
(a, b, c, d, e)
-> max(a) -> next(b, c, d, e)
-> max(a, b) -> next(c, d, e)
-> max(a, b, c) -> next(d, e)
```

 이 두 가지 경우에 대해서 다음 이틀 동안의 스케쥴을 구하는 함수를
 퉁쳐서 `next`라고 하면 위 그림과 같다. 첫번째 `next(b, c, d, e)`는
 **이틀** 동안 `(b, c, d, e)` 네 가지 업무를 스케쥴링하는 것이고,
 두번째 `next(c, d, e)`는 이틀동안 `(c, d, e)` 세 가지 업무를 스케쥴링
 하는 것이고, `next(d, e)`는 `(d, e)` 두 가지 업무를 스케쥴링 하는
 것이다. 먼저 `next(b, c, d, e)`를 풀어 생각해보자.

```
(a, b, c, d, e)
-> max(a) -> max(b) -> next(c, d, e) = max(c, d, e)
-> max(a) -> max(b, c) -> next(d, e) = max(d, e)
-> max(a) -> max(b, c, d) -> next(e) = max(e)
```

 이틀을 쪼개야 하므로 가능한 경우는 위 그림과 같다. 이때 마지막 날에는
 남은 날짜가 하루 뿐 (즉, day가 `d`가 됨)이기 때문에, `dfs` 콜의 base
 case에 해당한다.

 그럼 이번에는 `next(c, d, e)`를 풀어 생각해보자.

```
(a, b, c, d, e)
-> max(a, b) -> max(c) -> next(d, e) = max(d, e)
-> max(a, b) -> max(c, d) -> next(e) = max(e)
```

 슬슬 중복이 보이고 있음을 알 수 있다. 남은 것도 풀어 생각해보자.

```
(a, b, c, d, e)
-> max(a, b, c) -> max(d) -> next(e) = max(e)
```

 남은 날짜가 이틀 밖에 안되기 때문에 자명하게 풀린다. 모든 케이스를
 나열하면 다음과 같다.

```
(a, b, c, d, e)
-> *max(a) -> max(b) -> next(c, d, e) = max(c, d, e)
-> *max(a) -> max(b, c) -> *next(d, e) = max(d, e)
-> *max(a) -> max(b, c, d) -> *next(e) = max(e)
-> *max(a, b) -> max(c) -> *next(d, e) = max(d, e)
-> *max(a, b) -> max(c, d) -> *next(e) = max(e)
-> max(a, b, c) -> max(d) -> *next(e) = max(e)
```

 중복되는 케이스에는 `*`를 찍어놨다. 이 작은 케이스에서도 중복 계산이
 꽤 많이 발생함을 알 수 있다. 따라서, 여기서도 메모아이제이션을
 활용하면 복잡도를 확 줄일 수 있다.

```python
from functools import cache

def min_difficulty(jobDifficulty, d):
    if len(jobDifficulty) < d:
        return -1
    @cache
    def dfs(idx, day):
        if day == d:
            # no more division is possible.
            # return the maximum among all remainings
            return max(jobDifficulty[idx:])

        min_diff = float('inf')  # accum minimum sum of each day's difficulties
        day_diff = 0  # accum day's possible maximum difficulty

        for i in range(idx, len(jobDifficulty) - d + day)):
            day_diff = max(day_diff, jobDifficulty[i])
            min_diff = min(min_diff, day_diff + dfs(i + 1, d + 1))

        return min_diff

    return dfs(0, 1)
```


# 번외: 구간 평균의 합 중에서 가장 큰 합 구하기
 Largest Sum of Averages 를 아주 유사한 접근으로 풀 수 있다. 숫자 배열
 `A`를 `K` 개의 그룹으로 쪼갤 때, "점수"는 각 그룹의 평균의
 합이다. 이때 가장 큰 합은 뭘까?

 위의 DFS 접근이 결국 인덱스마다 상태(최대값)을 구하고 이 상태로부터
 가능한 다음 상태(난이도의 합) 중에서 최소 값을 구하는 문제였다면, 이
 문제는 인덱스마다 상태(평균값)을 구하고 이로부터 가능한 다음
 상태(점수의 합) 중에서 최대 값을 구하는 문제이다. 거의 유사하게 풀 수
 있다.

```python
from functools import cache
from statistics import mean

def largest_score(A, K):
    if K == 1:
        return

    n = len(A)

    @cache
    def seg_mean(start, end):
        return mean(A[start:end])

    @cache
    def dfs(idx, k):
        if k == K:
            return seg_mean(idx, n)

        max_sum = 0
        for i in range(idx, n - K + k):
            max_sum = max(max_sum, seg_mean(idx, i + 1) + dfs(i + 1, k + 1))
        return max_sum
    return dfs(0, 1)
```
 - 평균 값을 구하기 위해서 `statistics` 모듈의 `mean` 함수를
   활용했다. 그리고 매 구간마다 평균 값을 계속 계산할 필요는 없기
   때문에, 이 값도 메모아이즈한다.
 - 여기서도 매번 최대 `len(A) - K + k` 까지의 범위가 가능하다. 그리고
   범위가 늘어갈 때마다 시작 인덱스는 `idx` 그대로인 채로 끝 구간만
   변하므로, `seg_mean` 함수를 십분 활용 가능하다.
 - 한 가지 주의할 점은, 평균 값을 계산할 때 `start`은 인덱스지만
   `end`는 인덱스가 아니라 파이썬의 `range` 형식과 같이 마지막 다음
   위치를 가리키므로, 매 범위마다 `seg_mean`을 호출할 때 `(idx, i)`가
   아니라 `(idx, i+1)` 범위에 대해서 호출해야 한다는 점이다.
