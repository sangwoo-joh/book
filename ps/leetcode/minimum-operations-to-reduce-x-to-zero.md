---
layout: page
tags: [problem-solving, leetcode, python, array, two-pointers]
title: Minimum Operations to Reduce X to Zero
---

# [Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero/)

 정수 배열 `nums`와 정수 값 `x`가 주어진다. 한 번의 연산에서, 가장
 왼쪽 또는 가장 오른쪽의 원소를 `nums`에서 뽑은 다음 이 값을 `x`에서
 뺄 수 있다. 이 연산은 `nums` 배열 자체를 수정한다는 것을 기억하자.

 `x`를 정확하게 `0`으로 만들기 위한 **최소 연산 횟수**를 구하자. 어떤
 경우에도 불가능하다면 `-1`을 리턴하자.

 정수 배열의 크기는 $$ 1 \leq | nums | \leq 10^5 $$ 이고 원소의 값의
 범위는 $$ 1 \leq nums[i] \leq 10^4 $$, $$ 1 \leq x \leq 10^9$$이다.


## 백트래킹 - 타임아웃

 가장 직관적으로 생각해낼 수 있는 방법은, 문제에 나온 설명대로 직접
 해보는 것이다.

 가장 왼쪽과 가장 오른쪽에서 하나씩 꺼내어서 합을 확인하는 것까지는
 쉽게 구현할 수 있다. 이러면 각 단계에서 진행할 수 있는 가짓수가 2
 가지, 즉 가장 왼쪽을 빼거나 가장 오른쪽을 빼는 두 가지 이므로,
 복잡도는 $$ 2 ^ N $$ 이 되어 터질 게 분명하다. 다만, 문제의 조건에
 따라 모든 원소가 양수인 덕분에, 이 성질을 이용해서 조금 가지치기를 할
 수 있다. 모든 원소가 양수이기 때문에, 재귀를 하기 전에 이미 지금까지
 연산한 결과가 음수라면 더 이상 그 공간의 서브 트리를 살펴볼 필요가
 없는 것이다.

 이 아이디어를 구현하면 다음과 같다.

```python
def minOperations(nums, x):
    answer = float('inf')

    def find(arr, cur_x, turn):
        nonlocal answer
        if not arr:
            return

        # pick leftmost
        cand_left = cur_x - arr[0]
        if cand_left == 0:
            answer = min(answer, turn + 1)
            return

        # pick rightmost
        cand_right = cur_x - arr[-1]
        if cand_right == 0:
            answer = min(answer, turn + 1)
            return

        # pruning
        if cand_left > 0:
            find(arr[1:], cand_left, turn + 1)
        if cand_right > 0:
            find(arr[:len(arr)-1], cand_right, turn + 1)

    find(nums, x, 0)
    return -1 if answer == float('inf') else answer
```

 단, 이렇게 해도 타임아웃이 난다. 뭔가 다른 접근이 필요하다.

## 투 포인터

 이 문제의 최적 알고리즘은 이 문제를 이 문제의 Dual인 [합이 k가 되는
 최장 부분 배열](../maximum-size-subarray-sum-equals-k) 문제로
 치환해서 푸는 것이다. 즉, 양쪽 끝에서 하나씩 원소를 `x`에서 빼서
 `0`을 만드는 게 아니라, 합이 `total - x`가 되는 부분 배열을 찾으면
 된다. 그리고, 원소를 빼는 연산 횟수를 최소로 하라고 했으니, 이 말은
 합이 `total - x`가 되는 **가장 긴** 부분 배열을 찾으면 된다. 완벽한
 Dual이다.

 따라서 이 아이디어를 그냥 구현하면 된다.

```python
def minOperations(nums, x):
    total = sum(nums)
    tofind = total - x
    n = len(nums)
    maxwin = -1
    start, cursum = 0, 0
    for end in range(n):
        cursum += nums[end]
        while cursum > tofind and start <= end:
            cursum -= nums[start]
            start += 1
        if cursum == tofind:
            maxwin = max(maxwin, end - start + 1)
    return (n - maxwin) if maxwin != -1 else -1
```

 - 전체 합 `total`을 계산하고 우리가 원하는 합인 `tofind = total -
   x`를 계산해둬서 부분 배열의 합을 체크한다.
 - `start`를 줄일 수 있는 (shrink) 조건은, 여전히 `start, end`가
   유효한 윈도우이면서, 지금 합이 여전히 `tofind`보다 큰
   경우이다. 모든 원소가 양수이기 때문에, 지금 합이 `tofind`보다 큰
   동안 `start`에 있는 원소의 값을 지금 합에서 덜어내면서 `start`
   포인터를 이동하면 된다.
 - 답을 찾은 경우, 즉 지금 합이 `tofind`인 경우, 우리는 이때의 **최대
   윈도우 사이즈**를 기록해둬야 한다. 단, 이렇게 구한 최대 윈도우
   사이즈가 곧바로 답이 되진 않는다. 우리는 원래 문제를 dual로 바꿔서
   풀고 있다는 사실을 잊지 말자. 문제의 답은, **전체 길이에서 최대
   윈도우 사이즈를 뺀 값**이 된다. 이 값이 곧 최소의 연산 횟수와
   동일한 의미를 갖는다.
