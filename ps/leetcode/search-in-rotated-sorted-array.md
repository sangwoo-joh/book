---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Search in Rotated Sorted Array
---

# [Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/)

 유니크한 값만 담긴 정렬된 정수 배열이 주어진다. 그런데 이 배열이 어떤
 피벗 인덱스를 기준으로 *회전*되어 있을수 있다. 예를 들어, `[0, 1, 2,
 4, 5, 6, 7]` 배열이 피벗 인덱스 3에서 회전된다면 `[4, 5, 6, 7, 0, 1,
 2]`가 된다.

 이렇게 회전된 배열이 들어왔을 때, `target` 값의 인덱스를 찾자. 만약
 `target`이 없다면 `-1`을 리턴하자.

 알고리즘의 복잡도는 반드시 $$ O (\log n)$$ 을 만족해야 한다.

 배열의 크기는 1~5,000 사이이고 배열의 값은 모두 유니크함이 보장된다.

## 이분 탐색의 다양한 쓰임새

 이것과 유사한 문제로 [회전 정렬된 배열에서 최소값
 찾기](../find-minimum-in-rotated-sorted-array)가 있다. 이것과 유사한
 방법을 사용하면 될 것 같다.

 일단 위의 방법으로 회전 정렬된 배열의 최소 값의 위치를 찾았다고
 해보자. 그러면 다음과 같은 방법이 가능해보인다.
 - 해당 인덱스가 최소라는 것은 해당 인덱스가 피벗 인덱스라는 뜻이고,
   그러면 이 피벗으로부터 다시 배열을 회전해서 정렬된 원래 배열을
   원복할 수 있다. 단, 이렇게하면 배열을 원복하는데 `O(N)`의 시간 및
   공간 복잡도를 소모하게 되어서 문제의 조건을 위배하긴 한다.
 - 피벗 인덱스를 기준으로 왼쪽과 오른쪽이 각각 오름차순으로 정렬되어
   있다. 따라서, 피벗 왼쪽 범위에다 한번, 오른쪽 범위에다 한번 각각
   이분 탐색을 해서 값을 찾는 방법도 있다.
 - 피벗을 기준으로 회전되어 있기 때문에, 모듈러 연산을 활용하면 중앙
   인덱스를 구할 수 있을 것 같기도 하다.

 그러면 일단 하나씩 해보자. 피벗을 구하는 함수는 다음과 같다.

```python
def find_pivot(nums):
    low, high = 0, len(nums)-1
    while low < high:
        mid = low + (high - low) // 2
        if nums[mid] > nums[high]:
            low = mid + 1
        else:
            high = mid
    return low
```

 - 중앙 원소가 끝 값보다 큰 경우, 중앙과 끝 사이 어딘가에서
   회전되었다고 생각할 수 있다. 즉, `nums[low] ... nums[mid] .. pivot
   .. nums[high]` 이다. 그러므로 범위 시작 값을 `mid+1`로 업데이트
   한다.
 - 그 반대의 경우는 범위 끝 값을 `mid`로 땡긴다.

---

 이렇게 피벗은 구할 수 있고, 이제 이걸로 문제를 풀어보자.

### 회전된 배열 복원하기

 피벗 위치를 알면 원래 배열을 어떻게 복원할 수 있을까? 파이썬에서는
 슬라이스 연산을 지원하기 때문에 아주 수월하게 다음과 같이 할 수 있다.

```python
import bisect
def search(nums, target):
    pivot = find_pivot(nums)
    orig = nums[pivot:] + nums[:pivot]
    bi = bisect.bisect_left(orig, target)
    if bi < len(nums) and nums[bi] == target:
        return (bi + pivot) % len(nums)
    else:
        return -1
```

 - 피벗을 구한 뒤 원래 배열 `orig`를 복원해서 여기서 탐색한다. 단,
   탐색 결과의 인덱스는 **원본 배열 기준**이므로, 이를 다시 회전한
   배열 기준으로 돌려줘야 한다. 따라서, `(bi + pivot) % len(nums)`를
   계산해야 피벗을 기준으로 회전한 인덱스를 돌려줄 수 있다.
 - 정렬된 배열에서 이분 탐색을 할 때에는 직접 바이너리 서치를 구현하기
   보다는 `bisect.bisect_left`를 활용하는 것이 좋다. 이분 탐색을 버그
   없이 제대로 구현하기가 어렵다는 것은 [역사적으로도 증명된
   사실](https://en.wikipedia.org/wiki/Binary_search_algorithm#Implementation_issues)이기
   때문이다. 자세한 내용은 [Upper Bound & Lower
   Bound](../../theory/bisect)에 정리해두었다.

### 이분 탐색 두번하기

 위의 방법은 쉽긴 하지만 배열을 복원하는데 쓰이는 O(N) 때문에 복잡도를
 만족하지 못한다.

 피벗 위치를 기준으로 배열을 둘로 쪼갠다면, 쪼개진 두 배열도 각각
 정렬되어 있기 때문에, 여기다가 바로 이분 탐색을 해보는 것도 좋을 것
 같다.

```python
def search(nums, target):
    pivot = find_pivot(nums)
    left = bisect.bisect_left(nums, target, 0, pivot)
    right = bisect.bisect_left(nums, target, pivot, len(nums))

    if left < pivot and nums[left] == target:
        return left
    elif pivot <= right < len(nums) and nums[right] == target:
        return right
    else:
        return -1
```

 - 역시 여기서도 `bisect.bisect_left`를 활용하는 것이 좋다. 추가적인
   입력으로 이분 탐색을 진행할 범위를 입력할 수 있는데, 이때 범위는
   `[low, high)`의 형태이고 피벗 인덱스는 배열의 최소값이 있는 인덱스
   이므로 위와 같이 호출하면 된다.

### 똑똑하게 이분탐색 한번만 하기

 피벗을 구하고 나면 사실 두 번 이분 탐색할 필요 없이 찾을려는 값이
 있는 위치의 범위를 다음과 같이 하나로 줄일 수 있다.

```python
low, high = 0, len(nums)
if nums[pivot] <= target <= nums[high-1]:
    low = pivot
else:
    high = pivot
```

 즉, 구하려는 값의 위치가 피벗과 배열 마지막 원소 사이에 있다면,
 우리가 원하는 범위는 피벗의 오른쪽이다. 그게 아니라면, 우리가 원하는
 범위는 피벗의 왼쪽이다.

 따라서 이렇게 범위를 좁혀놓고 나면 이분 탐색을 딱 한번만 해줘도
 된다. 이 아이디어를 구현하면 다음과 같다.

```python
def search(nums):
    pivot = find_pivot(nums)
    low, high = 0, len(nums)
    if nums[pivot] <= target <= nums[high-1]:
        low = pivot
    else:
        high = pivot

    bi = bisect.bisect_left(nums, target, low, high)
    if bi < len(nums) and target[bi] == target:
        return bi
    else:
        return -1
```
