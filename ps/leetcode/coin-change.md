---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Coin Change
---

# [Coin Change](https://leetcode.com/problems/coin-change/)

 서로 다른 금액을 나타내는 코인 배열 `coins`와 전체 돈의 양을 나타내는
 `amount` 정수 값이 주어진다. 이 양을 맞추기 위해서 필요한 최소한의
 코인의 수를 구하자. 어떤 코인의 조합도 양을 맞출 수 없다면 `-1`을
 리턴.

 각 코인은 무한개 있다고 가정해도 된다.

 - 배열 크기: 1~12
 - 코인 값: $$ 1 \sim 2^{31} - 1 $$
 - 돈의 양: 0~10,000

## 오답 노트 - 그리디 알고리즘
 탐욕법이 먹힐 것 같이 생겼지만 실제로는 반례가 있음.  `coins =
 [1,3,4]`이고 `amount = 6`일 때 그리디하게 풀면 `(4, 1, 1)`이 되어 3을
 구하지만, 실제 정답은 `(3, 3)`의 2가 된다.

 **따라서 그리디 쓰면 안된다.**

## DP - 메모아이제이션
 - `F(A) =` `A`를 맞추기 위한 최소한의 코인 개수.
 - 따라서 금액 `C`인 코인을 선택한다면, `F(A) = F(A - C) + 1`이
   성립한다.
 - 코인이 몇 개인지 모르기 때문에 다음 등식이 성립: $$ F(A) =
   min_{i=0..n-1}F(A-c_{i}) + 1 $$
 - 기저 조건을 생각해보면 `F(0) = 0`임.
 - 그외 불가능한 경우는 `A`가 음수인 경우
 - 각 코인마다 전부 가능한 경우를 따져봐야 하고, 이걸 다시 최소값으로
   누적해야 올바른 답을 구할 수 있다.

```python
import functools
def coinChange(coins, amount):
    @functools.cache
    def recurse(a):
        if a < 0:
            return -1
        if a == 0:
            return 0

        mincost = float('inf')
        for coin in coins:
            fa = recurse(a - coin)
            if fa == -1:
                continue
            mincost = min(mincost, fa + 1)
        return -1 if mincost == float('inf') else mincost

    return recurse(amount)
```
