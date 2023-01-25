---
layout: page
tags: [problem-solving, leetcode, python, sorting, hash-table]
title: Longest Consecutive Sequence.
last_update: 2023-01-25 18:33:14
---

# [Longest Consecutive Sequence](https://leetcode.com/problems/longest-consecutive-sequence/)
 정렬되지 않은 정수 배열 `nums` 에 대해서, 연속되는 원소 시퀀스의 가장
 긴 길이를 구해라.

 알고리즘의 시간 복잡도는 반드시 `O(N)`이어야 한다.

 배열의 길이는 0 ~ 100,000 이고 각 원소의 범위는 $$ -10^9 \sim
 10^9$$이다.

```
[100, 4, 200, 1, 3, 2] -> 4
[0, 3, 7, 2, 5, 8, 4, 6, 0, 1] -> 9
```

## 정렬
 일단 문제에서부터 '정렬 안된', '연속된' 키워드가 있기 때문에, 가장
 쉬운 접근은 정렬이다. 이때 "연속되는 원소 시퀀스"는 중복이 없는
 시퀀스이지만, 실제 배열에는 중복이 있을 수도 있음을 주의하자.

```python
def lognest_consecutive(nums):
    if not nums:
        return 0

    nums.sort()
    answer, cur = 1, 1

    for i in range(1, len(nums)):
        if nums[i-1] == nums[i]:
            continue

        if nums[i-1] + 1 == nums[i]:
            cur += 1
        else:
            answer = max(answer, cur)
            cur = 1

    return max(answer, cur)
```
 - 연속되는걸 알려면 원소가 적어도 하나는 있어야 되므로, 길이가 `0`인
   경우를 미리 잘라준다.
 - `nums[i-1] == nums[i]` 인 경우는 스킵한다.
 - 연속되는 경우는 `cur` 늘려서 현재 길이를 계산해주고, 연속이 끊기게
   되는 순간 max를 구해서 업데이트하고 동시에 현재 길이를 `1`로
   리셋한다.
 - 루프가 끝나고 마지막 리턴하기 전에 max를 한번 더 구해줘야
   한다. 마지막 계산한 `cur`가 아직 업데이트 되지 않았을 수 있기
   때문이다.

 이렇게 하면 정렬해야 하니까 `O(n*logn)`의 복잡도를 갖는다.

## 해시셋
 더 빠르게는 못할까? 좀 생각해보면 "연속된"의 정의를 활용하면,
 해시셋을 가지고 뭔가 해볼 수 있을 것 같다. 일단 정렬하지 말고 숫자를
 전부 해시셋에 넣는다. 그러면 중복도 사라지고 어떤 값이 있는지
 없는지를 `O(1)`만에 판단할 수 있다.

 이 해시셋의 원소를 돌면서, 만약 어떤 원소보다 `1` 작은 원소가
 **없다면**, 해당 원소가 어떤 연속되는 시퀀스의 **시작점**이라는
 사실을 알 수 있다. 그러면, 그 원소로부터 출발해서 `1`씩 늘려가면서
 연속되는 시퀀스가 가능한지 해시셋에 쿼리를 날리면서 최대를 누적하면
 된다.

 아이디어는 간단하다. 다음과 같이 구현할 수 있다.

```python
def longest_consecutive(nums):
    numset = set(nums)
    answer = 0

    for n in numset:
        if (n-1) in numset:
            continue
        start, end = n, n
        while end in numset:
            end += 1
        answer = max(answer, end - start)
    return answer
```
 - 말한대로 `(n-1)`이 해시셋에 없으면 `n`부터 시작하는 시퀀스가 존재할
   수도 있다. `n`은 그 자체로 이미 길이 1의 시퀀스이므로 이를 잘
   고려해서 해시셋 전체를 다시 확인하면 된다.
 - 시작점, 즉 `(n-1)`이 셋에 없는 `n`을 찾을 때, `n`을 원래 배열
   `nums`에서 꺼내오면 중복이 있을 수 있어서 느릴수 있다. 따라서
   여기서는 `numset`에서 꺼내오도록 한다.

 이러면 최대 2번 해시셋 전체를 순회하게 되므로 복잡도는 `O(n)`으로 확
 떨어진다.
