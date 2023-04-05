---
layout: page
tags: [problem-solving, leetcode, python, array]
title: 3Sum
<!-- : Problem Solving -->
<!-- parent: LeetCode -->
last_update: 2023-04-05 09:45:50
---

# [3Sum](https://leetcode.com/problems/3sum/)

 정수 배열이 주어졌을 때, `nums[i] + nums[j] + nums[k] == 0`이 되는
 모든 정수 세 쌍의 집합을 구하자. 이때, `i != j && i != k && j != k`를
 만족해야 한다.

 정답 배열은 중복되는 수를 담으면 안된다.

 배열의 길이는 0~3,000 사이이고 배열의 값은 -100,000~100,000 사이이다.

## 투 포인터

 두 수의 합은 해시 셋으로 금방 풀렸다. 세 수의 합은 어떻게 할 수
 있을까? Brute Force를 생각해보면 O(N^3)의 솔루션을 떠올릴 수
 있겠지만, 배열 최대 크기가 3000이라서 시간 초과가 날 것이다. N^3보다
 작은 솔루션은 없을까?

 [Two Sum II](../two-sum/#two-sum-ii---input-array-is-sorted)의 접근을
 활용해야 한다: 배열이 정렬되어 있을 때, 투 포인터를 이용해 합이
 원하는 값보다 작으면 더 작은 값의 포인터를 더 큰 값을 갖도록
 이동하였고, 합이 더 크다면 더 큰 값의 포인터를 더 작은 값을 갖도록
 이동하였다. 세 수의 합을 구하려면, 정수 하나는 배열 전체를 루프하도록
 하면서, 다른 두 정수는 투 포인터를 이용해서 O(N)만에 구하도록 한다면,
 총 복잡도 O(N^2)을 얻을 수 있을 것 같다. 그리고 이때 문제의 조건에
 따라 (1) 세 정수의 **인덱스**는 유니크해야 하고 (2) 세 정수의
 **각각의 값**도 유니크해야 한다.

 입력으로 들어오는 수가 정렬되어 있다는 말이 없기 때문에, 투 포인터를
 사용하려면 정렬을 해야한다. 여기에 O(NlogN)의 복잡도가 소요되긴
 하지만, 실제로 루프를 O(N^2)만큼 돌아야 하므로 이 부분은 괜찮다.

 이 아이디어를 구현해보자.

```python
def threeSum(nums):
    answer = []
    nums = sorted(nums)
    n = len(nums)
    for i in range(n-2):
        left, right = i + 1, n - 1
        while left < right:
            s = nums[i] + nums[left] + nums[right]
            if s == 0:
                answer.append((nums[i], nums[left], nums[right]))
                left += 1
                right -= 1
            elif s > 0:
                right -= 1
            else:
                left += 1
    return set(answer)
```

 - `i < left < right`인 세 인덱스를 잘 고르려고 한다. 따라서, `i`는
   `n-3`까지 가능하므로 `range(n-2)`까지 루프를 돈다. 이렇게 `i`를
   일단 고른다.
 - `left`는 `i` 다음부터, `right`는 항상 마지막 수부터
   검사한다. 그리고 `left`, `right`를 가지고 투 포인터로 범위를
   좁혀가며 합이 0이 될 때 정답에 추가한다.
 - 정답의 정수 튜플은 중복되면 안되기 때문에, 최종적으로 `set()`
   연산으로 중복을 없앤다. 이때 튜플은 항상 `(i, left, right)` 순으로
   넣어야 올바르게 중복을 제거할 수 있다.


 이렇게하면 대략 2초정도 걸리는 솔루션이 나온다. 더 빠르게 할 수 있는
 방법은 없을까?

### Small Optimization - 빨리감기

 위의 솔루션에서 시간을 꽤 잡아먹는 부분은, 중복되는 튜플을 무지성으로
 다 `answer`에 집어넣고 마지막에 이를 해싱해서 중복을 제거하는
 부분이다. 이 부분을 더 똑똑하게 해보자.

 일단 떠올리기 쉬운 부분은 투 포인터를 진행하는 부분이다. 우리가
 원하는 합이 되었을 때 (`s == 0`), 두 포인터를 한 칸씩만 움직이고
 있는데, 배열이 정렬되어 있기 때문에, 이 조건을 만족하는 동안 `left`와
 `right`의 값이 같으면 전부 스킵해도 된다. 따라서 다음과 같이 바꿀 수
 있다.

```python
def threeSum(nums):
    answer = []
    nums = sorted(nums)
    n = len(nums)
    for i in range(n-2):
        left, right = i + 1, n - 1
        while left < right:
            s = nums[i] + nums[left] + nums[right]
            if s == 0:
                answer.append((nums[i], nums[left], nums[right]))
                while left < right and nums[left] == nums[left+1]:
                    left += 1
                while left < right and nums[right-1] == nums[right]:
                    right -= 1
                left += 1
                right -= 1
            elif s > 0:
                right -= 1
            else:
                left += 1
    return set(answer)
```

 `left`는 왼쪽에서 오른쪽 방향으로 진행하기 때문에 `left`와 `left +
 1`의 값이 같으면 싹 땡긴다. `right`는 반대로 오른쪽에서 왼쪽으로
 진행하기 때문에 `right - 1`과 `right`의 값이 같으면 싹 땡긴다. 이렇게
 두 개의 반복문으로 빨리감기를 진행하고 나면, 그 위치는 합 조건을
 만족하는 같은 값을 가진 `left`, `right` 의 마지막 부분에 위치하게
 되고, 최종적으로 그 다음 탐색을 위해서 한 칸씩 더 이동해주면 된다.

 이렇게하고 마지막의 `set()` 연산을 풀면 답을 얻을 수 있지 않을까?
 놀랍게도 다음 반례를 발견하게 된다.

```python
Input: [-1,0,1,2,-1,-4]
Expected: [[-1,-1,2], [-1,0,1]]
Output: [[-1,-1,2], [-1,0,1], [-1,0,1]]
```

 중복을 다 제거한줄 알았는데 중복이 나왔다. 어디서 놓친 것일까? 위의
 입력을 하나씩 따라가보자. 먼저 입력을 정렬하면 `[-4,-1,-1,0,1,2]`를
 얻는다. `i = 1`일 때의 상황을 살펴보자. `(left, right) = (2, 5)`에서
 `(-1, -1, 2)`의 해답 하나를 얻는다. 그 다음 `left`는 같은 `-1`을 가진
 `3`을 거쳐 `4`가 되고, `right`는 `4`가 되어 `(-1, 0, 1)`의 해답을
 얻는다. 여기까진 좋다. 그런데 그 다음 `i = 2`가 되었을 때, `(left,
 right) = (3, 4)`에서 똑같은 해답인 `(-1, 0, 1)`을 얻게 된다!

 앞서 우리는 두 개의 포인터, `left`와 `right`에서만 중복을 스킵했지,
 `i`에 대해서는 중복을 스킵하지 않은 것이 문제다. 그럼 무엇을
 해야할까? `i`는 `left`와 마찬가지로 왼쪽에서 오른쪽으로 진행하기
 때문에, `nums[i] == nums[i+1]`일 때 다 스킵하면 되지 않을까? 위의
 예시를 생각해보자. `i = 1`일 때, `i+1`과 같기 때문에 이를 스킵하고 `i
 = 2`로 곧장 넘어가버린다. 그런데 우리는 위에서 `i = 1` 일 때 정답
 튜플 `(-1, -1, 2)`를 구한 것을 보았다. 따라서 정답을 하나 놓친
 것이다. 그러므로, `i`를 스킵할 때에는 일단 `i`에 대해서 먼저 투
 포인터로 가능한 공간을 전부 탐색해본 뒤에, 그 다음 또 같은 값을
 만났을 때 이를 스킵해야 하는 것이다. 따라서, `nums[i-1] == nums[i]`일
 때 스킵해야 한다.

 이 최적화를 다 적용한 코드는 다음과 같다.

```python
def threeSum(nums):
    answer = []
    nums = sorted(nums)
    n = len(nums)
    for i in range(n-2):
        if i > 0 and nums[i-1] == nums[i]:
            continue
        left, right = i + 1, n - 1
        while left < right:
            s = nums[i] + nums[left] + nums[right]
            if s == 0:
                answer.append((nums[i], nums[left], nums[right]))
                while left < right and nums[left] == nums[left+1]:
                    left += 1
                while left < right and nums[right-1] == nums[right]:
                    right -= 1
                left += 1
                right -= 1
            elif s > 0:
                right -= 1
            else:
                left += 1
    return answer
```

 투 포인터에서의 빨리감기와 `i`의 빨리감기를 모두 적용하였기 때문에,
 마지막의 해싱 연산은 더 이상 필요하지 않다. 이렇게 1초 미만의
 솔루션을 얻을 수 있다.
