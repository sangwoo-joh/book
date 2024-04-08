---
layout: page
tags: [problem-solving, theory, graph]
title: Breadth First Search
last_update: 2024-04-06 23:55:03
---

# BFS
BFS 알고리즘의 결과로 얻어지는 경로는 시작 노드로부터 가장 가까운 거리에 있는 노드, 즉 엣지 수가 가장 적은 경로를 갖는 노드이다.
알고리즘의 복잡도는 $$O(n+m)$$ 이고 n은 노드의 수, m은 엣지의 수 이다.

### 알고리즘
웨이트가 없는 그래프와 시작 노드를 입력으로 받는다. 입력 그래프의 방향성(무향/유향)은 상관없다.
알고리즘을 불이 뻗어나가는 것으로 이해할 수 있다. 0번째 단계에서 시작 노드 s에 불이 붙는다. 이후 각각의 단계에서 각 노드와 인접한 노드에 불이 붙는다. 이러한 반복에 의해서 "불의 고리"가 넓게 퍼져 나간다.


### 구현
```python
from collections import deque

def bfs(graph: List[List[int]], source: int, n: int):
    q = deque()
    visited = set()
    dist, parent = [0] * n, [0] * n

    q.append(source)
    visited.add(source)
    parent[source] = -1
    while q:
        node = q.popleft()
        for neighbor in graph[node]:
            if neighbor in visited:
                continue
            visited.add(neighbor)
            q.append(neighbor)
            dist[node] = dist[neighbor] + 1
            parent[neighbor] = node

```

 - 큐가 빌 때까지 반복한다. 따라서, 큐의 초기 상태는 시작 노드 `source`가 들어있어야 한다.
 - 큐에서 꺼낸 노드는 항상 방문이 완료된 상태, 즉 `visited` 집합에 들어 있는 노드임이 불변식(invariant)이다.
 - 각 단계에서 인접한 노드의 방문 여부를 먼저 확인한다. 아직 방문하지 않았다면, 방문 표시를 하고 큐에 넣어야 한다. 그래야 탐색 공간이 터지지 않는다.
 - 각 단계에서 인접한 노드를 방문할 때, 방문을 완료한 이전 노드의 정보를 이용해서 (1) 이때까지 (시작 노드로부터) 거쳐온 거리와 해당 노드의 바로 직전 노드(부모) 정보를 기록할 수 있다. 이 정보를 이용하면 다음과 같이 최단 경로를 알아낼 수 있다.

```python
def shortest_path(source: int, parent: List[int]) -> List[int]:
    path = []
    node = source
    while node != -1:
        path.append(node)
        node = parent[node]

    return reversed(path)
```


그래프가 아닌 좌표 평면 상의 최단 경로를 구하는 데에도 적용할 수 있다.

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

최단 거리를 구할 때 주의해야 할 점은 딱 한 가지다. 도착 여부 체크 `has_arrived()`를 언제 하느냐에 따라서 정답이 되는 거리가 `step`인지 `step + 1`인지이다. 즉, 큐에서 방금 꺼낸 위치는 방문을 완료한 위치이기 때문에 꺼내자마자 도착 여부를 체크를 하면 `step`이고, 다음 위치를 계산하는 시점에 도착 여부를 확인하면 `step + 1`이 거리가 된다. 아마 다음 위치를 계산하는 시점에서 확인하면 상태를 조금이라도 덜 탐색하기 때문에 (큐에 넣고 빼는 과정이 없음) 시간 및 공간적으로 조금이라도 더 낫겠지만 전체 복잡도에서는 차이가 없을 것이므로 적당히 취향 껏 하면 된다.


