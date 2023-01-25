---
layout: page
tags: [problem-solving, leetcode, python, math]
title: Rectangle Area
---

# [Rectangle Area](https://leetcode.com/problems/rectangle-area/)

 2차원 좌표계에서 두 개의 직사각형을 나타내는 좌표가 주어진다. 이때,
 이 두 개의 직사각형이 만드는 넓이를 구하자.

 두 직사각형을 `a`, `b`라고 했을 때, 각각의 직사각형 좌표는 가장 왼쪽
 아래의 좌표(bottom-left) `(x1, y1)`와 가장 오른쪽 위의
 좌표(top-right) `(x2, y2)`로 주어진다. 따라서 입력은 `(ax1, ay1, ax2,
 ay2)`와 `(bx1, by1, bx2, by2)` 이다.

 - 각 사각형의 좌표 `x1 <= x2` , `y1 <= y2`이고 범위는 $$-10^4 \sim
   10^4$$ 사이이다.

## Exhaustive Case Analysis
 - 가장 무식하지만 단순하고 떠올리기 쉬운 방법은 모든 경우의 수를
   빠뜨림없이 처리하는 것이다.
 - x, y 축을 기준으로 총 6가지 경우가 있다:

![case-analysis](../images/rectangle-exhaustive-case.svg)

 1. Non-overlapping: 안겹치는 경우
 2. Edge overlapping: 모서리가 겹치는 경우
 3. X-eaten: X축으로 한쪽이 먹힌 경우
 4. Y-eaten: Y축으로 한쪽이 먹힌 경우
 5. Cross: 십자가를 형성하는 경우
 6. Subsumed: 한쪽이 다른 한쪽에 포함되는 경우

 모든 경우에 대해서 좌표를 잘 계산해서 (...) 각각의 경우를 다 처리하면
 다음과 같다.

```python
def computeArea(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2):
    a_width, b_width = ax2 - ax1, bx2 - bx1
    a_height, b_height = ay2 - ay1, by2 - by1
    a_area = a_width * a_height
    b_area = b_width * b_height
    ab_area = a_area + b_area

    if (ax1 <= bx1 <= bx2 <= ax2 and ay1 <= by1 <= by2 <= ay2) \
    or (bx1 <= ax1 <= ax2 <= bx2 and by1 <= ay1 <= ay2 <= by2):
        # subsumed case
        return max(a_area, b_area)
    elif (ax1 <= bx1 <= bx2 <= ax2 and by1 <= ay1 <= ay2 <= by2) \
      or (bx1 <= ax1 <= ax2 <= bx2 and ay1 <= by1 <= by2 <= ay2):
        # cross case
        inner_area = min(a_width, b_width) * min(a_height, b_height)
        return ab_area - inner_area
    elif (ax1 <= bx1 <= bx2 <= ax2 and (ay1 <= by1 <= ay2 or ay1 <= by2 <= ay2)) \
      or (bx1 <= ax1 <= ax2 <= bx2 and (by1 <= ay1 <= by2 or by1 <= ay2 <= by2)):
        # x-eaten case
        inner_area = min(a_width, b_width) * min(by2 - ay1, ay2 - by1)
        return ab_area - inner_area
    elif (ay1 <= by1 <= by2 <= ay2 and (ax1 <= bx1 <= ax2 or ax1 <= bx2 <= ax2)) \
      or (by1 <= ay1 <= ay2 <= by2 and (bx1 <= ax1 <= bx2 or bx1 <= ax2 <= bx2)):
        # y-eaten case
        inner_area = min(ax2 - bx1, bx2 - ax1) * min(a_height, b_height)
        return ab_area - inner_area
    elif (ax1 <= bx1 <= ax2 <= bx2 and (ay1 <= by1 <= ay2 <= by2 or by1 <= ay1 <= by2 <= ay2)) \
      or (bx1 <= ax1 <= bx2 <= ax2 and (ay1 <= by1 <= ay2 <= by2 or by1 <= ay1 <= by2 <= ay2)):
        # edge overlapping case
        inner_area = min(bx2 - ax1, ax2 - bx2) * min(by2 - ay1, ay2 - by1)
        return ab_area - inner_area
    else:
        # non-overlapping case
        return ab_area
```


## Math
 - 좀더 똑똑하게 하는 방법을 생각해보자.
 - 1차원 X축만 생각했을 때, 두 선이 겹치는지 안겹치는지를 확인하는
   방법은 다음과 같다.
```python
if min(ax2, bx2) < max(ax1, bx1):
    # non-overlapping
    pass
else:
    # overlapping four cases!
    pass
```
 - 즉, 선이 서로 안겹치면 `(ax1, ax2) < (bx1, bx2)` 또는 `(bx1, bx2) <
   (ax1, ax2)` 이기 때문에, `x2` 좌표 중 더 작은 값 (`ax2` 또는
   `bx2`)이 `x1` 좌표 중 더 큰 값 (`bx1` 또는 `ax1`)보다 항상 작다.
 - 서로 겹치는 경우에는 `min(ax2, bx2) - max(ax1, bx1)` 값이 곧바로
   겹치는 부분의 길이가 된다.
 - 따라서, 이걸 X축과 Y축 각각에 대해서 구한 다음에 곱하면 그게 바로
   겹치는 영역이다.
 - 즉, X축과 Y축이 모두 겹치는 부분이 있어야 겹치는 영역이 있는
   것이고, 위의 수식은 겹치는 다음 네 가지 경우를 모두 포함한다:
![overlapping](../images/overlapping.svg)

 1. 겹치는 부분의 길이: `ax2 - bx1 = min(ax2, bx2) - max(ax1, bx1)`
 2. 겹치는 부분의 길이: `bx2 - ax1 = min(ax2, bx2) - max(ax1, bx1)`
 3. 겹치는 부분의 길이: `ax2 - ax1 = min(ax2, bx2) - max(ax1, bx1)`
 4. 겹치는 부분의 길이: `bx2 - bx1 = min(ax2, bx2) - max(ax1, bx1)`

```python
def computeArea(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2):
    a_area = (ay2 - ay1) * (ax2 - ax1)
    b_area = (by2 - by1) * (bx2 - bx1)

    overlapping_width = min(ax2, bx2) - max(ax1, bx1)
    overlapping_height = min(ay2, by2) - max(ay1, by1)

    overlapping_area = 0
    if overlapping_width > 0 and overlapping_height > 0:
        overlapping_area = overlapping_width * overlapping_height

    return a_area + b_area - overlapping_area
```
