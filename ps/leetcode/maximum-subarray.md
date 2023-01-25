---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Maximum Subarray
---

# [Maximum Subarray](https://leetcode.com/problems/maximum-subarray/)

 정수 배열 `nums`가 주어졌을 때, 합이 가장 큰 부분 배열의 합을
 리턴하자. 부분 배열이란 배열의 연속적인 일부분이다.

 배열의 크기는 1~100,000 사이이고 배열의 값은 -10,000~10,000 사이이다.

## O(N^2) - 타임아웃

 이게 왜 Easy 난이도인지 모르겠네. 아무튼 가장 먼저 Brute Force부터
 생각해보자. 그냥 모든 합을 다 구해보면서 최대 값을 업데이트 하면
 된다. 단, 이중 루프를 돌 때 안쪽 인덱스가 바깥쪽 인덱스 이전의 값을
 볼 필요는 없기 때문에 다음과 같이 하면 *족굼* 더 낫긴 하지만 여전히
 타임아웃 난다.

```python
def maxSubArray(nums):
    maxsum = float('-inf')
    for i in range(len(nums)):
        cursum = 0
        for j in range(i, len(nums)):
            cursum += nums[j]
            maxsum = max(maxsum, cursum)

    return maxsum
```


## Kadane's Algorithm

 몰랐는데 이 문제를 푸는 유명한 [카데인의
 알고리즘](https://en.wikipedia.org/wiki/Maximum_subarray_problem#Kadane's_algorithm)
 이라는 테크닉이 있다고 한다. 이 방법은 주어진 배열을 훑으면서, 인덱스
 `i`에 있을 때 인덱스 `i`로 끝나는 부분배열의 합 중 최대값을 구한다.

 Loop Invariant는 다음과 같다. `i`번째 인덱스에서, `current_sum`의
 예전 값은 `[0, ..., i-1]` 부분 배열의 합 중에서 최대값을 담고
 있다. 따라서, `current_sum + nums[i]`는 `[0, ..., i]` 부분 배열의
 합이 된다. 여기서 음수가 가능하기 때문에, 실제로는 이전까지 누적 합을
 *버리고* 지금 위치에서 새로 시작하는 것이 더 나을 수도 있다. 따라서
 `current_sum`은 `nums[i]`가 될 수도 있다.

 그리고 매번 `current_sum`을 업데이트할 때마다, 지금까지 계산한
 `current_sum` 중에서 최대 값을 업데이트하면, 이게 바로 우리가 원하는
 값이 된다.

 이 아이디어를 구현하면 다음과 같다.

```python
def maxSubArray(nums):
    maxsum, cursum = nums[0], nums[0]
    for n in nums[1:]:
        cursum = max(cursum + n, n)
        maxsum = max(maxsum, cursum)
    return maxsum
```

 - `cursum = max(cursum + n, n)` 부분이 바로 위에서 길게 설명한
   부분이다. 현재 위치에서 `cursum`의 값은 (현재 위치 직전까지의) 이전
   누적 합 중 최대 값이지만, 이걸 버리고 지금 위치에서부터 다시
   시작하는 것이 더 괜찮은 선택일 수 있기 때문이다.
