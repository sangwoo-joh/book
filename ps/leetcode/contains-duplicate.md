---
layout: page
tags: [problem-solving, leetcode, python, array, hash-table]
title: Contains Duplicate
---

# [Contains Duplicate](https://leetcode.com/problems/contains-duplicate/)

 정수 배열이 주어졌을 때, 최소 두 번 이상 나타나는 원소가 있는지를
 확인하자.

 배열 크기는 1~100,000 이다.

## 해시 셋
 - 중복을 제거해서 전후 Cardinality를 비교하면 된다.

```python
def containsDuplicate(nums):
    return len(nums) != len(set(nums))
```


# [Contains Duplicate II](https://leetcode.com/problems/contains-duplicate-ii/)

 역시 정수 배열이 주어지고 이번에는 정수 `k`도 같이 주어진다. 이때,
 서로 다른 두 인덱스 `i`와 `j`에 대해서 `nums[i] == nums[j]` 이면서
 `abs(i - j) <= k`를 만족하는 두 인덱스가 존재하는지를 확인하자.

 - 정수 배열의 크기는 1 ~ 100,000
 - 정수 원소 값의 범위는 $$ -10^9 \sim 10^9$$
 - `k`의 범위는 0~100,000

## 해시 셋
 - `abs(i - j) <= k`인 서로 다른 두 인덱스 `i`, `j`가 뜻하는 바는 결국
   `k` 크기의 슬라이딩 윈도우를 뜻한다.
 - 중복은 역시 해시 셋으로 판단할 수 있다. `k` 크기의 슬라이딩
   윈도우에 포함되는 원소를 해시 셋으로 유지하면서 정방향으로 훑어
   나간다.
   - 원소가 해시 셋에 있다면 중복이 있다는 것이다.
   - 원소가 없는데 해시 셋의 크기가 `k`를 넘었다면, 이때까지 살펴본
     슬라이딩 윈도우에서는 중복이 없었다는 의미이다. 다음으로 넘어가기
     위해서는 슬라이딩 윈도우를 벗어나는 지점의 원소를 빼야한다.

```python
def containsNearbyDuplicate(nums, k):
    window = set()
    for i in range(len(nums)):
        if nums[i] in window:
            return True

        window.add(nums[i])
        if len(window) > k:
            window.remove(nums[i - k])
    return False
```


# [Contains Duplicate III](https://leetcode.com/problems/contains-duplicate-iii/)

 역시 정수 배열과 `indexDiff` (II의 `k`) 가 주어지고 이번에는 추가로
 `valueDiff`도 주어진다. 이때 다음 조건을 만족하는 서로 다른 인덱스
 쌍이 존재하는지 확인하자.
 - `abs(i - j) <= indexDiff`
 - `abs(nums[i] - nums[j]) <= valueDiff`

 - 배열의 크기는 2~100,000
 - 값의 크기는 $$ -10^9 \sim 10^9$$
 - `indexDiff`는 1과 배열 크기 사이
 - `valueDiff`는 $$0 \sim 10^9$$

## 버킷 테이블
 - II의 슬라이딩 윈도우와 유사한 접근을 생각해볼 수 있는데, 이번에는
   `valueDiff` 조건 즉 값의 범위도 생각해야 한다. 슬라이딩 윈도우 +
   해시 셋 접근을 하면 현재 배열의 값에 0부터 `valueDiff`까지를
   증가시켜 가면서 값을 체크하거나, 혹은 조금 더 똑똑하게 절반씩
   바이너리 서치를 해볼 수도 있다.
 - 간단한 방법은 버킷 정렬의 아이디어를 빌려오는 것이다.
 - 버킷 정렬에서 하나의 버킷은 **특정 범위**의 값을 담는다.
 - 이 아이디어를 바탕으로, 슬라이딩 윈도우에 해당하는 버킷을
   유지하면서 버킷에는 `valueDiff` 범위의 값만 담도록 한다면, 다음 세
   가지 경우가 있다:
   - 같은 버킷 아이디가 존재: `valueDiff` 범위의 값이 존재함
   - 현재 버킷 아이디 + 1이 존재: 해당 버킷의 값을 꺼내와서
     `valueDiff` 만큼 차이나는지 확인
   - 현재 버킷 아이디 - 1이 존재: 역시 버킷의 값을 꺼내와서
     `valueDiff` 만큼 차이나는지 확인
 - 슬라이딩 윈도우 사이즈 축소 조건을 확인하는 방법은 다음 두
   가지이다:
   - 유지하고 있는 윈도우에 해당하는 데이터의 크기가 `k`를 넘었는지:
     `len(window) > k`
   - 인덱스가 `k` 이상인지: `i >= k`
   - 둘 중 어느것을 해도 동작한다. 첫 번째가 동작하는 이유는 중복
     체크를 먼저해서 리턴하기 때문이고, 두 번째는 일반적인 슬라이딩
     윈도우 기법이다.

```python
def containsNearbyAlmostDuplicate(nums, indexDiff, valueDiff):
    def bucket_id(x):
        return x // (valueDiff + 1)

    buckets = {}
    for i in range(len(nums)):
        x = nums[i]
        bid = bucket_id(x)

        if bid in buckets:
            return True
        if (bid + 1) in buckets and abs(x - buckets[bid-1]) <= valueDiff:
            return True
        if (bid - 1) in buckets and abs(x - buckets[bid+1]) <= valueDiff:
            return True

        buckets[bid] = x
        if i >= indexDiff:
            buckets.pop(bucket_id[i - indexDiff])
    return False
```
