---
layout: page
tags: [problem-solving, theory, python, graph, cycle]
title: Topological Ordering
last_update: 2023-04-09 23:53:46
---

# Topological Ordering


 위상 정렬은 방향성 있는 비순환 그래프, 흔히 DAG(Directed Acyclic Graph)라고
 불리는 그래프의 노드들을 선형 순서로 정렬하는 방법이다. 이 선형 순서는 모든
 엣지의 소스와 싱크를 고려한다. 즉, 엣지 `(src, snk)`에 대해서 노드 `src`는
 반드시 `snk`보다 앞 쪽에 위치하도록 정렬한다.

 위상 정렬은 주로 *의존성*이 있는 상황에서 순서를 결정할 때 사용된다. 예를 들어
 스케쥴링, 컴파일 시에 빌드 의존성 처리, 대학교에서 선행 과목을 고려해서
 시간표짜기 등이 있다.

 하나의 DAG에 대해서는 (노드의 선형 순서만 지켜진다면) 여러 개의 위상 정렬이
 가능하다.

 위상 정렬을 구현하는 방법은 크게 두 가지가 있다. 하나는 노드에 진입하는
 엣지(In-degree Edge) 정보를 이용하는 방법이고, 다른 하나는 DFS를 이용하는
 방법이다.


## 칸의 알고리즘

 In-degree 엣지 정보를 이용하는 알고리즘은 칸의 알고리즘(Kahn's
 Algorithm)이라고도 한다. 노드마다 진입하는 엣지의 수를 유지하면서, 엣지 수가
 0인 노드부터 하나 씩 그래프에서 제거하고 동시에 진입 엣지 수를 업데이트 하면서
 남은 노드가 없을 때까지 반복하는 방법이다.

 알고리즘의 순서는 다음과 같다.
 1. in-degree가 0인 노드를 선택. 여러 개일 경우 어떤 걸 선택해도 무방하다.
 2. 선택한 노드 선형 순서에 추가하고, 동시에 이 노드와 연결된 이웃 노드의 엣지
    수를 업데이트한다.
 3. 만약 업데이트한 이웃 노드의 진입 엣지 수가 0이면 큐에 추가한다.
 4. 1~3을 반복해서 모든 노드가 삭제되면 종료한다.

```python
def topologicalSort(nodes: List[int], edges: List[List[int]]) -> List[int]:
    graph = defaultdict(set)
    nodes = set(nodes)
    indegree = Counter({c: 0 for c in nodes})

    for src, snk in edges:
        graph[src].add(snk)
        indegree[snk] += 1

    ordering = []
    q = deque([c for c in indegree if indegree[c] == 0])
    while q:
        node = q.popleft()
        ordering.append(node)
        for neighbor in graph[node]:
            indegree[neighbor] -= 1
            if indegree[neighbor] == 0:
                q.append(neighbor)

    return ordering
```

 이 알고리즘의 특징은 다음과 같다.
 1. 그래프에 싸이클이 있으면 제대로 된 위상 정렬을 해내지 못한다. 정확히 말하면
    싸이클에 속한 모든 노드는 무슨 짓을 해도 in-degree가 0이 될 수 없으므로
    싸이클의 노드를 **아예 만나지 못한다**. 참고로 이런 성질을 이용해서 아예
    싸이클만 남긴 다음 SCC를 수집하는 방법도 있다.
 2. 위상 정렬이 존재한다면, 알고리즘이 in-degree가 0인 노드부터 방문하도록
    동작하기 때문에 항상 **위상 정렬의 순서대로** 그래프를 탐색하게 된다.
    바꿔말하면 정렬 결과를 뒤집지 않아도 된다.


## Toplogical Ordering with DFS

 DFS로도 위상 정렬을 할 수 있는데, 이때는 다음과 같은 싸이클 조건을 이용해서
 싸이클인지 아닌지도 같이 판별할 수 있다.

| | `visiting = False` | `visiting = True` |
| --- | --- | --- |
| `visited = False` | 아직 방문하지 않음 | **싸이클** |
| `visited = True` | 불가능한 경우 | 탐색이 끝남 |


 DFS에서 노드에 대한 방문을 **완료** 했다는 의미는 즉 이 친구는 Topological
 Ordering 에서 제일 나중에 방문해야 한다는 뜻이다. 따라서 방문을 완료한 순서대로
 리스트든 큐든 스택이든 차례로 넣으면 이게 곧 거꾸로 된 Topological Ordering
 이다. 그러므로,
  - 간선 방향을 거꾸로한 그래프 (이걸 Transposed Graph 라고 하더라) 를 따로
    만들거나,
  - 리턴하기 직전에 뒤집어주면 된다.