### BFS의 응용
 * 웨이트가 없는 그래프에서 시작 노드로부터 다른 모든 노드로의 최단 경로 찾기.
 * 무향 그래프에서 $$O(n+m)$$ 복잡도로 모든 연결 요소(connected component) 찾기: 이걸 하려면 BFS를 각각의 노드에 대해서 모두 수행해야 하는데, 이때 이전의 수행에서 방문된 노드들은 제외한다. 그러면 각각의 노드로부터 일반적인 BFS를 수행하게 되지만, 새로운 연결 요소를 만나더라도 `visited` 집합을 초기화하지 않기 때문에 전체 수행 시간은 그대로 $$O(n+m)$$이 된다. 이렇게 방문 집합을 유지하면서 BFS를 여러 번 수행하는 것을 연속 BFS (a series of BFSes)라고 한다.
 * 어떤 문제나 게임에서 최소한의 턴(움직임)으로 해결할 수 있는 해법 찾기: 게임의 각 상태를 그래프의 노드로 표현하고 하나의 상태에서 다른 상태로 바뀌는 것을 그래프의 엣지로 표현하면 된다.
 * 웨이트가 0 또는 1만 있는 그래프에서 최단 경로 찾기: 일반적인 BFS에 아주 약간의 수정을 가하면 된다. `visited` 집합을 유지하지 않고, 대신 노드까지의 거리가 현재 계산한 거리보다 짧은지를 체크한 후 현재 엣지의 웨이트가 0이라면 큐의 앞쪽에 넣고 아니면 큐의 뒷쪽에 넣는다. 이러한 방법을 [0-1 BFS](../0-1-bfs) 라고 한다.
 * 웨이트가 없는 유향 그래프에서 가장 짧은 싸이클 찾기: 각각의 노드에서 BFS를 시작한다. 시작 노드로 다시 되돌아 오는 순간 우리는 시작 노드로부터 가장 짧은 싸이클을 찾은 것이다. 이 시점에서 BFS를 멈추가 그 다음 노드에 대해서 새로운 BFS를 시작하면 된다. 그리고 이렇게 찾은 모든 싸이클 중에서 가장 짧은 것을 고르면 된다.
 * 주어진 노드 쌍 (a, b) 사이의 어떤 최단 경로에 있는 모든 노드 구하기. 이걸 하려면 BFS를 두 번 하면 된다. 먼저 a에서 b로 한번 한다. $$d_{a}[]$$를 첫 번째 (a로부터의) BFS를 통해 얻은 최단 거리 배열이라고 하자. 그 다음 b에서 a로 한다. 두 번째 (b로부터의) BFS를 통해 얻은 최단 거리 배열을 $$d_{b}[]$$라고 하자. 그러면 각각의 노드 x에 대해서 해당 노드가 a와 b 사이의 최단 경로에 있는지를 쉽게 확인할 수 있다: $$d_{a}[x] + d_{b}[x] = d_{a}[b]$$.
 * 주어진 노드 쌍 (a, b) 사이의 어떤 최단 경로에 있는 모든 엣지 구하기. 이걸 하려면 BFS를 a -> b, b -> a 방향으로 두 번 수행해서 각 시작 노드로부터의 최단 거리 배열 $$d_{a}[]$$와 $$d_{b}[]$$를 구한 다음, 모든 엣지 (x, y)에 대해서 다음 조건을 확인하면 된다: $$d_{a}[x] + 1 + d_{b}[y] = d_{a}[b]$$.
 * 웨이트가 없는 그래프에서 시작 노드 s로부터 목표 노드 t까지의 **짝수 거리**를 갖는 최단 경로 찾기: 이걸 하려면 보조 그래프부터 만들어야 한다. 현재 노드를 v, 현재 패리티(즉 홀짝성) 0 또는 1을 담은 변수를 c라고 하면, (v, c) 상태를 노드로 하는 새로운 그래프를 만들자. 그러면 원래 그래프의 어떤 엣지 (x, y)는 이 새로운 그래프에서 두 개의 엣지 ((x, 0), (y, 1))과 ((x, 1), (y, 0))을 갖게 된다. 그러면 이제 우리는 시작 노드 (s, 0)에서 목표 노드 (t, 0)까지의 최단 경로를 구하면 된다.
