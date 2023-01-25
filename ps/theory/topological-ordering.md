---
layout: page
tags: [problem-solving, theory, python, graph, cycle]
title: Topological Ordering
---

{: .no_toc }
## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

# Cycle Condition

| | `visiting = False` | `visiting = True` |
| --- | --- | --- |
| `visited = False` | 아직 방문하지 않음 | **싸이클** |
| `visited = True` | 불가능한 경우 | 탐색이 끝남 |

# Topological ordering
 DFS에서 노드에 대한 방문을 **완료** 했다는 의미는 즉 이 친구는
 Topological Ordering 에서 제일 나중에 방문해야 한다는 뜻이다. 따라서
 방문을 완료한 순서대로 리스트든 큐든 스택이든 차례로 넣으면 이게 곧
 거꾸로 된 Topological Ordering 이다. 그러므로,
  - 그래프를 만들 때부터 source와 sink를 거꾸로 한 다음 그냥 리턴하거나,
  - 리턴하기 직전에 뒤집어주면 된다.

``` python
class Graph:
    def __init__(self, n):
        self.node_map = {}
        self.node_set = set(range(n))  # edge가 없는 노드가 있을 수 있음

    def add_edge(self, src, snk):
        self.node_set.add(src)
        self.node_set.add(snk)

        sink_set = self.node_map.get(src, None)
        if sink_set:
            sink_set.add(snk)
        else:
            self.node_map[src] = {snk}

    def topological_ordering(self):
        visiting = set()
        visited = set()
        order = []

        def dfs(node):
            if node in visited:  # node_set 이 entry 이므로 진입하자마자 visited 체크를 해줘야 한다.
                return

            visiting.add(node)
            for succ in self.node_map.get(node, set()):
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

# Floyd's Cycle Finding Algorithm, or The Tortoise and The Hare Algorithm
 단순히 싸이클의 유무만 판별하기 위한 유명한 알고리즘이다. 시간
 복잡도는 O(n)으로 동일하지만 공간 복잡도가 O(1)인 알고리즘이다.

 플로이드의 이 알고리즘의 다른 이름은 거북이와 토끼
 알고리즘이다. 속도가 두 배 차이나는 포인터 두 개를 이용해서 리스트를
 동시에 탐색하기 때문에 이런 이름이 붙었다. 알고리즘은 다음과
 같다. 거북이는 한번에 1개씩, 토끼는 한번에 2개씩 리스트를
 탐색한다. 만약 싸이클이 존재한다면, 거북이와 토끼는 **반드시** 만나게
 된다. 싸이클이 없으면 토끼가 먼저 리스트의 끝에 도달한다. 깔끔하게
 구현할 수 있다.

 여기서 궁금한 점은 싸이클이 있을 때 왜 거북이와 토끼는 항상 반드시
 만날까? 하는 점이다. 이걸 증명해보자. ([참조](
 https://www.quora.com/How-do-I-prove-that-the-tortoise-and-hare-in-Floyd-s-cycle-detection-algorithm-definitely-meet-if-a-cycle-exists-How-do-I-determine-the-starting-point-of-a-cycle-in-a-linked-list))

 싸이클이 없는 경우는 의미 없으니, 싸이클이 있는 경우만
 고려하자. 거북이가 엉금엉금 기어서 싸이클의 시작점에 진입하게 되면,
 이제 거북이는 그 싸이클을 계속 돌게 된다. 토끼는 이미 거북이보다 두
 배 빠른 속도로 싸이클에 진입해서 뛰고 있다. 관건은 그래서 이 둘이
 항상 만나는 지점이 있는지?, 있다면 어디서 만나는지? 이다.

 싸이클에 진입하기 까지의 경로 길이를 `x`, 싸이클의 총 길이를
 `L`이라고 하자. 그리고 만나는 지점이 있다고 가정하면 이 지점을
 기준으로 싸이클을 쪼갤 수 있는데, 이를 `L = y + z`라고 하자. 그러면
 거북이와 토끼가 만났을 때 거북이와 토끼가 각각 움직인 총 거리는
 다음과 같다:
 - 거북이: `x + y + T*L` (`T`: 거북이가 싸이클을 돈 총 횟수)
 - 토끼: `x + y + H*L`(`H`: 토끼가 싸이클을 돈 총 횟수)

 토끼가 거북이보다 두 배 빠르게 움직이기 때문에, 아래 등식이 성립한다:

```
      (x + y + T*L) / 2 = (x + y + H*L)
<-->  x + y = L *(T - 2H)
```

 이때 `(T - 2H)`를 어떤 상수 `k (>= 0)`라고 해보자. 그러면 `x + y =
 K*L`이 성립하고, 따라서 `x = K*L - y`가 된다. 이 말은 곧 거북이랑
 토끼가 두 배 차이나는 속도로 싸이클이 있는 리스트에서 출발하면,
 *거북이가 딱 싸이클에 진입할 때* 둘이 만난다는 뜻이다.
