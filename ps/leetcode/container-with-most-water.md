---
layout: page
tags: [problem-solving, leetcode, python, array]
title: Container with Most Water
---

# [Container with Most Water](https://leetcode.com/problems/container-with-most-water/)

 높이가 적힌 배열 `height`가 들어온다. 여기에는 배열의 크기 `n`개
 만큼의 수직선(세로선)의 정보가 들어있는데 `i`번째 수직선은 `(i,
 0)`부터 `(i, height[i])`까지 긋는다.

 이 중에서 두 개의 서로 다른 수직선을 골라 X축을 이으면 물을 담을 수
 있는 컨테이너를 그릴 수 있다. 이 중 가장 많은 물을 저장할 수 있는
 컨테이너를 만드는 두 개의 수직선을 찾고, 그때의 물의 양을 구하자.

 컨테이너를 기울이면 안된다.

 배열의 크기는 2~100,000, 높이는 0~10,000 사이이다. 항상 최소 두 개의
 수직선이 있음이 보장된다.

## 투 포인터

 컨테이너를 기울이면 안된다는 조건에 집중하자. 즉, 두 개의 수직선
 중에서 더 짧은 쪽이 컨테이너의 물의 양을 결정한다. 그리고, X축이
 길수록 컨테이너가 넓어지므로 물의 양이 더 많아진다.

 그러므로 우리가 찾아야 하는 수직선의 조건은 다음과 같다:
 - 두 수직선 사이가 멀수록 좋다.
 - 두 수직선 중 짧은 쪽의 길이가 클수록 좋다.

 수직선 두 개를 골라야 하므로 투 포인터 기법이 가장 유력해보인다. 두
 수직선 사이가 멀수록 좋기 때문에, 양 끝점에서 시작해서 한 칸씩
 좁혀나가면서 최대의 수량을 구하면 된다. 이때, 둘 중 더 긴 쪽의
 수직선은 그대로 두고, 더 짧은 쪽의 수직선을 계속해서
 움직여나간다. 즉, 좁혀나간다. 이렇게 두 개의 포인터가 서로 끝까지
 도달할 때까지 모든 케이스를 다 살펴보면 된다.

 일단 두 X좌표가 주어졌을 때 물의 양을 구하는 함수를 짜두자.

```python
def water(x1, x2):
    return abs(x1 - x2) * min(height[x1], hight[x2])
```

 그 후, 투 포인터를 유지하면서 최대 물의 양을 계속 누적해가면서 더
 짧은 쪽의 위치를 계속 좁혀나가도록 하면 된다.

```python
def maxArea(height):
    maxarea = 0
    start, end = 0, len(height) - 1
    while start < len(height) and end >= 0:
        maxarea = max(maxarea, water(start, end))
        if height[start] < height[end]:
            start += 1
        else:
            end -= 1
    return maxarea
```
