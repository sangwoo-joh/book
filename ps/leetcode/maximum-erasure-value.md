---
layout: page
tags: [problem-solving, leetcode, python, array, two-pointers, hash-table]
title: Maximum Erasure Value
---

# [Maximum Erasure Value](https://leetcode.com/problems/maximum-erasure-value/)

 정수 배열 `nums`가 주어진다. 여기서 **유일한 원소**만을 담은 **부분
 배열**을 삭제하고 싶다. 어떤 부분 배열을 삭제해서 얻을 수 있는
 **점수**는 그 부분 배열의 원소의 합과 같다.

 **딱 하나** 부분 배열만을 삭제했을 때 획득할 수 있는 **점수의
 최대값**을 구하자.

 배열의 길이는 $$ 1 \sim 10^5 $$ 이고 원소의 범위는 $$ 1 \sim 10^4 $$
 이다. 따라서 가능한 점수는 32비트 정수 안에 다 들어갈 수 있다(대충
 10억 언저리).

## 투 포인터 접근

 문제 설명을 읽었을 때 가장 먼저 떠오른 유사 문제는 [반복되는 글자
 없는 가장 긴 부분
 문자열](../longest-substring-without-repeating-characters)
 문제였다. 해당 문제를 이 문제 식으로 설명하면, 유일한 원소만을 담은
 부분 배열 중 가장 길이가 긴 것을 구하는 문제이다. 여기서는 길이가
 아니라 해당 부분의 *합*을 구하기만 하면 될 것 같았다. 그래서 예전
 풀이 방법을 떠올리며 아래와 같이 짜서 제출했다.

```python
def maximumUniqueSubarray(nums):
    previous_occurrence = {}
    start = 0
    score = 0
    for end, num in enumerate(nums):
        if num in previous_occurrence:
            start = max(start, previous_occurrence[num] + 1)
        previous_occurrence[num] = end
        score = max(score, sum(nums[start:end + 1]))
    return score
```

 예전 문제와 마찬가지로 해시 테이블에 이전에 나타났던 위치의 인덱스를
 기록해두면서, 이전 위치가 발견된 경우 (원소가 유일해야 하므로) 이전
 위치 다음 위치로 빨리감기를 해준다. 이때 주의할 것은 역시 코너
 케이스로, 예를 들어 `[1, 2, 2, 1]`에서 `1`, `2`를 거쳐 `{1: 0, 2:
 1}`을 만들고 나면 두번째 `2`를 만나면서 `start = 2`가 되고, 또 두번째
 `1`을 만날 때 `start = 1`이 되어 되려 줄어버리는 경우가 발생하기
 때문에, `start`는 무작정 이전에 나타났던 위치의 다음 위치로
 빨리감기를 하면 안되고 지금 위치보다 더 클 때에만 빨리감기를
 해야한다.

 이렇게 하면 문제의 조건에 맞게 잘 구현했고 복잡도도 나쁘지
 않아보이지만, 그렇지 않다. 시간 초과가 났다.

## + 부분합

 시간 초과가 난 부분은 바로 점수를 계산하는 부분, 즉 배열의 합을
 구하는 부분이다. 반복문 자체는 투 포인터를 이용해서 `O(N)` 만큼만
 돌고 있지만, 매번 점수를 계산하기 위해서 `sum(nums[start:end+1])`
 부분을 일일이 구하고 있는 것이 문제였다.

 따라서 이 부분만 부분합으로 최적화해주면 된다. 부분합을 구할 때에는
 인덱스에 주의해야 하는데, 아무것도 더하지 않은 상태인 0을 유지해줘야
 한다는 것만 주의하면 된다.

```python
def maximumUniqueSubarray(nums):
    n = len(nums)
    partial_sum = [0] * (n + 1)
    for i in range(n):
        partial_sum[i+1] = partial_sum[i] + nums[i]

    previous_occurrence = {}
    start = 0
    score = 0
    for end, num in enumerate(nums):
        if num in previous_occurrence:
            start = max(start, previous_occurrence[num] + 1)
        previous_occurrence[num] = end
        score = max(score, partial_sum[end + 1] - partial_sum[start])
    return score
```

 - 길이 `n`의 정수 배열의 부분합을 구하면 길이가 `n + 1`이 된다.
 - 이제 부분합을 알기 때문에 점수를 `O(1)`만에 계산 가능하다. 이때
   인덱스에 주의하자. `start` 부터 `end` (둘다 인덱스) 까지의 부분합은
   `end`까지의 부분합에서 `start - 1`까지의 부분합을 뺀 값이 되고,
   우리가 계산해둔 부분합의 인덱스는 모두 1씩 더해졌으므로, 부분합에
   들어갈 인덱스는 `end + 1`과 `start`가 된다.

---

 처음으로 솔루션이나 힌트의 도움없이 푼 Hard 난이도 문제라는 것을
 기록해둔다. 예이!

 ... 는 근데 쥐도 새도 모르게 난이도가 Medium으로 다운그레이드 되어
 있었다... 흑흑.

---
