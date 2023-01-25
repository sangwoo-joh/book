---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Maximum Area of a Piece of Cake After Horizontal and Vertical Cuts
---

# [Maximum Area of a Piece of Cake After Horizontal and Vertical Cuts](https://leetcode.com/problems/maximum-area-of-a-piece-of-cake-after-horizontal-and-vertical-cuts/)

 `h x w` 사이즈의 사각형 모양의 케익이 주어진다. 이를 각각 수평 방향과
 수직 방향으로 자르려고 하는데 이 정보가 `horizontalCuts`와
 `verticalCuts`로 주어진다.
 - `horizontalCuts[i]`는 사각 케익의 위에서부터 수평 방향으로 자른
   `i`번째 부분까지의 거리이다.
 - `verticalCuts[j]`는 사각 케익의 왼쪽에서부터 소직 방향으로 자른
   `j`번째 부분가지의 거리이다.

 이때 케익을 다 자르고 난 뒤 가져갈 수 있는 가장 큰 케익 조각의 면적을
 구하자. 답의 범위가 벗어날 수 있으므로 $$ 10^9+7 $$로 나눈 나머지를
 리턴하자.

 $$ 2 \leq h, w \leq 10^9 $$ 이고 각각의 자르는 정보는 최대 $$10^5$$개
 이다. 모든 원소는 유일하다.

## 정렬..한다..

 2차원이라서 헷갈리는 부분이 있는데, 문제가 1차원 수직선을
 왼쪽으로부터 수직 방향으로 자르는문제라고 생각해보자. 그러면 당연히
 이 중 가장 긴 길이의 선은 자르는 부분 사이의 길이가 가장 큰 부분일
 것이다. 이걸 2차원으로 확장하면 이 문제와 동일하다. 즉, 수직과 수평
 방향의 가장 큰 부분을 각각 찾아서 곱하면 된다.

 단, 여기서 한 가지 조심해야 하는 부분은 **케익의 범위**를 잊으면
 안된다는 것이다. 입력으로 들어오는 자르는 범위 정보는 케익의 어디를
 자르라는 얘기만 있지, 케익의 범위는 암묵적으로 주어져있다: 바로
 `0`부터 `h`, 또는 `0`부터 `w`가 그것이다. 따라서 문제를 조금 쉽게
 풀려면 자르는 정보에 이 값을 각각 보충(augment)한 다음 일괄적으로
 구해도 되겠다.

```python
def maxArea(h, w, horizontalCuts, verticalCuts):
    MOD = 10 ** 9 + 7
    hh, vv = sorted(horizontalCuts + [0, h]), sorted(verticalCuts + [0, w])
    maxh, maxw = 0, 0
    for h0, h1 in zip(hh, hh[1:]):
        maxh = max(maxh, h1 - h0)
    for v0, v1 in zip(vv, vv[1:]):
        maxw = max(maxw, v1 - v0)
    return maxh* maxw % MOD
```

 - `[0, h]`와 `[0, w]`를 각각 보충해서 전체를 정렬하고 있다.
 - 인접한 두 원소의 차이를 계산하기 위해서 파이썬의 슬라이스 연산과
   `zip`연산을 활용했다. 특히 `zip`은 두 오브젝트 중 작은 쪽의 길이로
   맞추기 때문에 `zip(hh, hh[1:])`은 곧 `(hh[0], hh[1]), (hh[1],
   hh[2]), ..., (hh[n-2], hh[n-1])`이 된다.
