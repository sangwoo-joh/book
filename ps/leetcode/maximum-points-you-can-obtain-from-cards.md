---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Maximum Points You Can Obtain from Cards
---

# [Maximum Points You Can Obtain from Cards](https://leetcode.com/problems/maximum-points-you-can-obtain-from-cards/)

 여러개의 카드가 한 줄로 나열되어 있다. 각각의 카드에는 점수가
 적혀있다. 이 카드의 점수는 `cardPoints` 배열로 들어온다.

 한 번의 단계에서, 당신은 카드 줄의 제일 앞 또는 제일 뒤에서 한 장을
 뽑을 수 있다. 이렇게 정확히 `k`번 카드를 뽑을 수 있다.

 당신의 점수는 이렇게 뽑은 카드의 점수의 합이다.

 이때 얻을 수 있는 최대 점수를 구하자.

 카드는 1~100,000개, 각 점수는 1~10,000점이다. `k`는 1과 카드 배열
 길이 사이의 값이 보장된다.

## 하라는 대로 하기

 그냥 하라는 대로 정직하게 구현해봤다.

 먼저 0부터 `k`까지의 합을 구한다. 즉, 카드 앞에서만 `k`개를 뽑았을
 때의 점수이다. 이제 이 고정 윈도우 크기를 그대로 유지하면서 배열
 전체를 훑으면서 각각의 합을 계산하고, 동시에 그 중 최대 값을
 누적해가면 된다.

 이때 파이썬의 음수 인덱스를 활용하면 편하다. 배열의 가장 마지막
 원소를 `-1`부터 시작해서 인덱스로 접근할 수 있다.

```python
def maxScore(cardPoints, k):
    score = sum(cardPoints[:k])
    answer = score
    for i in range(1, k + 1):
        score = score - cardPoints[k - i] + cardPoints[-i]
        answer = max(answer, score)

    return answer
```

 - 1부터 `k`까지 돌면서, 현재 점수 구간에서 먼저 가장 뒷쪽을 빼고
   (`cardPoints[k-i]`), 카드 배열 가장 뒷쪽을 더해준다
   (`cardPoints[-i]`).

## 역발상하기

 약간 [`x`를 0으로 만드는 최소 연산
 횟수](../minimum-operations-to-reduce-x-to-zero) 문제랑 비슷한 접근을
 해볼 수 있는데, 바로 카드 점수의 최대값을 구하는게 아니라, 점수의
 합이 최소가 되는 카드의 연속 배열을 구하는 것이다. 그러면 전체 합에서
 최소 점수를 빼면 된다. 참고로 이는 카드 점수가 전부 양수라서 가능한
 테크닉이다.

 일단 `k`개를 고르는 것이 아니라 `k`개를 뺀 나머지를 구하는 것이기
 때문에, 초기 점수는 `n - k` 까지의 합이 된다. 그러면 여기서부터
 하나씩 고정 윈도우를 끝까지 이동하면서 이 중 최소가 되는 것을 구하고,
 최종적으로 이를 전체 합에서 빼면 된다.

```python
def maxScore(cardPoints, k):
    total = sum(cardPoints)
    n = len(cardPoints)
    if n == k:
        return total
    cursum = sum(cardPoints[:n-k])
    minsum = cursum
    start = 0
    for i in range(n-k, n):
        cursum = cursum - cardPoints[start] + cardPoints[i]
        start += 1
        minsum = min(minsum, cursm)
    return total - minsum
```

 - 카드 점수를 앞에서부터 뺄 때 복잡하게 인덱스 연산을 할 거 없이 그냥
   `start` 변수를 하나 두고 0부터 증가시키면 속편하다.
