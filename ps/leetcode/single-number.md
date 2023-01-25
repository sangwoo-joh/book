---
layout: page
tags: [problem-solving, leetcode, python, ]
title: Single Number
last_update: 2023-01-25 18:32:50
---

# [Single Number](https://leetcode.com/problems/single-number/)

 정수 배열이 주어지는데, 딱 하나의 원소만 빼고 나머지 원소는 전부
 정확히 두 번 등장한다. 여기서 딱 한 번만 등장하는 원소 하나를 찾자.

 배열의 크기는 1 ~ 30,000 사이이고 원소 값의 범위는 -30,000 ~ 30,000
 사이이다. 문제의 조건에 부합하는 배열만 입력으로 들어온다.

 선형 시간 복잡도와 상수 공간 복잡도를 구현해야 한다.

## 접근 1
 - 일단 O(N) 시간만 만족하도록 해보자. 공간 복잡도도 역시 O(N)이
   가능하다면 답은 해시 셋이다.
 - 정답 원소를 뺀 나머지는 정확히 두 번 등장하기 때문에, 첫 등장에
   셋에 집어넣고 두 번째 등장에 셋에서 빼면 된다. 그럼 셋에 남은 원소
   하나가 바로 답이다.
 - 이렇게하면 최악의 경우여도 O(N/2)의 공간 복잡도를 가질 것 같다.

```python
def singleNumber(nums):
    bucket = set()
    for n in nums:
        if n in bucket:
            bucket.remove(n)
        else:
            bucket.add(n)
    return bucket.pop()
```


## 접근 2
 - 공간 복잡도 O(1)을 만족하려면 XOR 연산의 성질을 활용해야 한다.
 - XOR 연산의 네 가지 성질: Commutative, Associative, Identity
   Element, Self-Inverse.
 - 이 중 Identity Element가 존재해서 `X ^ 0 = X`인 것과,
   Self-Inverse라서 `X ^ X = 0`인 것이 중요하다.
 - 즉, 어떤 정수를 비트로 표현했을 때, 이 수를 두 번 XOR 하면 XOR
   연산의 Identity Element가 된다.
 - 따라서, 어떤 수가 됐던지 XOR을 두 번 하면 사라진다.
 - 문제의 조건에 따라 딱 하나의 원소를 빼고 나머지는 정확히 두 번
   등장하므로, 그냥 모든 수를 XOR로 누적하면 남는 값이 정답이다.

```python
def singleNumber(nums):
    answer = 0
    for n in nums:
        answer ^= n
    return answer
```
