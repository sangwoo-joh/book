---
layout: page
tags: [problem-solving, leetcode, python, array, binary-search]
title: Find Minimum in Rotated Sorted Array
---

# [Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/)

 길이 `n`인 리스트가 정렬되어 있다. 이 정렬을 한 번 *회전*하면 제일 큰
 원소가 제일 앞으로 온다. 예를 들어 `[0, 1, 2, 4, 5, 6, 7]`이 있을 때,
  - 1번 회전: `[7, 0, 1, 2, 4, 5, 6]`
  - 2번 회전: `[6, 7, 0, 1, 2, 4, 5]`
  - 4번 회전: `[4, 5, 6, 7, 0, 1, 2]`
  - 7번 회전: `[0, 1, 2, 4, 5, 6, 7]`

 이 된다.

 정렬된 `k`번 회전한 리스트 `nums`가 입력으로 들어왔을 때, 그 중 *가장
 작은 원소*를 구하자. 알고리즘은 반드시 $$ O(log n) $$ 복잡도여야
 한다.

## 이분 탐색으로 Pivot 구하기

 내 블로그 글 중 [이분
 탐색](../../theory/binary-search/#binary-search-in-rotated-sorted-array)글을
 참조하면 좋다.

 요는 피벗, 즉 회전한 부분의 위치를 찾는 것이다. 시간 복잡도가
 명시적으로 주어져 있기 때문에 이분 탐색을 써야하는 것은
 자명하다. 그러면 피벗의 위치를 어떻게 알 수 있을까? 다음 그림을
 생각해보자.

```python
arr[low], arr[low+1], ..., arr[mid], ..., arr[high-1], arr[high]
```

 이분 탐색처럼 `low`, `high`, `mid`를 잡았다고 해보자. 목표는 `low`와
 `high`를 적절히 줄여가면서 피벗의 위치를 `low`에 찾는 것이다. 그러면
 다음 두 가지 경우가 나온다:

### 1) `arr[high] < arr[mid]`: 중앙의 원소가 이분 범위 끝보다 큰 경우

 이 때는 `mid`와 `high` 사이 어딘가에서 회전이 된 것이다. 즉, 회전하기
 전 원래 모습은 다음과 같을 것이다.

```python
 pivot, ... arr[high], ... arr[low], ... arr[mid], ...

 --> rotated --> arr[low], ... arr[mid], ...pivot... arr[high]
```

 따라서, 피벗의 위치는 `mid`와 `high` 사이 어딘가에 존재할
 것이다. 그러므로 이 경우에는 `low`를 `mid + 1`로 업데이트 해준다.

### 2) `arr[mid] <= arr[high]`: 중앙의 원소가 이분 범위 끝보다 작거나 같은 경우

 이 때는 `mid`와 `high` 사이는 잘 정렬이 되어 있으므로, `low`와 `mid`
 사이 어딘가에서 회전이 된 것이다. 앞의 예시처럼 길이만큼 회전한 경우,
 즉 그냥 정렬된 경우도 회전된 경우라고 본다면 여기 포함된다. 이 때는
 그냥 일반적인 이분 탐색을 하듯이 `high`를 `mid`로 업데이트 해준다.

---

 이 아이디어를 구현하면 다음과 같다.


```python
def findMin(nums):
    low, high = 0, len(nums)-1
    while low < high:
        mid = low + (high - low) // 2
        if nums[mid] > nums[high]:
            # rotated in somewhere mid..high
            low = mid + 1
        else:
            # rotated in somewhere low..mid
            high = mid

    pivot = low
    return nums[pivot]
```

 - `low`, `high` 모두 **인덱스**임에 주의하자. 따라서 첫 번째
   케이스에서 `low`를 업데이트할 때 `mid + 1`이 옳다.
 - `mid`를 계산할 때 `(low + high) // 2`가 아니라 `low + (high - low)
   // 2`를 한 이유는 오버플로우를 막기 위함이다. 파이썬에서는
   괜찮겠지만 빅인트로 넘어가는 순간 성능이 문제될 수 있기 때문에 그냥
   늘 저렇게 하는게 속편한다.
