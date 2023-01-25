---
layout: page
tags: [problem-solving, theory, python, binary-search]
title: Binary Search
---

{: .no_toc }
## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

# Binary Search


## Binary Search in Rotated Sorted Array

 정렬된 리스트(배열)에서 `k` (`0 <= k < len(arr)`) 번째 인덱스를
 기준으로 회전을 시킨 경우, 어디서 회전되었는지를 찾고 (피벗) 이 값을
 이용해서 이분탐색을 하면 `O(log N)` 만에 찾을 수 있다.

 참고로, 피벗을 찾은 다음 `sorted_arr = arr[pivot:] + arr[:pivot]`
 이렇게 정렬된 리스트를 복구해서 검색해도 말은 되지만, 복사 연산자
 때문에 `O(N)`을 한번 겪게 되어서 사이즈가 커지면 느려진다. 작으면
 별로 문제 안됨.

``` python
def search_from_rotated(nums, tofind):
    # 1. find pivot index (the smallest value)
    low = 0
    high = len(nums) - 1  # this is tricky - high is an index here

    while low < high:
        mid = low + (high - low) // 2  # same as (low + high) // 2, but avoid overflow
        if nums[mid] > nums[high]:
            # rotated in somewhere mid..high
            low = mid + 1
        else:
            # rotated in somewhere low..mid
            high = mid

    pivot = low  # the index of the smallest value

    # 2. now, binary search with this info
    low = 0
    high = len(nums)  # here, the range is half open: [low, high)

    # find correct range
    if nums[pivot] <= tofind <= nums[high-1]:
        # tofind is somewhere pivot..high
        low = pivot
    else:
        # tofind is somewhere low..pivot
        high = pivot

    while low < high:
        mid = low + (high - low) // 2
        if nums[mid] == tofind:
            return mid
        if tofind > nums[mid]:
            low = mid + 1
        else:
            high = mid

    return -1
```

 - 처음에 피벗 인덱스를 찾을 때는 `high` 역시 인덱스로
   쓰였다. `high`를 half-open 으로 둬볼려고 했는데, `1`씩 빼거나
   더해줘야 되서 코드가 더 복잡해져서 그냥 저렇게 하는게 깔끔하다.
 - 피벗을 찾은 이후에는 위 코드처럼 직접 이분 탐색을 구현해도 되고
   (여기서는 half-open 으로 구현), 아니면 아래와 같이 `bisect`를
   활용해도 된다.

 ``` python
    ... # search pivot
    # find Lower Bound to find equal value
    bi = bisect.bisect_left(nums, tofind, low, high)
    if bi < len(nums) and nums[bi] == tofind:
        return bi
    else:
        return -1

 ```

  - `bisect` 를 활용할 때에는 Lower Bound를 찾는게 편한데, 왜냐하면
    위에서 설명했듯이, 찾고자 하는 값 보다 "크거나 같은 값"이 처음
    나오는 위치를 찾아주기 때문이다. 그래서 `bisect_left` 리턴 값을
    곧바로 인덱스로 쓸 수 있다. 만약 Upper Bound로 찾았다면, 이는 "큰
    값"이 처음으로 나오는 위치 이므로, `bisect_right` (또는 그냥
    `bisect`) 리턴 값에서 1을 빼줘야 정확한 인덱스가 된다.
  - 추가로, `bisect`는 "값을 적절하게 삽입할 위치"를 찾아주기 때문에,
    실제로 리턴한 인덱스에 정말 찾고자 하는 값이 있는지 한번 더
    확인해야 한다.
