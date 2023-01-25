---
layout: page
tags: [problem-solving, leetcode, python, graph, disjoint-set]
title: Number of Connected Components in an Undirected Graph
---

# [Number of Connected Components in an Undirected Graph](https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/)

 `n`개의 노드를 가진 그래프가 주어진다. 그래프는 무향 그래프이고 엣지
 정보 `edges`가 주어지는데 `edges[i] = [ai, bi]` 이고 `ai`와 `bi` 노드
 사이에 엣지가 있다는 의미이다.

 그래프에서 연결된 컴포넌트의 개수를 구하자.

## DFS

 이거 사실 [섬 개수 구하기](../number-of-islands)와 거의 같은
 문제이다. 그래서 DFS로 모든 노드를 방문하면서 방문 기록을 남기고,
 방문 안한 노드를 만날 때마다 개수를 1개씩 증가하면 된다. 이때
 그래프가 무향이므로 엣지 정보를 정방향 한번 역방향 한번 총 두 번
 체크해줘야 한다.

```python
def countComponents(n, edges):
    graph = defaultdict(set)
    for src, snk in edges:
        graph[src].add(snk)
        graph[snk].add(src)

    visited = set()
    def dfs(node):
        if node in visited:
            return
        visited.add(node)

        for neighbor in graph[node]:
            if neighbor not in visited:
                dfs(neighbor)

    count = 0
    for node in range(n):
        if node not in visitied:
            count += 1
            dfs(node)
    return count
```

## Union Find

 하나의 연결된 컴포넌트에 속한 노드는 절대로 다른 컴포넌트에 속할 수
 없다. 즉, 연결된 컴포넌트 안의 원소는 서로소 집합이다. 이 부분도 섬의
 개수 문제와 유사하다. 따라서 서로소 집합, 또는 유니온 파인드로도 풀
 수 있다.

```python
class DisjointSet:
    def __init__(self):
        self.rep = {}
        self.count = 0

    def __len__(self):
        return self.count

    def make(self, x):
        if x not in self.rep:
            count += 1
            self.rep[x] = x

    def find(self, x):
        if x != self.rep[x]:
            self.rep[x] = self.find(self.rep[x])
        return self.rep[x]

    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px != py:
            count -= 1
            self.rep[px] = py

def countComponents(n, edges):
    ds = DisjointSet()
    for i in range(n):
        ds.make(i)

    for src, snk in edges:
        ds.union(src, snk)

    return len(ds)
```

 - 유니온 파인드에서는 굳이 엣지를 양방향으로 볼 필요는 없다. 어차피
   양쪽 다 대표 원소가 지정되어 있으면 합쳐질 뿐이기 때문이다.
