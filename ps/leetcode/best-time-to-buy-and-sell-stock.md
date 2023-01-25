---
layout: page
tags: [problem-solving, leetcode, python, hash-table]
title: Best Time to Buy and Sell Stock
---

# [Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)

 주식 가격 리스트 `prices`가 주어진다. `i` 번째 날의 주식 가격이
 적혀있다.

 수익을 최대한으로 내기 위해서 주식을 살 날짜 하나와 그 날짜 이후에
 주식을 팔 날짜 하나를 고르고 싶다. 이때 가능한 *최대의 수익*을
 구해보자. 수익을 아예 못내는 경우는 `0`을 리턴한다.

## 접근
 - 배열을 순차적으로(날짜 순으로) 훑어감
 - 항상 판매는 구매 날짜 이후에 가능하므로, 다음 상태를 유지:
   - 지금까지 구매했던 **최소 가격**
   - 지금까지 가능했던 **최대 수익**
 - 날짜를 진행할 때마다 "현재 날짜에 가능한 수익"을 계산할 수 있음:
   `지금 날짜의 가격 - 지금까지 구매했던 최소 가격`. 이를 매번
   최대치로 업데이트
 - 초기 값에 주의
   - 0일에 가능한 최소 가격은 무한대
   - 0일에 가능한 최대 수익은 0

```python
def max_profit(prices):
    min_price_so_far = float('inf')
    max_profit_so_far = 0
    for p in prices:
        min_price_so_far = min(min_price_so_far, p)
        max_profit_so_far = max(max_profit_so_far, p - min_price_so_far)
    return max_profit_so_far
```
