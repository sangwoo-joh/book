---
layout: page
tags: [problem-solving, leetcode, python, lru-cache]
title: Unique Paths
last_update: 2023-04-05 09:51:59
---

# [Unique Paths](https://leetcode.com/problems/unique-paths/)
 `m x n` 격자판이 주어지고 왼쪽 제일 위에 로봇이 있다. 로봇은 한 번에
 한 칸 오른쪽 또는 아래로 움직일 수 있다. 최종적으로는 오른쪽 제일
 아래로 가려고 한다. 이때 가능한 "유니크 경로"의 개수는?

 예를 들어, `m = 3`, `n = 2` 라고 하자. 그러면 가능한 경우는 총 세
 가지이다.
  1. 오른쪽 -> 아래 -> 아래
  2. 아래 -> 아래 -> 오른쪽
  3. 아래 -> 오른쪽 -> 아래

## Brute Force
 먼저 무식하게 풀어보자. 시작 지점을 `(1, 1)`, 도착 지점을 `(m, n)`
 으로 모델링하자. 한 번에 아래 또는 오른쪽으로만 움직일 수 있다.

 예를 들어, 다음과 같은 `3 x 2` 격자를 생각해보자. 아래 각 튜플은
 격자의 좌표를 나타낸다.

```python
(1, 1) (1, 2)
(2, 1) (2, 2)
(3, 1) (3, 2)
```

 `(1, 1)` 에서 출발해서 `(3, 2)`에 도착하는 게 목표다. 그럼 `(3, 2)`로
 올 수 있는 가지 수는 몇 개일까?

```python
|   |   |
|   | u |
| l |l+u|
```

 한 턴에 가능한 움직임이 오른쪽과 아래쪽 밖에 없으므로, 위쪽으로 올
 경우의 수 `u`와 왼쪽으로 올 경우의 수 `l`을 합한것 과 같다.

 이런식으로 재귀적으로 거꾸로 거슬러 계산하면 구해질 것 같다. 그럼
 Base Case는 뭘까? 만약 출발 지점에서 출발하는 그림을 생각해보면,
 아래와 같이 테두리, 즉 오른쪽으로만 or 아래로만 움직이는 경우는
 가능한 경우가 1개 뿐이다.


```python
|   | 1 |
| 1 |   |
| 1 |   |
```

 따라서 Base Case는 둘 중 하나라도 `1`일 때, 가능한 경우의 수가
 `1`개임을 뜻한다.

 이걸 코드로 구현하면 다음과 같다.

```python
def unique_paths(m, n):
    def pathof(x, y):
        if x == 1 or y == 1:
            return 1
        return pathof(x-1, y) + pathof(x, y-1)
    return pathof(m, n)
```


## 메모아이제이션
 Brute Force는 알았으니 좀더 복잡도를 줄여보자. 더 큰 격자를
 생각해보면 중복되는 부분이 있음을 알 수 있다. 예를 들어 다음과 같이
 큰 격자가 있을 때,

```python
|   |   |   |   |   |
|   |   |   | p | u |
|   |   |   | l | g |
```

 도착지점인 `g`의 값을 알아내기 위해서는 `u`, `l`을 알아야
 한다. 그런데 가능한 움직임이 오른쪽/아래쪽 뿐이므로, `u`도 `p`위치의
 값이 필요하고 `l`도 `p` 위치의 값이 필요하다. 즉, `p`를 위한 계산이
 중복된다.

 따라서, 아래와 같이 이전 결과를 캐싱해두면 더 빠른 결과를 얻을 수
 있다.

```python
from functools import cache

def unique_paths(m, n):
    @cache
    def pathof(x, y):
        if x == 1 or y == 1:
            return 1
        return pathof(x-1, y) + pathof(x, y-1)
    return pathof(m, n)
```
