---
layout: page
tags: [problem-solving, leetcode, python, array, interval]
title: Count Odd Numbers in an Interval Range
---

# [Count Odd Numbers in an Interval Range](https://leetcode.com/problems/count-odd-numbers-in-an-interval-range/)

 $$ 0 \sim 10^9 $$ 사이의 정수 `low`와 `high`가 주어진다. 이 두 수가
 만드는 범위 안의 *홀수*의 개수를 계산하자. 두 수를 포함하는
 범위이다. 즉 `[low, high]` 이다.

## 똑똑하게 세기

 당연하지만 `low`부터 `high`까지 일일이 세면 안된다. 범위를 좀
 살펴보자.

 `low`, `high`를 포함하는 범위이므로 이 값이 모두 홀수일 때를
 생각해보자. 예를 들어 `[1, 2, 3, 4, 5]` 를 생각해보면, 홀수의 개수는
 3개이다. 즉 `1`과 `5` 범위의 길이 + 1 이 홀수의 개수가 된다.

 둘 다 짝수이거나 둘 중 하나만 짝수일 때에는 어떻게 될까? 예를 들어
 `[0, 1, 2, 3]`을 생각해보자. 짝수인 `low`는 홀수가 아니지만 이를 한
 칸 오른쪽으로 민 `1`은 홀수이므로, 사실 이 때의 홀수 개수는 `[1, 2,
 3]`에서의 홀수 개수와 같다. 반대의 경우도 마찬가지이다.

 따라서, 먼저 범위의 시작과 끝을 홀수로 맞춘 다음, 홀수 범위 안의
 길이 + 1을 계산하면 된다.

```python
def countOdds(low, high):
    if low % 2 == 0:
        low += 1
    if high % 2 == 0:
        high -= 1
    return (high - low) // 2 + 1
```
