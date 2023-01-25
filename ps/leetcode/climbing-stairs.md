---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Climbing Stairs
---

# [Climbing Stairs](https://leetcode.com/problems/climbing-stairs/)

 계단을 올라가려고 한다. `n` 개의 계단을 올라가야 꼭대기에 도착한다.

 각 단계에서 계단을 1개 또는 2개 씩 올라갈 수 있다. 꼭대기까지
 올라가기 위한 방법은 총 몇 가지가 있는지 계산하자.

 $$ 1 \leq n \leq 45 $$ 이다.

 예를 들어, `n = 3`일 때, 총 세 가지 방법이 있다:
 - 1 + 1 + 1
 - 1 + 2
 - 2 + 1

## 피보나치 + 다이나믹 프로그래밍

 `k` 개의 계단을 올라가는 방법을 구하려면 다음 두 가지 방법이 있다는
 것을 알 수 있다:
 - `k-1` 개의 계단을 올라가는 방법 + 1 (계단 1개)
 - `k-2` 개의 계단을 올라가는 방법 + 1 (계단 2개)

 즉, `f(k)`를 "`k`개의 계단을 올라가는 방법의 수"라고 한다면, 다음
 점화식이 성립한다: `f(k) = f(k-1) + f(k-2)`. 그리고 이 식은 그냥
 피보나치 공식과 같다.

 따라서, 이 문제는 피보나치 수를 구하는 것과 같다. 피보나치 수는
 다이나믹 프로그래밍의 대표적인 예시이고, `n`의 피보나치 수를 구하기
 위해서 `n-1`부터 `0`(또는 `1`)까지의 모든 부분 문제를 계산해야
 하므로, 탑 다운 방식의 메모이제이션이 잘 먹히는 문제이기도 하다.

```python
import functools
def climbStairs(n):
    @functools.cache
    def fib(n):
        if n == 1:
            return 1
        if n == 2:
            return 2
        return fib(n-1) + fib(n-2)
    return fib(n)
```
