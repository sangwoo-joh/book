---
layout: page
tags: [problem-solving, theory, graph]
title: Breadth First Search
last_update: 2023-01-25 23:47:44
---

# BFS
 BFS는 최단 거리를 찾는 데에 쓸 수 있다. 그리고 BFS 코드는 생긴 모습이
 문제와 상관없이 거의 유사하기 때문에 잘 기억해두면 좋다.

```python
from collections import deque

def bfs(graph, starting, visited):
    m, n = len(graph), len(graph[0])
    visited.add(starting)
    q = deque()
    q.append(starting)

    while q:
        y, x = q.popleft()
        # populate next states
        for ny, nx in ((y+1, x), (y-1, x), (y, x+1), (y, x-1)):
            # check range
            if ny < 0 or nx < 0 or ny >= m or nx >= n:
                continue
            # check reachability
            if (ny, nx) not in visited and reachable(graph[ny][nx]):
                visited.add((ny, nx))
                q.append((ny, nx))
```

 기억해야 할 점은 다음 세 가지이다.
 - 큐에 넣고 꺼내는 순서에 주의해야 한다. 시작점은 곧바로 큐에
   넣는다. 큐를 검사하는 동안, 큐에서 꺼낸 위치로부터 다음 위치를 큐에
   넣을 때는 항상 **올바른 위치 - 즉 범위 안에 있고 도달 가능한 경우**
   일 때에만 넣는다.
 - 큐에 넣는 것과 동시에 방문 집합에 넣어야 탐색 공간이 터지지
   않는다. 이거 때문에 메모리 초과 나는 경우가 많기 때문에
   중요하다. **큐에 넣을 때 동시에 `visited` 집합에 넣어야 한다**.
 - 큐에 **다음 위치를 넣을 때 방문 체크**를 해야 한다. 큐에서 방금
   꺼낸 좌표 `(y, x) = q.popleft()`는 **방문을 완료한
   위치**(invariant)이다. 따라서 큐에서 꺼내자마자 방문 체크를 하면
   처음 시도부터 방문을 완료한 걸로 확인되어서 아무런 탐색도 하지
   않는다.


 거리와 같은 추가적인 정보를 함께 갖고 다니면서 최단 거리를 계산하고
 싶은 경우에는 다음과 같이 하면 된다.

```python
def bfs(graph, starting, visited):
    m, n = len(graph), len(graph[0])
    visited.add(starting)
    q = deque()
    q.append((0, starting))  # carry with step

    while q:
        step, (y, x) = q.popleft()

        # check arrival here!
        if has_arrived(y, x):
            return step

        # populate next states
        for ny, nx in ((y+1, x), (y-1, x), (y, x+1), (y, x-1)):
            # check range
            if ny < 0 or nx < 0 or ny >= m or nx >= n:
                continue
            # or check arrival here, with step + 1
            if has_arrived(ny, nx):
                return step + 1
            # check reachability
            if (ny, nx) not in visited and reachable(graph[ny][nx]):
                visited.add((ny, nx))
                q.append((step + 1, (ny, nx)))  # carry with step
```

 최단 거리를 구할 때 주의해야 할 점은 딱 한 가지다. 도착 여부 체크
 `has_arrived()`를 언제 하느냐에 따라서 정답이 되는 거리가 `step`인지
 `step + 1`인지이다. 즉, 큐에서 방금 꺼낸 위치는 방문을 완료한
 위치이기 때문에 꺼내자마자 도착 여부를 체크를 하면 `step`이고, 다음
 위치를 계산하는 시점에 도착 여부를 확인하면 `step + 1`이 거리가
 된다. 아마 다음 위치를 계산하는 시점에서 확인하면 상태를 조금이라도
 덜 탐색하기 때문에 (큐에 넣고 빼는 과정이 없음) 시간 및 공간적으로
 조금이라도 더 낫겠지만 전체 복잡도에서는 차이가 없을 것이므로 적당히
 취향 껏 하면 된다.
