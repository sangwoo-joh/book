---
layout: page
tags: [problem-solving, leetcode, python, binary-search]
title: Pow(x, n)
---

# [Pow(x, n)](https://leetcode.com/problems/powx-n/)

 `pow(x, n)`, 즉 $$ x ^ n $$ 을 계산하자.

 $$ -100.0 < x < 100.0 $$, $$ -2^{31} \leq n \leq 2^{31} -1 $$, $$
 -10^4 \leq x^n \leq 10^4 $$ 이다.

## 정직한 구현 - 타임아웃

 정직하게 한번 구현해보자. 주의할 것은 지수가 음수인 경우이다. 이때는
 곱하는 게 아니라 나눠줘야 한다.

```python
def myPow(x, n):
    if n < 0:
        x = 1 / x
        n = -n
    answer = 1
    while n:
        answer *= x
        n -= 1
    return answer
```

 당연하지만 이러면 타임아웃 난다.

## 더 빠른 구현

 빠른 지수 함수를 계산하는 데에는 널리 알려진 방법이 있다. Divide and
 Conquer라고 볼 수도 있고 바이너리 서치라고 볼 수도 있는데, 아무튼
 다음 성질을 이용하면 된다:
 - `n`이 2로 나눠 떨어질 때: $$ x ^ n = x ^ {n/2} \times x ^ {n/2} $$
 - Otherwise: $$ x ^ n = x \times x ^{n-1} $$

 여기서 `n`이 2의 배수일 때 $$ x ^ {n/2}$$ 라는 같은 값을 구하기
 때문에, 이를 이용하면 된다.

```python
def myPow(x, n):
    def fast_power(x, n):
        if n == 0:
            return 1.0
        if n % 2 == 0:
            half = fast_power(x, n // 2)
            return half * half
        else:
            return fast_power(x, n - 1) * x
    if n < 0:
        x = 1 / x
        n = -n
    return fast_power(x, n)
```

 위의 수식을 거의 그대로 옮겨둔 재귀 함수이다. 문제를 절반 씩 나눠
 풀고 있기 때문에 복잡도는 `O(logN)` 이 된다.
