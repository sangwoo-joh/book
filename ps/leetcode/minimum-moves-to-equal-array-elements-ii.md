---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Minimum Moves to Equal Array Elements II
last_update: 2023-04-05 09:47:56
---

# [Minimum Moves to Equal Array Elements II](https://leetcode.com/problems/minimum-moves-to-equal-array-elements-ii/)

 정수 배열이 주어진다. 한 단계에서 원소 하나를 1만큼 증가시키거나
 감소시킬 수 있다. 이때, 모든 원소를 다 같이 만들기 위해서 필요한
 단계의 최소 횟수를 구하자.

 모든 정답과 원소의 범위는 32비트 정수형에 담긴다.

 배열의 크기는 1 ~ 100,000 사이이고 원소 값의 범위는 $$ -10^9 \sim
 10^9 $$ 이다.

## 중위값 찾기

 1씩 증가 또는 감소만 할 수 있기 때문에, 처음에는 데이터에서 일종의
 분산과 표준편차를 구하는 문제와 비슷하다고 생각했다. 그래서 각
 원소마다 평균과의 차이를 누적하면 되지 않을까 했는데, 반례가
 있다. 원소가 한쪽으로 많이 치우쳐 있을 때, 예를 들어 `[1, 2, 10]`과
 같은 경우, 평균을 구하면 `(1+2+10)/3 = 4`이고 모든 원소를 이 평균으로
 만들기 위해서 차이를 구하면 `[3, 2, 6]`이 되어 11이 최소 연산 수라고
 생각할 수 있다. 하지만 실제로는 모든 원소를 `2`로 만드는게 가장 연산
 수가 적은데, `[1, 0, 8]`이 되어 총 9번의 연산만 필요하기 때문이다.

 따라서 여기서 알 수 있는 것은 평균이 아니라 (정렬된) 배열의
 **중위값**으로 만드는 연산이 최소 횟수라는 것이다. 그러므로 다음과
 같이 구현할 수 있다.

```python
def minMoves2(nums):
    seq = sorted(nums)
    n = len(nums)
    median = seq[n//2] if n % 2 == 1 else ((seq[n//2-1] + seq[n//2]) // 2)
    moves = 0
    for num in nums:
        moves += abs(median - num)
    return moves
```

---

 그런데 위와 같이 정확한 방법으로 median을 구하는게 의미가 있을까?
 예를 들면 `[1, 2, 2, 10]`과 같이 중위값 계산에 쓰일 두 원소가 같으면
 당연히 이 중 아무거나 써도 되지만 `[1, 2, 9, 10]`과 같은 상황에서도
 유효할까? 일일이 계산해보면 다음과 같다:

 - `[1, 2, 9, 10]` 에서 중위값으로 `(2+9)/2 = 5`를 고름: `[4, 3, 4,
   5]` -> 합은 16
 - `[1, 2, 9, 10]` 에서 중위값으로 `2`를 고름: `[1, 0, 7, 8]` -> 합은
   16
 - `[1, 2, 9, 10]` 에서 중위값으로 `9`를 고름: `[8, 7, 0, 1]` -> 합은
   16

 즉 배열 크기가 짝수이더라도, 최소 횟수 계산을 위해 필요한 중위값
 계산에는 중간의 두 원소의 평균을 내지 않아도 된다! 어떤 걸 집어도
 똑같은 값(뒤집은)이 나오는 걸 확인할 수 있다. 따라서, 중위값을 배열
 크기의 짝/홀수에 따라 정확히 계산하지 않아도 된다.

```python
def minMoves2(nums):
    seq = sorted(nums)
    median = seq[len(nums)//2]
    return sum(abs(median - num) for num in nums)
```

---

## 번외: 왜 중위값일까?

 그럼 왜 "모든 원소를 같은 값으로 만들기 위한 최소의 연산"을 위해서
 모든 원소를 *중위값*으로 만들어야 할까? 여기에는 수학적인 증명이
 가능하다.

 먼저 다음과 같이 정의하자.
 - `k`: 모든 원소가 같아질 값
 - `count_before_k`: `k`보다 작은 원소의 수
 - `count_after_k`: `k`보다 큰 원소의 수
 - `sum_before_k`: `k`보다 작은 원소의 합
 - `sum_after_k`: `k`보다 큰 원소의 합

 그러면 모든 원소를 `k`로 만들기 위해서 필요한 연산의 수는 다음과 같이
 계산할 수 있다:

```python
number_of_moves = (k * count_before_k) - sum_before_k + (sum_after_k - (k * count_after_k))
```

 즉, 아래 두 가지 경우에 대해서 case analysis를 한다고 하면:
 - `k`보다 작은 원소를 `k`로 만들기 위해서는, `k`보다 작은 원소
   수(`count_before_k`)를 `k` 만큼 곱한 값에서 `k`보다 작은 원소의
   합(`sum_before_k`)을 뺀 것만큼의 연산이 필요하다. `k`보다 작은
   원소의 합이 당연히 더 작을 것이기 때문에 합을 뺀다.
 - 비슷하게, `k`보다 큰 원소를 `k`로 만들려면, `k`보다 큰 원소의
   합(`sum_after_k`)에서 `k`보다 큰 원소를 `k`만큼 곱한 값에서 뺀
   것만큼의 연산이 필요하다.

 이제 우리는 이 연산 수를 최소화하는 `k`를 찾으면 된다. 이를 위해서
 양변을 `k`로 미분해보자. 그러면

```python
number_of_moves/dk = (k * count_before_k)/dk - sum_before_k/dk + sum_after_k/dk - (k * count_after_k)/dk

                   = count_before_k - count_after_k
```

 가 되고, 최소가 되려면 `number_of_moves/dk` 미분 값이 0이어야 하므로
 이는 곧 `count_before_k == count_after_k` 조건을 만족하는 `k`에
 대해서 `number_of_moves`가 최소값을 갖는다는 의미이다. 즉 어떤 수
 `k`를 기준으로 `k`보다 작은 원소의 개수와 `k`보다 큰 원소의 개수가
 같도록 하는 `k`를 고르면 된다. 그리고 이 성질을 만족하는 `k`는 바로
 중위값이다.
