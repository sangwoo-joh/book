---
layout: page
tags: [problem-solving, leetcode, python, hash-table]
title: Remove Duplicates from Sorted Array
---

# [Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
 정렬된 배열이 들어오면, 여기서 중복되는 원소를 **제자리에서**
 수정하여 모든 값이 단 한번만 나오게 수정하고, 수정된 배열의 길이를
 리턴하는 문제이다.

 즉, 공간 복잡도는 `O(1)`을 반드시 지켜야한다. 그리고 결과로 *길이*를
 리턴하는 이유는, 제자리 수정된 배열의 0부터 *수정된 길이*까지만
 체크하여 채점을 하기 때문이다.

## `O(n^2)`
 먼저 가장 단순하게는 *왼쪽으로 땡기는* 것을 생각해볼 수 있다. 두 개의
 포인터를 이용해서 중복을 체크하다가 같은 값이 나올 때마다 왼쪽으로 한
 칸씩 전체 배열을 땡기는 것이다. 이렇게하면 전체를 훑기 위해서 `n`,
 그리고 중복이 발생될 때마다 또 전체를 훑기 위해서 `n` 총 `O(n^2)`의
 복잡도가 소요된다. 따라서 작은 입력에 대해서는 잘 동작하지만,
 실제로는 타임아웃이 난다.

 코드는 다음과 같다.

```python
def remove_duplicate(nums) -> int:
    length = len(nums)
    starti = 0

    while starti < length:
        endi = starti + 1
        while endi < length:
            if nums[starti] == nums[endi]:
                # shift left
                shifti = endi + 1
                while shifti < length:
                    nums[shifti - 1] = nums[shifti]
                    shifti += 1
                # decrease length
                length -= 1
                # after shifting, there might be a number at nums[endi] same as nums[starti],
                # so just leave endi as it is.
            else:
                # search to next
                endi += 1

        starti += 1
    return length
```

 - 왼쪽으로 땡길 때마다 (shift left) 길이가 줄어들어야 하므로
   `length`를 계속 업데이트 한다.
 - `starti`와 `endi`의 값이 같아서 왼쪽으로 땡기고 나면, 원래 `endi`
   자리에 `endi+1`에 있던 값이 오게 되는데, 이 값 또한 `starti`와 같을
   수 있으므로 이때는 `endi`를 증가시키지 않는다는 것에 주의하자.


## `O(n)`
 타임아웃이 나지 않기 위해서는 전체 배열을 한번만 훑는 방법이 필요하다.

 중복을 찾았을 때 왼쪽으로 땡기는 작업은 무조건 `O(n)`이 소요되기
 때문에 너무 비싸다. 이 작업을 `O(1)`로 줄여야 배열을 한번만 훑을 수
 있게 된다. 그러면 생각을 뒤집어서, 중복을 찾았을 때 *아무것도*
 안하려면 어떻게 해야할까? 즉, 중복이 *아닌* 값을 찾았을 때 뭔가를
 해보면 좋을 것 같다. 다음 상황을 생각해보자.

```
[1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 4]
```

 두 개의 포인터 `starti`와 `endi`를 이용해서 중복을
 검사해보자. 처음에는 `starti = 0`, `endi= 1` 에서 시작한다. 앞서
 말했듯 한번만 훑기 위해서 두 인덱스에 있는 값이 같은 경우 그냥
 스킵하자. 그러면 처음으로 달라지는 값이 나오는 부분은 `endi = 5`일 때
 `1 != 2`를 만나게 된다.

```
[1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 4]
 |              |
starti          |
              endi
```

 이 상황에서 우리가 원하는 *중복없는 배열*을 앞에서 부터 만들어가려면
 어떻게 하면 될까? 잘 생각해보면 `starti`는 우리가 원하는 중복없는
 값이 딱 하나 있는 위치이고, `starti + 1`의 위치는 그 다음 중복없는
 값이 와야 하는 위치이다. 따라서, `starti + 1` 위치에, 처음으로
 달라진 `endi` 위치의 값을 넣으면 다음과 같은 상황이 된다.

```
[1, 2, 1, 1, 1, 2, 2, 2, 2, 3, 4]
    |           |
 starti+1       |
              endi
```

 이제 배열의 앞은 우리가 원하는 배열의 일부분이 되었다. 즉, 각 값이
 정확하게 한번만 나오는 배열의 일부인 `[1, 2]`가 완성되었다. 그
 다음은? 일단 `starti` 위치의 값과 중복되는 값은 다 스킵했으니
 `starti`는 다음 값으로 넘어가기만 하면 된다. 그리고 `endi`는 다시
 중복값을 찾아 떠나면 된다.

 이렇게 `endi`를 배열의 끝까지 한번만 훑고나면 다음 모양이 된다.

```
[1, 2, 3, 4, 1, 2, 2, 2, 2, 3, 4]
          |                        |
        starti                     |
                              endi (out-of-index)
```

 따라서, 최종 배열의 길이는 `starti + 1` 과 같다!

 이를 코드로 짜면 다음과 같다.

```python
def remove_duplicate(nums) -> int:
    if not nums: return 0

    starti, endi = 0, 1
    while endi < len(nums):
        if nums[starti] != nums[endi]:
            starti += 1
            nums[starti] = nums[endi]  # or, swapping is ok too
            # [1, 1, 1, 2] (starti=0, endi=3) -> starti=1 -> [1, 2, 1, 2]
        endi += 1
    return starti + 1
```

 - `starti=0`, `endi=1`을 초기값으로 하기 때문에 베이스 케이스인 "빈
   배열"의 경우를 미리 처리해주는 것에 주의하자.
