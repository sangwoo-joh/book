---
layout: page
tags: [problem-solving, leetcode, python, dynamic-programming]
title: Triangle
---

# [Triangle](https://leetcode.com/problems/triangle/)

 삼각형을 표현한 배열 `triangle`이 입력으로 주어졌을 때, 꼭대기에서
 바닥까지 가는 경로 중 합이 최소가 되는 값을 구하자.

 각각의 단계에서는 아래 행의 인접한 원소로 움직일 수 있다. 좀더
 형식적으로 말하면, 현재 행의 `i` 인덱스에 있다면, 한 단계를
 움직이려면 그 다음 행의 `i` 인덱스 또는 `i+1` 인덱스로 갈 수 있다.

 삼각형의 높이(배열의 길이)는 최대 200이고, 항상 유효한 삼각형 모양이
 입력으로 들어옴이 보장된다. 따라서 `triangle[0].length == 1` 이고
 `triangle[i].length == triangle[i-1] + 1`임이 보장된다. 삼각형 배열
 각 원소는 정수형이고 값의 범위는 $$ -10^4 \sim 10^4 $$ 사이이다.

## 다이나믹.. 프로그래밍..

 꽤 유명한 다이나믹 프로그래밍 문제 중 하나인 것 같다. [경로
 찾기](../unique-paths)와도 비슷한 문제인데, 여기서는 맵이 격자가
 아니라 삼각형인 점, 그리고 원소 합의 최소값을 구해야 한다는 점이
 다르다.

 그러면 다이나믹 프로그래밍을 계획해보자. 먼저 탑 다운 방식과 바텀 업
 방식 중 어떤 것이 가능할지 가늠해보자. 꼭대기로부터 출발해서 바닥까지
 가려면 모든 행을 적어도 한번은 다 살펴봐야 하기 때문에, 탑 다운과
 바텀 업 모두 가능해보인다. 보통 점화식을 세우고 이것을 곧바로 코드로
 옮기기 쉬운 것은 탑 다운 방식이기 때문에, 점화식을 고민해보자.

 `path(r, c)`는 `(r, c)`로부터 바닥까지 가는 경로 합의 최소라고
 하자. 그러면 문제에 나온 "각 단계에 움직일 수 있는 방향"의 정의에
 따라 다음 식이 성립한다: `path(r, c) = triangle[r][c] + min(path(r+1,
 c), path(r+1, c+1))`. 즉 `(r, c)`에서 한 칸 아래(`r+1`)로 갈 때,
 가능한 경우는 다음 행의 `c` 인덱스 또는 `c+1` 인덱스 이고, 이 중 최소
 값을 찾아서 경로에 누적하면 된다.

 그러면 이 식을 곧바로 탑 다운 방식으로 구현하고 메모이제이션할 수
 있다. 단, 이때 인덱스의 범위에 주의해야 한다. 삼각형의 *바닥*까지
 간다는 뜻은 곧 다음 행 (`r+1`)이 삼각형의 높이 안인지 확인하는
 것이다. 이 점을 조심하면서 아이디어를 구현하면 다음과 같다.

```python
def minimumTotal(triangle):
    from functools import cache

    @cache
    def min_path(row, col):
        acc = triangle[row][col]
        if (row + 1) < len(triangle):
            p += min(min_path(row+1, col), path(row+1, col+1))
        return p
    return path(0, 0)
```
