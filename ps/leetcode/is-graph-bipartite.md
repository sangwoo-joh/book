---
layout: page
tags: [problem-solving, leetcode, python, graph]
title: Is Graph Bipartite?
---

# [Is Graph Bipartite?](https://leetcode.com/problems/is-graph-bipartite/)

 `n`개의 노드를 가진 무향 그래프가 주어진다. 노드는 `0`부터 `n-1`까지
 레이블링 되어 있다is-graph-bipartite. 2차원 배열 `graph`가 입력으로 들어오는데,
 `graph[u]`는 노드 `u`와 인접한 노드의 배열이다.
 - 자기 자신에게 가는 엣지는 없다. 즉, $$ \forall node, graph[node]
   \neq node $$
 - 여러 개의 엣지도 없다. `graph[u]`는 중복 원소를 담고 있지 않는다.
 - `v`가 `graph[u]`안에 있다면, `graph[v]` 안에도 `u`가 있다. 즉,
   무향이다.
 - 그래프는 연결이 안되어 있을 수도 있다. 즉, 어떤 두 노드 `u`와 `v`
   사이에 엣지가 없을 수도 있다.

 어떤 그래프의 모든 노드가 두 개의 독립적인 집합 A와 B로 나누어지고
 A에 있는 모든 노드와 B에 있는 모든 노드 사이에 엣지가 존재한다면,
 그래프는 **이분(Bipartite)**이라고 불린다.

 그래프가 이분 그래프인지 판단하자.

## 번갈아 가며 색깔 칠하기

 유명한 이분 그래프 문제다. 인접한 노드끼리 서로 다른 색으로 칠해
 나아가면서, 모든 정점을 두 가지 색으로만 칠할 수 있는지를 확인하는
 문제다.

 결국 그래프를 탐색하면서 서로 다른 색을 칠하면 된다. 탐색은 BFS, DFS
 모두 가능하다. 어차피 엣지가 연결된 두 노드에 서로 다른 색을 칠하기만
 하면 된다.

 색깔을 칠하기 위한 해시 테이블을 도입하자. 그러면, 아직 색이 칠해지지
 않은 노드는 곧 아직 방문하지 않은 노드이기 때문에, 탐색에 쓰이던
 `visited` 집합이 필요없다.

 또한, 입력으로 들어오는 그래프가 연결 그래프가 아닐 수 있기 때문에,
 모든 노드에 대해서 탐색을 해야 한다는 사실에 주의하자.

```python
from collections import deque
def isBipartite(graph):
    colors = {}  # we can check visited by coloring
    q = deque()
    bipartite = True

    for node in range(len(graph)):
        if node not in colors and bipartite:
            q.append(node)
            colors[node] = 1

            while q and bipartite:
                top = q.popleft()
                for neighbor in graph[top]:
                    if neighbor not in colors:
                        q.append(neighbor)
                        colors[neighbor] = -colors[top]
                    elif colors[neighbor] == colors[top]:
                        bipartite = False
                        break
    return bipartite
```

 - BFS로 구현했다. 현재 방문 중인 노드와 인접한 모든 노드를 보면서,
   아직 색이 칠해지지 않았다면(=아직 방문하지 않았다면) 지금 노드와
   다른 색을 칠한다. 색은 `1`과 `-1`을 이용해서 손쉽게 서로 다른
   색임을 표현했다.
 - 만약 색이 같다면 이분 그래프가 아니므로, 더 이상 탐색할 필요가
   없다. 따라서 글로벌 상태로 `bipartite`를 두고, 여전히 이분
   그래프라고 판단될 때에만 그래프를 탐색하도록 최적화했다.
