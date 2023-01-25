---
layout: page
tags: [problem-solving, leetcode, python, graph]
title: Number of Distinct Islands
---

# [Number of Distinct Islands](https://leetcode.com/problems/number-of-distinct-islands/)

 `m x n` 지도가 주어진다. 0은 물이고 1은 땅이다. 4방향 1로 이뤄진 땅은
 섬이다. 네 방향의 가장자리는 모두 물로 둘러쌓여 있다.

 어떤 섬의 모양을 바꾸지 않고 그대로 다른 섬에 매칭할 수 있으면, 두
 섬은 **같다**고 취급한다. 즉, 90도, 180도, 270도 회전을 제외한 같은
 모양의 섬은 모두 같은 섬이다.

 지도에서 고유한 섬의 개수를 구하자.

## 접근
 - "고유한(distinct)"의 정의가 모든 회전을 제외한 수평이동임을
   이해하자.
 - 회전이 없어서 그나마 쉬운 편에 속한다.
 - 어떤 방식이든 *섬*의 좌표 집합을 정규화(normalize)하는 방법이
   필요하다.
 - 고유한 섬의 개수를 세기 위해서 (1) 전체 지도를 탐색하는 방향과 (2)
   섬에 속한 땅을 탐색하는 방향을 **항상 일정**하게 유지해야
   한다.
 - 그러면, 어떤 미지의 섬에 속한 첫 번째 땅을 방문하게 될 때, 항상
   같은 땅을 방문하게 되고, 그 후 거기 속한 섬의 땅은 항상 같은 순서로
   탐색됨이 보장된다. 이것이 기본 전제다.
 - 문제의 조건인 **고유한** 섬을 구분하기 위해서 섬에 속한 땅의 좌표의
   집합을 정규화하는 접근을 적용해보자.
 - 같은 모양의 섬은 항상 같은 위치의 땅부터 밟는 것이 보장되므로,
   처음으로 밟는 이 땅의 위치를 항상 원점 `(0, 0)`이라고 하자. 그러면
   나머지 섬의 땅을 이 원점을 기준으로 수평이동하면, 같은 모양의 섬은
   항상 같은 좌표 집합을 갖게 된다.
 - 즉, BFS는 이제 섬을 방문하고 끝나는게 아니라 **섬에 속한 땅의
   정규화된 좌표 집합**을 리턴하는 함수가 된다. 그리고 이걸 다시
   집합으로 쌓아서 최종 개수를 세면 된다.

```python
def numDistinctIslands(grid):
    m, n = len(grid), len(grid[0])
    visited, islands = set(), set()

    def bfs(x, y):
        visited.add((x, y))
        lands = [(0, 0)]
        q = deque()
        q.append((x, y))
        ox, oy = x, y
        while q:
            x, y = q.popleft()
            for nx, ny in [(x+1,y), (x-1,y), (x,y+1), (x,y-1)]:
                if nx < 0 or ny < 0 or nx >= m or ny >= n:
                    continue
                if (nx, ny) in visited or grid[nx][ny] == 0:
                    continue
                visited.add((nx, ny))
                q.append((nx, ny))
                lands.append((nx - ox, ny - oy))
        return lands

    for x in range(m):
        for y in range(n):
            if (x, y) not in visited and grid[x][y] == 1:
                islands.add(tuple(bfs(x, y)))
    return len(islands)
```


## 접근 2
 - 같은 모양의 섬을 정규화하는 또 다른 한 가지 방법은 바로 섬의 땅을
   탐색하는 **방향의 순서**를 기록하는 것이다.
 - 항상 일정한 순서로 네 방향의 땅을 탐색한다고 하면, 같은 모양의 섬에
   속한 모든 땅을 방문하는 방향은 항상 같은 순서일 것이다.
 - 다만 이 방법은 DFS로 밖에 안풀리는 것 같고 구현이 좀더 헷갈린다.
