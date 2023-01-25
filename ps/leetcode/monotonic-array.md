---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Monotonic Array
---

# [Monotonic Array](https://leetcode.com/problems/monotonic-array/)

 어떤 배열이 단조 증가 또는 단조 감소이면 단조(monotonic)이라고 한다.

 모든 `i <= j`에 대해서 `nums[i] <= nums[j]` 이면 단조 증가, `nums[i]
 >= nums[j]` 이면 단조 감소이다.

 주어진 배열이 단조 배열이면 참, 아니면 거짓을 리턴하자.

## 한 반복에 둘 다 검사하기

 주어진 문제를 코드로 옮기기만 하면 된다. 여기서는 반복문을 한 번만
 써서 둘 다 체크하는 로직을 구현해보려고 한다.

 먼저 배열이 단조 증가인지 단조 감소인지 모르기 때문에, 처음에는 둘
 다라고 가정한다. 그리고 모든 `i <= j(i+1)`에 대해서 단조 증가 또는
 단조 감소 조건을 위반하는 순간 한 쪽의 플래그를 거짓으로
 기록한다. 최종적으로는 단조 증가 또는 단조 감소 둘 중 한 조건만
 만족하는지를 리턴한다.

```python
def isMonotonic(nums):
    monotonic_increasing = True
    monotonic_decreasing = True
    i = 0
    n = len(nums)
    while i < (n-1):
        if nums[i] > nums[i+1]:
            monotonic_increasing = False
        if nums[i] < nums[i+1]:
            monotonic_decreasing = False
        i += 1
    return monotonic_increasing or monotonic_decreasing
```

 여기서 쪼오끔 최적화를 진행할 수는 있다. 이 문제에서는 입력 배열이
 정수 배열이지만, 조금 일반화해서 비교 연산이 값비싼 오브젝트의 배열일
 경우, 비교 연산을 최대한 안하는 것이 좋다. 따라서 두 가지 최적화가
 가능하다.
 - 이미 단조 증가 또는 단조 감소가 아니라고 판단된 경우, 굳이 비교할
   필요가 없다. 파이썬에도 [Short-circuit
   Evaluation](https://en.wikipedia.org/wiki/Short-circuit_evaluation)이
   적용되기 때문에, 각 비교 연산 앞에 추가로 조건을 체크해주면 된다.
 - 단조 증가도 단조 감소도 모두 아니라고 판단되었다면, 이후의 배열
   원소를 훑어볼 필요조차 없다.

 이 최적화를 추가하면 다음과 같다.

```python
def isMonotonic(nums):
    monotonic_increasing = True
    monotonic_decreasing = True
    i = 0
    n = len(nums)
    while i < (n-1):
        if monotonic_increasing and nums[i] > nums[i+1]:
            monotonic_increasing = False
        if monotonic_decreasing and nums[i] < nums[i+1]:
            monotonic_decreasing = False
        if not monotonic_increasing and not monotonic_decreasing:
            break
        i += 1
    return monotonic_increasing or monotonic_decreasing
```

 제법 비결정적인 파이썬인데도 불구하고 이 최적화로 시간이 꽤 줄었다.