``` python
class Graph:
    def __init__(self, n):
        self.node_map = defaultdict(set)
        self.node_set = set(range(n))  # edge가 없는 노드가 있을 수 있음

    def add_edge(self, src, snk):
        self.node_set.add(src)
        self.node_set.add(snk)
        sef.node_map[src].add(snk)

    def topological_ordering(self):
        visiting = set()
        visited = set()
        order = []

        def dfs(node):
            if node in visited:  # node_set 이 entry 이므로 진입하자마자 visited 체크를 해줘야 한다.
                return

            visiting.add(node)
            for succ in self.node_map[node]:
                if succ in visiting:  # 정확히 싸이클 케이스
                    raise TypeError("has cycle")
                if succ not in visited:  # 아직 방문 완료가 아닐 때에만 추가로 탐색한다
                    dfs(succ)

            # node 에 대한 방문을 완료했으므로, visiting/visited 처리를 완료하고 order에 넣는다.
            visiting.remove(node)
            visited.add(node)
            order.append(node)

        try:
            for node in self.node_set:
                dfs(node)
        except TypeError:
            return []

        order.reverse()
        return order
```


## 참고) Floyd's Cycle Finding Algorithm, or The Tortoise and The Hare Algorithm

 단순히 싸이클의 유무만 판별하기 위한 유명한 알고리즘이다. 시간 복잡도는
 O(n)으로 동일하지만 공간 복잡도가 O(1)인 알고리즘이다.

 플로이드의 이 알고리즘의 다른 이름은 거북이와 토끼 알고리즘이다. 속도가 두 배
 차이나는 포인터 두 개를 이용해서 리스트를 동시에 탐색하기 때문에 이런 이름이
 붙었다. 알고리즘은 다음과 같다. 거북이는 한번에 1개씩, 토끼는 한번에 2개씩
 리스트를 탐색한다. 만약 싸이클이 존재한다면, 거북이와 토끼는 **반드시** 만나게
 된다. 싸이클이 없으면 토끼가 먼저 리스트의 끝에 도달한다. 깔끔하게 구현할 수
 있다.

 여기서 궁금한 점은 싸이클이 있을 때 왜 거북이와 토끼는 항상 반드시 만날까? 하는
 점이다. 이걸 증명해보자.
 ([참조](https://www.quora.com/How-do-I-prove-that-the-tortoise-and-hare-in-Floyd-s-cycle-detection-algorithm-definitely-meet-if-a-cycle-exists-How-do-I-determine-the-starting-point-of-a-cycle-in-a-linked-list))

 싸이클이 없는 경우는 의미 없으니, 싸이클이 있는 경우만 고려하자. 거북이가
 엉금엉금 기어서 싸이클의 시작점에 진입하게 되면, 이제 거북이는 그 싸이클을 계속
 돌게 된다. 토끼는 이미 거북이보다 두 배 빠른 속도로 싸이클에 진입해서 뛰고
 있다. 관건은 그래서 이 둘이 항상 만나는 지점이 있는지?, 있다면 어디서 만나는지?
 이다.

 싸이클에 진입하기 까지의 경로 길이를 `x`, 싸이클의 총 길이를 `L`이라고 하자.
 그리고 만나는 지점이 있다고 가정하면 이 지점을 기준으로 싸이클을 쪼갤 수
 있는데, 이를 `L = y + z`라고 하자. 그러면 거북이와 토끼가 만났을 때 거북이와
 토끼가 각각 움직인 총 거리는 다음과 같다:
 - 거북이: `x + y + T*L` (`T`: 거북이가 싸이클을 돈 총 횟수)
 - 토끼: `x + y + H*L`(`H`: 토끼가 싸이클을 돈 총 횟수)

 토끼가 거북이보다 두 배 빠르게 움직이기 때문에, 아래 등식이 성립한다:

```
      (x + y + T*L) / 2 = (x + y + H*L)
<-->  x + y = L *(T - 2H)
```

 이때 `(T - 2H)`를 어떤 상수 `k (>= 0)`라고 해보자. 그러면 `x + y = K*L`이
 성립하고, 따라서 `x = K*L - y`가 된다. 이 말은 곧 거북이랑 토끼가 두 배
 차이나는 속도로 싸이클이 있는 리스트에서 출발하면, *거북이가 딱 싸이클에 진입할
 때* 둘이 만난다는 뜻이다.
