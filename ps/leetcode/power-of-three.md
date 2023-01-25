---
layout: page
tags: [problem-solving, leetcode, python, math]
title: Power of Three
---

# [Power of Three](https://leetcode.com/problems/power-of-three/)

 정수가 주어졌을 때 이게 $$ n = 3^x $$를 만족하는 수인지 확인하자.

 `n`은 32비트 정수 범위의 모든 값이다.

## 접근 1 - 반복문
 - 가장 쉬운 방법은 1($$3^0$$)부터 시작해서 `n`과 크거나 같아질 때까지
   계속 3을 곱한 다음 같은 값인지 보는 것
 - 문제의 조건에 따라 음수는 답이 될 수 없음 ($$3^x$$)

```python
def isPowerOfThree(n):
    if n < 0:
        return False
    x = 1
    while x < n:
        x *= 3
    return x == n
```


## 접근 2 - 반복문 없이
 - 반복문 없이 하려면 수학적인 성질을 이용해야 함
 - 지수의 역함수는 로그이니 로그를 활용
 - $$ n = 3^x \iff x = log_{3}(n) $$
 - 따라서 $$ log_{3}(n) $$이 정수인지 확인하면 됨
 - **주의**: 로그 함수를 도입하는 순간 부동소수점의 오류를 맞이하게
   되는데, 이를 피하기 위해서는 `math.log`($$log_{2}$$) 보다 정확도가
   높은 `math.log10`($$log_{10}$$)을 사용해야 함!

```python
def isPowerOfThree(n):
    import math
    if n <= 0:
        return False
    x = math.log10(n) / math.log10(3)
    return (f - int(f)) == 0
```


## 접근 3 - 반복문 없이 (2)
 - 반복문 없는 또 다른 접근은, 입력의 한계를 이용하는 것
 - 입력은 32비트 정수이고 문제의 조건에 따라 양의 정수만 생각하면
   되므로, 32비트 양의 정수 범위인 $$2^{31} - 1$$ 안에서 가장 큰
   $$3^x$$ 값을 미리 계산한 후 이 값이 n으로 나누어 떨어지는지 보면 됨
   - 이 값은 $$3^{19} = 1162261467$$
   - 이 접근이 가능한 이유는 3이 **소수**이기 때문

```python
def isPowerOfThree(n):
    return n > 0 and 1162261467 % n == 0
```
