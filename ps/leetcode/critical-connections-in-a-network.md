---
layout: page
tags: [problem-solving, leetcode, python, graph, cycle]
title: Critical Connections in a Network
---

# [Critical Connections in a Network](https://leetcode.com/problems/critical-connections-in-a-network/)
 `n`개의 서버가 있고 `0`부터 `n-1`까지 번호가 매겨져있다. 서버끼리는
 연결되어 있을 수 있는데 이 정보가 `connections`에 담겨 있고
 `connections[i] = (a, b)` 이면 `a`서버와 `b`서버가 연결되어 있다는
 의미이다. 서버끼리 직접 연결되든 간접적으로 연결되든 네트워크를 통해
 연결될 수 있다.

 서버 간 연결 중에서, 만약 연결이 끊긴다면 다른 어떤 서버에 더 이상
 연결할 수 없게 되는 연결을 *Critical Connection*이라고 한다.

 네트워크 정보가 주어졌을 때 네트워크 안의 모든 Critical Connection을
 구하자. 어떤 순서든 상관없다.

## 문제의 이해
 문제만 읽어선 이게 대체 뭔 소리인가 싶었다. 이런건 예시를 봐야 한다.

 다음 그림(?)을 보자.

```python
0 ---- 1 --- 3
 \    /
  \  /
    2
```

 점점 아스키 아트가 늘어가는 기분이다. 아무튼 위와 같은 네트워크가
 주어졌을 때, 크리티컬 커넥션은 어디일까? 잘 보면 `(1, 3)`을
 끊어버리면 `3`은 그 어디와도 연결될 수 없게 된다. 그럼 대체 이 연결은
 뭘까? 그래프에 익숙하다면 `0`, `1`, `2`는 싸이클을 형성하고 있다는
 것을 알 수 있다.

 즉, 이 문제는 주어진 그래프의 모든 엣지들 중에서, **싸이클이 아닌**
 엣지를 찾는 문제로 환원할 수 있다.

## 싸이클 찾기
 그래프의 싸이클은 DFS와 연관이 깊다. 그런데 보통은 `visited`에 추가로
 `visiting`을 둬서, 싸이클의 존재 여부를 판단하는 문제가
 대부분이었다. 여기서는 **모든** 싸이클을 찾아야 하는데 어떻게
 해야할까?

 싸이클을 좀더 유식한 말로는 SCC(Strongly Connected Components)라고
 부르기도 한다. 정확한 수학적인 정의는 유향/무향 그래프에 따라 좀 다른
 것 같긴 한데.. 암튼 여기서는 어차피 무향 그래프니까 같은 거라고
 생각하자. SCC 안에 있는 모든 노드끼리는 서로 직/간접적으로 닿을 수
 있다(Reachable). 따라서, SCC를 구하는 알고리즘을 조금 변형하면,
 우리가 원하는 "SCC가 **아닌**" 엣지만 판변할 수 있다.

