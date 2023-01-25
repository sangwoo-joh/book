---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Partition Equal Subset Sum
---

# [Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/)

 비어있지 않은 배열 `nums`에 양수만 담겨 있다. 이 배열을 각 배열의
 합이 똑같은 두 개의 배열로 쪼갤 수 있는지 확인하자.

 - 배열 크기: 1~200
 - 배열 값: 1~100


## Knapsack Problem
 - 전통적인 냅색 문제랑 비슷하다.
 - 일단 전체 합이 홀수면 불가능.
 - 합이 `subset_sum`인 크기 `n`인 배열 `nums`에서 출발. 두 배열 중
   하나만 추적. 원소 값을 하나씩 빼서 0이 되는지 보면 된다. 어떤 원소
   `x`에 대해서 다음 두 가지 경우가 가능함:
   - `x`가 해당 Subset에 포함: `subset_sum -= x`
   - `x`가 포함 안됨, 따라서 `subset_sum`은 그대로.
   - Base case: `subset_sum`이 0이 되면 `True`, 배열의 끝까지 가거나
     (따라서 현재 원소 `x`를 추적하는 인덱스가 필요) `subset_sum < 0`
     이면 불가능이므로 `False`
 - 역시 부분 문제가 중복되므로 메모아이제이션 가능

```python
import functools
def canPartition(nums):
    n = len(nums)

    @functools.cache
    def can_reach(i, subsum):
        if subsum == 0:
            return True
        if i == n or subsum < 0:
            return False

        return can_reach(i+1, subsum-nums[i]) or can_reach(i+1, subsum)

    total = sum(nums)
    if total % 2 != 0:
        return False

    return can_reach(0, total // 2)
```
