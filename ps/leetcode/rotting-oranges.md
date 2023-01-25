---
layout: page
tags: [problem-solving, leetcode, python, graph, simulation]
title: Rotting Oranges
last_update: 2023-01-25 18:33:22
---

# [Rotting Oranges](https://leetcode.com/problems/rotting-oranges/)
 `m x n` 격자가 주어지는데 각 쎌은 세 종류의 값을 갖는다.
  - `0`: 비어 있는 쎌
  - `1`: 신선한 오렌지
  - `2`: 썩은 오렌지

 매 1분마다, 신선한 오렌지 중에서 4방향 중 한 곳이라도 썩은 오렌지랑
 맞닿아 있는 애는 썩는다.

 격자의 모든 오렌지가 썩기 위해서 지나야 하는 최소 시간을
 구하자. 불가능하면 `-1`을 리턴하자.

 예를 들면 아래와 같은 경우, 총 4분이 필요하다.

```
2 1 1      2 2 1      2 2 2      2 2 2     2 2 2
1 1 0  --> 2 1 0  --> 2 2 0  --> 2 2 0 --> 2 2 0 --> ....
0 1 1      0 1 1      0 1 1      0 2 1     0 2 2
```

## BFS With Barrier
 *4방향 중 한 곳이라도* 에서 BFS의 냄새가 난다. 다만, 한 번(1분)에 한
 스텝 씩 상태가 진행되어야 한다는 점이 새로운데, 시간 사이에 배리어
 데이터를 넣어서 구분하면 될 것 같다.

 일단 시작점은 썩은 오렌지이므로, 무조건 한번은 격자 전체를 다 훑어서
 썩은 위치를 찾아내야 한다. 그리고 이 썩은 오렌지의 위치들을 큐에
 넣어둔다. 동시에 썩혀야 할 신선한 오렌지의 전체 개수도 미리
 계산해둔다. 격자의 모든 오렌지가 썩었다는 것은 곧 격자에 있던 신선한
 오렌지가 하나도 없게 되는 것과 동치이기 때문이, 시간이 지나면서
 신선한 오렌지가 썩을 때마다 신선한 오렌지 개수를 깎으면 될 것 같다.

 그리고 BFS를 할 껀데, 이때 큐에서 꺼낸 데이터가 배리어면, 그때마다
 지나간 시간을 누적하면 된다. 위의 4분 예시에서는 다음과 같이 흘러갈
 것이다.

```
t   queue
-----------
0: [(0, 0), barrier]  # 시작 상태
0: [barrier, (0, 1), (1, 0)]  # 첫 큐를 꺼내고 난 상태
1: [(0, 1), (1, 0), barrier]  # 배리어 덕분에 시간이 흘러간 것을 알게됨
1: [barrier, (1, 1), (0, 2)]
2: [(1, 1), (0, 2), barrier]
2: [barrier, (2, 0)]
3: [(2, 0), barrier]
3: [barrier, (2, 2)]
4: [(2, 2), barrier]
4: [barrier]
4: []  # DONE
```

 더 이상 썩힐 신선한 오렌지가 없으면, 큐에는 배리어 하나만 남게
 된다. 즉, 큐에서 꺼낸게 배리어인데 여전히 큐에 데이터가 남아있는
 경우에만 시간을 진행시킬 수 있다.

 이 아이디어를 구현하면 다음과 같다.

```python
from collections import deque
def orange_rotting(grid):
    q = deque()
    fresh = 0
    m, n = len(grid), len(grid[0])
    # initialize rotten oranges queued, and count fresh oranges
    for x in range(m):
        for y in range(n):
            if grid[x][y] == 2:
                q.append((x, y))
            elif grid[x][y] == 1:
                fresh += 1

    barrier = (None, None)  # used to denote elapsed time
    q.append(barrier)

    elapsed = 0
    while q:
        x, y = q.popleft()
        # check if time has been elapsed
        if (x, y) == barrier:
            if q:
                # if there are still some rotten oranges,
                # it can be proceeded.
                elapsed += 1
                q.append(barrier)
            continue

        # proceed to next state
        for nx, ny in ((x+1, y), (x-1, y), (x, y+1), (x, y-1)):
            if 0 <= nx < m and 0 <= ny < n:
                if grid[nx][ny] == 1:
                    # rotting
                    grid[nx][ny] = 2
                    fresh -= 1
                    q.append((nx, ny))

    return elapsed if fresh == 0 else -1
```

 - 배리어로 `(None, None)`을 활용했다. 큐에는 좌표값만 쌓이기 때문에
   그냥 `None` 하나보다는 튜플로 곧바로 받으면 편하다.
 - 앞서 설명한 것처럼 BFS 진입후 꺼낸 데이터가 배리어이고, 꺼냈는데도
   큐에 여전히 데이터가 남아있을 때에만 시간이 진행된다. 그리고 동시에
   배리어를 큐에 넣어줘서, 그 다음 시간을 위한 선을 긋는다.
 - 최종적으로 남아있는 신선한 오렌지 개수가 0일 때에만 흐른 시간을
   리턴한다.
