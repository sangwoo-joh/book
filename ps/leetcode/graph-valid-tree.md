---
layout: page
tags: [problem-solving, leetcode, python, graph, tree, cycle, disjoint-set]
title: Graph Valid Tree
---

# [Graph Valid Tree](https://leetcode.com/problems/graph-valid-tree/)
 `0`부터 `n-1`까지 레이블링 된 `n` 개의 노드가 있는 그래프가
 있다. 엣지 정보를 담은 `edges` 가 주어지고, `edges[i] = (a_i, b_i)`는
 노드 `a_i`와 `b_i` 사이에 무향 엣지가 있음을 나타낸다.

 `n`과 `edges`가 주어졌을 때, 이 그래프가 유효한 트리를 만들어내는지를
 확인하자.


## Valid Tree?
 문제를 정확하게 이해하기 위해서 정의를 살펴볼 필요가 있다. *유효한
 트리*의 정의가 뭘까? 위키피디아를 찾아보면 여러가지가 있는데,
 눈여겨볼 것은 다음과 같다:
 - 트리는 무향 그래프이다.
 - 트리는 [연결
   그래프](https://en.wikipedia.org/wiki/Connectivity_(graph_theory)#Connected_vertices_and_graphs)이다. 즉,
   트리의 **모든** 노드는 연결되어 있다.
 - 트리는 싸이클이 없다.

 여기서 무향 그래프를 제외한 나머지를 확인하는 것이 바로 이 문제의
 핵심이 된다. 이 중에서 싸이클을 판단하는 것은 잠깐 뒤로 미뤄두고,
 *연결 그래프*의 의미를 좀더 살펴보자. 어떤 그래프가 연결 그래프라면
 이건 대체 무엇을 뜻할까? 모든 노드가 연결되어 있다는 말은 곧 모든
 노드 사이에는 경로(path)가 있다는 뜻이고, 이건 다르게 말해서 `n`개의
 노드를 갖는 그래프가 트리라면 여기에는 **정확하게 `n-1`개의 엣지**가
 있다는 것을 뜻한다. `n-1`개보다 적으면 뭔가 연결 안된 노드가 있는
 거고, `n-1`개 보다 많으면 *무조건* 싸이클이 있다는 것이다. 그러므로
 일단 이것부터 제외할 수 있다.

## Disjoint Set
 그럼 싸이클은 어떻게 찾으면 될까? [Condition of
 Cycle](/algorithm/tips#condition-of-cycle)에서 했던 것처럼,
 `visited`와 `visiting`을 유지하면서 DFS를 돌리는 것은 어떨까?
 아쉽게도 이 방법은 *유향* 그래프에서만 먹힌다. 우리는 트리, 즉 무향
 그래프를 갖고 있기 때문에 일반적인 그래프 순회로 판단하기는 조금
 까다롭다. 추가로 부모 노드를 쌓아가면서 확인하는 방법이 가능하지만,
 여기서는 다른 방법을 써보자.

 어떤 무향 그래프에 싸이클이 있다는 사실을 어떻게 다르게 표현할 수
 있을까? 다음 싸이클이 있는 엣지를 생각해보자.

```python
edges = [(0, 1), (1, 2), (2, 0)]
```

 첫번째 엣지에서 노드 `0`과 `1`이 연결된다. 두번째에서 노드 `1`과
 `2`가 연결된다. 여기까지오면 `0`, `1`, `2`가 하나로 연결된
 상태다. 여기에 추가로 `2`와 `0`을 연결하는 순간 싸이클이 생긴다.

 다르게 표현하면 이렇다. 먼저 노드 `0`과 `1`이 하나의 집합에
 속한다. 그리고 `(1, 2)`가 들어오면 노드 `2`가 `1`이 속해있던 집합에
 추가된다. 마지막으로 `(2, 0)`을 추가하려는 순간, `2`와 `0`이 이미
 같은 집합에 속해있음을 알게 되고, 이게 곧 싸이클이 된다.

 여기까지 오면 눈치챌 수 있다: 이 문제는 서로소 집합으로 풀 수
 있다. 즉, 무향 그래프에서, 모든 엣지 정보를 서로소 집합에 추가하면서,
 만약 `union` 연산을 할 때 두 집합이 이미 같은 집합에 속하면 (= 두
 집합의 대표 원소가 같으면), 싸이클이 발생한 것이다.

 따라서 구현할 알고리즘의 아이디어는 다음과 같다.
 1. 연결 그래프의 조건인 "엣지 개수가 `n-1`개인가?"를 먼저 확인한다.
 2. 모든 엣지의 노드를 서로소 집합에 추가하면서, 이미 같은 집합에 속해
    있는 경우가 하나라도 발견되면 바로 `False`를 리턴한다.
 3. 위의 1, 2 검사를 모두 통과하면 비로소 `True`를 리턴한다.

 코드는 다음과 같다.

```python
class DisjointSet:
    class IdentityDict(dict):
        def __missing__(self, x):
            self[x] = x
            return x

    def __init__(self):
        self._data = DisjointSet.IdentityDict()

    def find(self, x):
        if x != self._data[x]:
            self._data[x] = self.find(self._data[x])
        return self._data[x]

    def union(self, x, y):
        px, py = self.find(x), self.find(y)

        if px == py:
            # cycle is detected
            raise TypeError

        self._data[px] = py

def is_valid_tree(n, edges):
    if len(edges) != (n - 1):
        return False

    dset = DisjointSet()

    try:
        for src, snk in edges:
            dset.union(src, snk)
    except TypeError:
        return False

    return True
```
 - 연결 그래프 검사를 하고 나면, 사실상 모든 노드에 대해서 이미
   `make_set` 함수를 호출했다고 가정해도 된다. 즉, 모든 노드는 이미
   하나의 서로소 집합(= 스스로가 스스로의 대표원소)을 이룬다. 이걸
   좀더 편하게 하기 위한 트릭으로 `IdentityDict`를 만들었다. `dict`를
   상속받아서 `__missing__` 메소드를 제공하면, `dict[x]`를 할 때
   `KeyError` 예외가 발생한 순간 `__missing__`을 호출해서 디폴트 값을
   처리한다. 종종 쓰이는 테크닉이다.
 - [섬의 개수를 세던
   문제](/leetcode/number-of-islands#optimized-disjoint-set)처럼
   개수를 셀 필요는 없지만, 여기에 쓰인 최적화인 경로 압축은
   적용해뒀다.
 - `union`을 시도할 때 이미 같은 집합을 합치려는 시도가 발견되면
   `TypeError`를 발생시키도록 했다. 그냥 리턴으로 처리해도
   된다. 바깥에서 이걸 호출할 때에만 잘 처리해주면 된다.
