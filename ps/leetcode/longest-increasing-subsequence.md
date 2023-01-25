---
layout: page
tags: [problem-solving, leetcode, python, binary-search]
title: Longest Increasing Subsequence
---

# [Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/)

 정수 배열 `nums`가 주어질 때, 가장 길이가 긴 증가 부분 수열의 길이를
 리턴하자.

 **부분 수열(subsequence)**이란 배열의 원소 순서는 바꾸지 않은 채로
 0개 이상의 원소를 삭제해서 얻을 수 있는 수열이다. 예를 들어,
 `[3,6,2,7]`은 `[0,3,1,6,2,2,7]`의 부분 수열이다.

## 부분 수열 만들면서 구하기

 이 문제는 다이나믹 프로그래밍으로 풀어도 되지만, 최적해를 구하는
 최적(`O(nlogn)`)의 방법이 알려져있다. 최적 방법을 설명하기 위해서
 먼저 최적이 아닌 `O(N^2)` 방법을 설명한다.

 그 방법은 문제 조건을 만족하는 부분 수열, 즉 증가하는 부분 수열을
 직접 만들어가는 방법이다.

 1. 배열의 첫 번째 원소만 담은 부분 수열 `sub`를 초기화한다.
 2. 배열의 두 번째 원소부터 훑으면서:
    1. 만약 원소가 `sub`의 마지막 원소보다 크다면 (증가), `sub`의 끝에
       넣는다.
    2. 그렇지 않으면, `sub`를 돌면서 원소보다 크거나 같은 첫 원소를
       찾아서 지금 원소와 바꾼다.
 3. `sub`의 길이를 구한다.

```python
def lengthOfLIS(nums):
    sub = [nums[0]]

    for n in nums[1:]:
        if n > sub[-1]:
            sub.append(n)
        else: # Find the first element in sub that is greater than or equal to n
            i = 0
            while n > sub[i]:
                i += 1
            sub[i] = n
    return len(sub)
```

 참고로 이 알고리즘은 최장 부분 증가 수열의 **길이**는 제대로 구하지만
 실제 **부분 수열**은 제대로 못구한다. 예를 들어 입력이
 `[3,4,5,1]`이면, 마지막 `sub`는 `[1,4,5]`가 되지만, 길이는 올바른데,
 왜냐면 새 원소가 부분 수열의 모든 원소보다 클 때에만 길이가 변하기
 때문이다.

## 부분 수열 좀더 잘 만들기

 이제 `O(nlogn)`의 알고리즘을 소개하겠다. 위의 방법에서 `n`이 증가하지
 않을 때 부분 수열 위치를 찾을 때 선형 탐색을 했는데, 이 부분을 좀더
 잘 해서 `logn`으로 떨어뜨릴 수 있다. 바로 이분 탐색을 이용하는
 것이다.

```python
def lengthOfLIS(nums):
    sub = []
    for n in nums:
        i = bisect.bisect_left(sub, n)
        if i == len(sub):
            sub.append(n)
        else:
            sub[i] = n

    return len(sub)
```


 참고로 이 알고리즘도 부분 수열의 길이만 제대로 구할 수 있다.
