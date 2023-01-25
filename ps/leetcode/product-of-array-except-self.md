---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Product of Array Except Self
last_update: 2023-01-25 18:33:39
---

# [Product of Array Except Self](https://leetcode.com/problems/product-of-array-except-self/)

 정수 배열이 주어졌을 때, 다음 조건을 만족하는 새로운 배열을 만들자:
 - i 번째 원소는 i 번째 원소 자신을 제외한 모든 수의 곱과 같은 값

 모든 곱은 32비트 정수 안에 표현되는 것이 보장된다.

 알고리즘의 복잡도는 O(N)이어야 하고, **나누기 연산을 사용하면
 안된다.**

 정수 배열의 크기는 2~100,000 이고 정수의 값은 -30~30이다.

## 접근 1 - 나누기 연산을 쓰는 버전
 - 일단 나누기 연산을 쓰는 접근이 가장 쉽다.
 - 모든 곱이 32비트 정수 안에 담길 수 있기 때문에 배열 전체를 곱해서
   누적해둔 다음 `i` 번째 값으로 나누기만 하면 된다.
   - 이때 0을 주의해야 한다.
   - 0이 두 개 이상이면 어차피 뭘 곱해도 0이다.
   - 0이 하나일 때는 0인 곳만 주의하면 된다.
   - 0이 없을 때는 원래 방법대로 하면 된다.
 - 즉, 두 가지 상태를 유지해야 한다:
   - 0의 개수
   - 0을 뺀 나머지 수들의 곱


```python
def productExceptSelf(nums):
    all_product_except_zero = 1
    zero_count = 0
    for n in nums:
        if n != 0:
            all_product_except_zero *= n
        else:
            zero_count += 1
    answer = []
    if zero_count == 0:
        for n in nums:
            answer.append(all_product_except_zero // n)
    elif zero_count == 1:
        for n in nums:
            if n != 0:
                answer.append(0)
            else:
                answer.append(all_product_except_zero)
    else:
        answer = [0] * len(nums)
    return answer
```


## 접근 2 - 문제의 조건에 따라 나누기 안쓰는 방법
 - 문제의 조건에 힌트가 있다: O(N)
 - 배열을 정방향으로, 역방향으로 훑자.
 - 누적 합과 비슷한 누적 곱의 아이디어를 적용하자.
 - 정방향의 누적 곱과 역방향의 누적 곱이 있으면 인덱스 `i` 에서의 곱을
   구할 수 있다: `i`를 기준으로 왼쪽의 누적 곱과 오른쪽의 누적 곱을
   곱하면 된다.
 - 즉, 정방향 누적 곱은 왼쪽의 누적 곱, 역방향 누적 곱은 오른쪽의 누적
   곱이 된다.
 - `left`를 만드는 방법은 straightforward하다. 0번째의 왼쪽에는 아무런
   값도 없으므로 null이 맞겠지만, 계산의 편의를 위해 1로 준다. 그러면
   그 이후 `i` 번째의 값은 이전의 `i-1` 번째의 값에 `i`번째 값을
   곱해서 누적해 나아가면 된다. 단, 제일 마지막 원소는 곱할 일이
   없으므로 스킵한다.
 - `right`는 `left`를 만드는 방법을 거꾸로 하면 된다. 여기서는 배열을
   뒤집어서 차례대로 누적 곱을 구한 뒤에 이것을 한번 더
   뒤집었다. 그래야 정상적으로 오른쪽에 있는 원소의 순서가 된다.

```python
def productExceptSelf(nums):
    left = [1]
    for n in nums[:len(nums)-1]:
        left.append(left[-1] * n)

    right = [1]
    for n in list(reversed(nums))[:len(nums)-1]:
        right.append(right[-1] * n)
    right = reversed(right)

    answer = []
    for l, r in zip(left, right):
        answer.append(l * r)
    return answer
```