## 타잔 알고리즘 변형
 SCC를 구하는 알고리즘 중에는 그 유명한 [타잔의
 알고리즘](https://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm)이
 있다. 여기서는 이걸 조금 변경해서 문제를 풀어보려고 한다.

 기본은 DFS다. 단, `visited`나 `visiting`을 기록하진 않고, 노드의
 *랭크*를 기록한다고 생각하자. 여기서 랭크는 방문한 순서 정도로
 이해하면 된다.

 위의 그래프를 다시 가져와 봤다.

```python
0 ---- 1 --- 3
 \    /
  \  /
    2
```

 일단 그래프는 특별히 *루트*라고 불릴만 한 게 없으므로, 어떤
 노드에서든 DFS를 시작할 수 있다. 여기서는 `1`에서 시작한다고
 해보자. 랭크는 `0`부터 시작한다. 일단 `1`에는 랭크가 없는 상태이므로,
 `0`을 랭크로 갖게 된다.

```python
0 ---- 1(0) --- 3
 \    /
  \  /
    2
```

 다음으로 노드 `0`을 방문하게 되었다. 랭크가 없으므로, 이전 랭크보다
 `1` 증가한 `1`이 랭크가 된다.


```python
0(1) ---- 1(0) --- 3
 \        /
  \      /
      2
```

 다음으로 방문할 노드를 고를 때, 한 가지 원칙이 있다: **부모** 노드는
 방문하지 않는다. 즉, `0`을 방문하기 이전 부모 노드인 `1`은 방문하지
 않는다. 따라서 `0` 다음 방문할 노드는 `2`만 남았다. 역시 `1` 증가한
 `2`를 랭크로 업데이트하게 된다.

```python
0(1) ---- 1(0) --- 3
 \        /
  \      /
     2(2)
```

 다음으로 방문할 노드는 `1`밖에 없다. 그런데 여기서 싸이클이 발생하게
 된다! 어떻게 아냐고? 노드 `1`에 **이미 랭크가 있고**, 그 랭크가 지금
 노드의 랭크인 `2`보다 **작거나 같기** 때문이다. 즉, 우리는 항상 다음
 노드를 방문할 때마다 랭크를 증가시키기만 했는데, 랭크가 역전되었다는
 것은 이미 이전에 방문한 노드라는 뜻이다.

 만약 그냥 싸이클이 있는지만 찾는거라면 이쯤에서 종료해도
 된다. 익셉션을 날리든 리턴을 해버리든 하면 만사 오케이다. 하지만
 여기서는 **모든** SCC를 찾아야 하기 때문에, 여기서 끝내면 안되고 그
 다음 SCC도 찾아야 한다. 어떻게 해야할까?

 DFS를 재귀적으로 구현하면, 다음 노드를 방문 후에 다시 돌아온다는
 사실을 활용할 수 있다. 싸이클을 찾게 되면 랭크가 역전하게 되고, 이
 역전된 랭크가 곧 싸이클 안에서의 랭크 최소값이 된다. 이 최소값을 재귀
 호출 완료할 때 리턴하면, 각 노드의 랭크와 이 최소 랭크를 비교해서
 "내가 지금 싸이클에 있는가?"를 알 수 있을 것이다. 즉, 아래 그림처럼,


```python
0(1) ---- 1(0) --- 3(3)
 \        /
0 \      / 0
     2(2)
```

 노드 `1` 방문 -> 노드 `0` 방문 -> 노드 `2` 방문 -> 노드 `0`을 다시
 방문하게 되면서 싸이클임을 알게 되고, 최소 랭크인 `0`을 리턴 -> `2`의
 랭크인 `2`와 비교해서 더 작으므로 싸이클이고, 다시 `0`을 리턴 ->
 `0`의 랭크인 `1`보다 작으므로 싸이클이고, 다시 `0`을 리턴 -> `1`의
 랭크인 `0`과 같으므로 싸이클이고, 다음 탐색 계속 -> ...

 이런 느낌이 된다. 이를 구현해보자.


```python
from collections import defaultdict

def critical_connections(n, connections):
    graph = defaultdict(set)
    edges = set()
    for src, snk in connections:
        graph[src].add(snk)
        graph[snk].add(src)
        edges.add((min(src, snk), max(src, snk)))

    ranks = [None] * n
    def dfs(node, r):
        if ranks[node]:
            return ranks[node]

        ranks[node] = r

        min_rank = r + 1
        for neighbor in graph[node]:
            # skip parent
            if ranks[neighbor] and ranks[neighbor] == r - 1:
                continue

            rr = dfs(neighbor, r + 1)
            if rr <= r:
                # if current rank is less than or equals to recursive rank,
                # the edge (node, neighbor) must be a part of scc
                edges.remove((min(node, neighbor), max(node, neighbor)))

            # update min_rank
            min_rank = min(min_rank, rr)
        # if you want to group all SCC, uncomment below:
        # ranks[node] = min_rank
        return min_rank

    dfs(0, 0)
    return edges
```
 - 그래프를 나타내기 위해서 `defaultdict(set)`을 사용했다. OCaml로
   PS할 때에도 자주 쓰던 테크닉이다. 그래프는 Set의 Hash Table이다.
 - 여기서는 SCC에 속하지 않는 *엣지*를 알아야 하기 때문에, 그래프의
   모든 엣지를 `edges`에 담아둔다. `min`, `max`를 이용해서
   normalize하는 것을 잊지 말자.
 - 노드의 랭크를 초기화할 때 `[None] * n`으로 했다. 리스트 안에 들어간
   값이 상수라서 다행히 업데이트가 전파되진 않는다. 만약 `[[]] * n`이
   필요한 경우였다면 모든 업데이트가 공유되어 버리니 주의하자.
 - DFS의 base case가 달라졌다. 원래는 `visited` 체크를 해야하지만,
   여기서는 단순히 "이미 계산한 랭크가 있나?" -> "있다면 그걸
   리턴하자"가 된다.
 - `r`은 지금 방문하는 노드 `node`의 랭크이고, 그 다음 방문할 랭크의
   최소 랭크 후보는 `r+1`이다.
 - 바로 직전에 방문한 부모 노드를 확인하는 로직을 주의하자. 일단
   계산한 랭크가 있어야 되고 (`ranks[neighbor]`), 이 값이 지금
   랭크보다 1 작아야 한다(`ranks[neighbor] == r - 1`).
 - 부모가 아니라면, DFS 탐색을 해서 이른바 Recursive Rank를
   계산한다. 이 값이 지금 랭크보다 **작거나 같으면**, 지금 탐색 중인
   엣지는 싸이클에 속한다. 따라서 전체 엣지에서 삭제해준다.
 - 이 DFS는 최종적으로 **최소 랭크**를 리턴해야 하므로, `min_rank`를
   업데이트해주고 이를 리턴한다.

 처음에는 `ranks`를 전부 `min_rank`로 업데이트 해야 하지 않나? 라고
 생각했는데, 여기서는 싸이클이 **아닌** 엣지를 구하는게 목표라서 굳이
 그럴 필요가 없었다. 만약 다른 문제에서, 예를 들어 모든 SCC를 구하라
 하는 문제가 나온다면, `min_rank`를 리턴하기 직전에 `ranks[node] =
 min_rank`로 적절히 업데이트 해주고, `ranks` 전체를 훑으면서 같은
 랭크를 가진 노드끼리 그룹화하면 된다.
