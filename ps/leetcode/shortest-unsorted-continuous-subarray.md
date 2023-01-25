---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Shortest Unsorted Continous Subarray
---

# [Shortest Unsorted Continous Subarray](https://leetcode.com/problems/shortest-unsorted-continous-subarray/)

 정수 배열이 주어진다. 이 정수 배열의 **연속되는 부분 배열**을 어떻게
 잘 정렬하면, 배열 전체가 오름차순으로 정렬된다고 한다. 즉, 정렬이 안
 된 연속되는 부분 배열이 존재한다.

 이 부분 배열 중 가장 짧은 것의 길이를 구하자.

 배열 크기는 1~10,000 이고 값은 $$ -10^5 \sim 10^5 $$ 사이이다.

 예를 들어, `[2,6,4,8,10,9,15]` 배열을 생각하자. 이 중 `[6,4,8,10,9]`
 부분을 잘 정렬해야만 배열 전체가 오름차순으로 정렬된다. 그리고 이게
 찾을 수 있는 부분 배열 중 가장 짧다. 따라서 정답은 5가 된다.

 반면 `[1,2,3,4]` 배열은 전체가 이미 정렬되어 있기 때문에 답은 0이다.

## 단순 무식한 방법

 내가 문제를 이해하기로는, 적당히 정렬된 배열이 있는데 그 안에서 정렬
 안된 연속되는 부분 중에서 제일 짧은 걸 찾는 걸로 이해했다.

 가장 단순하게 떠올릴 수 있는 방법은 직접 정렬한 배열과 일대일로
 비교해보는 것이다. 정렬 안된 부분 배열의 길이만 구하면 되므로,
 여기서는 정렬 안된 부분을 찾는 두 개의 인덱스 `low`와 `high`를
 유지하면서 다른 부분을 찾는다. 이때, `low`는 정렬 안된 부분의 인덱스
 중 최소값을, `high`는 최대값을 계속 누적해 나아가면 될
 것이다. 자연스럽게 `low`의 초기값은 마지막 인덱스가 되고 `high`의
 초기값은 0이 된다.

```python
def findUnsortedSubarray(nums):
    nums_sorted = sorted(nums)
    low, high = len(nums)-1, 0
    for i in range(len(nums)):
        if nums[i] != nums_sorted[i]:
            low = min(low, i)
            high = max(high, i)
    return high - low + 1 if high > low else 0
```

## 스택을 이용하기

 정렬을 하는 순간 `O(nlogn)`의 덫에 걸린다. 그나마 입력이 (아마도)
 거의 정렬된 배열이고, 파이썬의 팀소트는 이런 데이터에 아주 잘
 작동하기 때문에, 나름 괜찮은 속도가 나온다.

 이론적으로 더 빠른, `O(n)`의 방법을 찾아보자. 답은 스택을 활용하는
 것이다.

 배열을 정방향으로 훑으면서, 증가하는 순서대로 스택에 넣는다. 그러다가
 만약 스택의 꼭대기보다 작은 값이 처음으로 나온다면, 여기서부터 탐색을
 거꾸로 해나갈 수 있다. 예시 `[2,6,4,8,10,9,15]`를 다시
 살펴보자. 스택에 `[2,6]`을 넣고 그 다음 처음으로 작아지는 `4`를
 만났다. 그럼 여기부터 시작해서 스택의 꼭대기 값이 `4`보다 작은 동안
 계속 스택을 팝 하면서 부분 배열의 시작 지점을 구할 수 있다. 반대로,
 배열을 역방향으로 훑으면서 감소하는 순서로 스택에 넣다가 스택의
 꼭대기보다 큰 값을 만난다면, 비슷한 탐색을 통해 부분 배열의 끝 지점을
 구할 수 있다.

```python
def findUnsortedSubarray(nums):
    stack = []
    low, high = len(nums)-1, 0
    for i in range(len(nums)):
        while stack and nums[i] < nums[stack[-1]]:
            low = min(low, stack.pop())
        stack.append(i)

    stack.clear()
    i = len(nums)-1
    while i >= 0:
        while stack and nums[stack[-1]] < nums[i]:
            high = max(high, stack.pop())
        stack.append(i)
        i -= 1
    return high - low + 1 if high > low else 0
```

 - 스택에 직접 값을 넣는게 아니라 인덱스를 넣음으로써 부분 배열의
   정확한 위치를 구할 수 있다.
 - `O(n)`의 시간 복잡도와 공간 복잡도를 얻었다.

## 스택 없이

 스택을 썼다는 것은 뭔가 순서가 거꾸로인 로직이 있다는 뜻이다. 그런데,
 잘 생각해보면 위의 로직은 스택 없이도 구현할 수 있어 보인다. 그러면
 `O(1)`의 공간 복잡도를 추가로 얻을 수 있을 것 같다.

 먼저 부분 배열의 끝 부분에 집중해보자. 배열을 정방향으로 훑으면서,
 이때까지 만난 최대값을 기록해둔다. 그러면, 이때까지 만난 최대값보다
 **작은** 값이 있는 위치를 부분 배열의 끝으로 업데이트 한다. 이걸
 정방향으로 한번 하고 나면, 부분 배열의 끝을 찾을 수 있을 것
 같다. 예시 `[2,6,4,8,10,9,15]`를 다시 보자. `2,6`으로 훑어서 최대값이
 `6`인 상황에서 최대값보다 작은 `4`를 만나면, 이 값을 우선 끝 부분의
 후보로 업데이트 한다. 그 후 `2,6,4,8,10`으로 훑으면서 최대값은 계속
 업데이트되어 `10`이 된다. `9`를 만났을 때, 최대값인 `10`보다 작은
 위치이므로, 또 끝 부분을 업데이트한다. 이렇게 배열 끝까지를 훑으면,
 **처음으로 값이 꺾이는 부분 중에서 제일 마지막 부분**의 위치를 알 수
 있고, 이것이 바로 우리가 원하는 부분 배열의 끝나는 지점이다. 그리고
 시작 지점은 이것과 정반대의 로직을 이용해, 역방향으로 훑으면 알 수
 있다.

```python
def findUnsortedSubarray(nums):
    high, maxval = 0, float('-inf')
    for i in range(len(nums)):
        maxval = max(maxval, nums[i])
        if nums[i] < maxval:
            high = i

    low, minval = 0, float('inf')
    i = len(nums)-1
    while i >= 0:
        minval = min(minval, nums[i])
        if minval < nums[i]:
            low = i
        i -= 1
    return high - low + 1 if high > low else 0
```
