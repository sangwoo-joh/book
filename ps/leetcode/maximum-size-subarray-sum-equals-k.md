---
layout: page
tags: [problem-solving, leetcode, python, array, two-pointers]
title: Maximum Size Subarray Sum Equals k
---

# [Maximum Size Subarray Sum Equals k](https://leetcode.com/problems/maximum-size-subarray-sum-equals-k/)

  정수 배열 `nums`와 정수 값 `k`가 주어졌을 때, 합이 `k`가 되는 부분
  배열 중 길이가 가장 긴 부분 배열의 길이를 구하자. 만약 그런 게
  없다면 0을 리턴하자.

  입력 배열의 길이는 최대 $$ 2 \times 10^5 $$ 이고 배열 원소의 값은 $$
  -10^4 \sim 10^4$$ 사이이다. `k`는 $$ -10^9 \sim 10^9 $$ 사이이다.

## 원소가 양수였다면...!

 만약 원소가 전부 양수였다면, 간단한 투 포인터로 쉽게 풀 수 있는
 문제이다. 특히 원소가 모두 양수일 때의 접근 방법은 [0으로 만드는 최소
 연산의 횟수](../minimum-operations-to-reduce-x-to-zero)에서도
 쓰인다. 그 방법은 다음과 같다.

```python
def maxSubArrayLenWithPositiveElements(nums, k):
    n = len(nums)
    size = 0
    start, cur = 0, 0
    for end in range(n):
        cur += nums[end]
        while cur > k and start <= end:
            cur -= nums[start]
            start += 1
        if cur == k:
            size = max(size, end-start+1)
    return size
```

 즉, 원소가 모두 양수일 때에는 현재까지 누적한 부분 합 `cur`가 원하는
 값 `k`보다 큰 경우, `start`를 전진시켜서 윈도우 사이즈를 줄이는 것이
 가능하기 때문에 위와 같은 접근을 할 수 있었다. 하지만 이 문제에서는
 원소가 *음수*일 수도 있기 때문에, 위와 같은 조건에서 `start`를
 전진시키면 탐색 공간 중 일부를 놓쳐 올바른 답을 구할 수 없게 된다.

---

 음수가 포함된 경우에는, 부분 합과 해시 테이블을 모두 활용해야
 한다. 부분 합은 말 그대로 현재 인덱스 `i`까지의 부분 합을
 계산해둔다. 만약 이 부분 합이 `k`와 같다면, 최장 길이 후보는 `i +
 1`일 것이다. 해시 테이블에는 **현재 부분 합의 위치**를
 기록해둔다. 그럼 이걸 어디다 써먹냐면, 바로 **부분 합 - `k`가 있는 첫
 위치**를 찾을 때 쓴다. 만약 이전에 부분 합을 누적해오던 중에 부분
 합 - `k`와 같은 값이 있었다면, 이는 곧 지금의 부분 합에서 이 위치의
 값을 빼면 `k`를 얻을 수 있다는 의미이다. 수식으로 쓴다면 지금의 부분
 합을 `cur_sum`이라고 했을 때, `cur_sum - (cur_sum - k) == k`와
 같다. 따라서 이 `cur_sum - k`가 나타났던 **첫 위치**를 알고
 있다면(우리는 최장 길이를 원하기 때문에 첫 위치만을 기록한다), 지금의
 위치 인덱스에서 `cur_sum - k`가 나타났던 위치를 빼면 부분 배열의
 길이를 알 수 있다.

 글로만 설명하니 잘 와닿지 않는다. 예시와 함께 보자.

```python
# 입력
nums = [-2, -1, 2, 1]
k = 1

# i = 2 에서의 부분 합 위치 해시 테이블
partial_sum_loc = {
    -2: 0,
    -3: 1,
    -1: 2,
}
# i = 2 에서의 partial_sum
cur_sum = -1
```

 위와 같은 상황을 생각해보자. `i = 2` 일 때의 스냅샷이다. 이때,
 `cur_sum - 1(k) == -2`인데, 부분 합 위치 해시 테이블을 살펴보니 `-2:
 0`이 있다. 즉, `cur_sum - k`가 이전에 나타난 적이 있고 그 첫 위치는
 인덱스 `0`이라는 뜻이다. 이를 이용하면 우리가 원하는 부분 배열, 즉
 합이 `k`가 되는 부분 배열의 시작 인덱스와 끝 인덱스를 알 수 있는데,
 시작 인덱스는 `cur_sum - k` 즉 `-2`가 나타난 **바로 다음 위치**이고,
 끝 인덱스는 현재 인덱스인 `i = 2`이다. 왜 `cur_sum - k`가 나타난
 인덱스가 아니라 그 다음 인덱스인지는 굉장히 헷갈리는데, 이는 부분
 합의 성질 때문이다. `cur_sum - k`가 나타난 위치에서의 부분 합은 그
 위치에서의 원래 배열 원소의 값까지 더해진 값이 `cur_sum - k`와 같고,
 `cur_sum`은 현재 위치의 원소 값까지 쌓인 값과 같다. 따라서, 우리가
 기록한 해시 테이블과 부분 합에 의해 구해지는 영역은 (`w =
 partial_sum_loc[cur_sum - k]` 라고 할 때) `w`가 아니라 `w + 1`부터
 `i`까지의 영역이다. 그림으로 나타내면 아래와 같다.

```
 i: current index
 w = partial_sum_loc[cur_sum - k]

              +-----------------+
              |/////////////////| <---- cur_sum - (cur_sum - k) == k 가 되는 부분 합 구간
    +-----+---+-------+-----+---+
     .... | w | w + 1 | ... | i | ...
    +-----+---+-------+-----+---+
    ////////////////////////////|
    ----------+-----------------+
    //////////|               ^
    ----------+               |
            ^                 |
            |                 |
            |              cur_sum
            |
            |
      (cur_sum - k)
```


 이 아이디어를 코드로 구현하면 다음과 같다.

```python
def maxSubArrayLenWithPositiveElements(nums, k):
    cur_sum = 0
    max_len = 0
    partial_sum_loc = {}

    for i, num in enumerate(nums):
        cur_sum += num
        candidate = cur_sum - k

        if cur_sum == k:
            max_len = i + 1
        if candidate in partial_sum_loc:
            cand_len = i - partial_sum_loc[candidate]
            max_len = max(max_len, cand_len)

        # update current partial sum location
        if cur_sum not in partial_sum_loc:
            partial_sum_loc[cur_sum] = i
    return max_len
```

 - 최대의 길이를 구하는 것이 목적이므로 그에 맞게 최대 값을 매번
   구한다.
 - `cur_sum`이 `k`와 같을 때에는 굳이 `max` 연산을 할 필요가 없이 현재
   인덱스까지의 배열 길이가 곧 답이다.
 - `cur_sum - k` 부분합이 이전에 나타난 적이 있다면 위에서 설명한
   것처럼 부분합이 나타난 위치를 이용해서 길이를 계산한다.
 - 루프 마지막에 현재 인덱스에서의 `cur_sum`의 위치를 기록할 때,
   **이전에 기록한 적이 없을 때에만** 기록한다. 왜냐하면 우리는 `i`가
   증가하는 방향으로 배열을 훑고 있고, 최장 길이를 구하고 싶기
   때문이다. 이전에 나타난 적 있는데 또 업데이트 하면 길이가 줄어든다.
