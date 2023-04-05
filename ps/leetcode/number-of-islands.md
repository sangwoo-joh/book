---
layout: page
tags: [problem-solving, leetcode, python, graph, disjoint-set]
title: Number of Islands I, II
last_update: 2023-04-05 09:48:06
---

# [Number of Islands](https://leetcode.com/problems/number-of-islands/)

 m x n 2D 그리드가 지도로 주어진다. `1`은 땅이고 `0`은 물일 때, 섬의
 개수를 세는 문제다.

 여기서 **섬**은 가로/세로로 인접해서 연결된 땅이 물로 둘러 쌓여 있는
 것을 의미하는데, 지도 바깥은 전부 물이라고 가정하면 된다.

## DFS
 전형적인 그래프 탐색 문제다. 파이썬으로 DFS는 특히 쉽게 구현할 수
 있어서 여기서는 DFS로 구현해본다.

 전체 지도를 돌다가 땅을 만나는 순간 섬의 개수를 하나 증가하고, 곧바로
 그 땅으로부터 DFS를 시작해서 모든 땅을 다 *탐색*하면 된다. 이후
 만나는 땅 중에서 이전 땅에서 이미 *탐색* 된 땅은 같은 섬에 속하게
 되고, 탐색 안된 땅은 *다른 섬*이기 때문에 또 DFS를 호출하게 된다.

```python
def numIslands(grid):
    visited = set()
    m, n = len(grid), len(grid[0])
    def dfs(x, y):
        visited.add((x, y))

        for nx, ny in [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]:
            if 0 <= nx < m and 0 <= ny < n:
                if grid[nx][ny] == '1' and (nx, ny) not in visited:
                    dfs(nx, ny)

    num = 0
    for x in range(m):
        for y in range(n):
            if grid[x][y] == '1' and (x, y) not in visited:
                num += 1
                dfs(x, y)

    return num
```

 - 파이썬의 튜플은 해싱 가능하기 때문에 set에 곧바로 넣을 수
   있다. 해당 좌표가 이미 탐색이 끝났는지 여부를 쉽게 체크할 수 있다.
 - 범위 연산을 할 때 `x >= 0 and x < m`과 같이 `&&` 연산을 해도 되지만
   위에서 처럼 Pythonic 하게 적을 수도 있다. 더 잘 읽힌다.
 - 원래 DFS 재귀 함수 안에서 다음 노드를 방문하기 전에 방문 여부
   (visited) 를 체크해주면 된다. 여기서는 바깥에서 추가로 한번 더 방문
   여부를 체크하는데 그 이유는 섬의 개수를 세기 위해서다. 어떤 섬의
   땅에 첫 발을 내딛는 순간 섬의 개수가 하나 증가하고 그 섬에 속한
   모든 땅을 방문한 것으로 기록하기 때문에, 이후 노드 중 이미 방문
   기록된 노드는 이전 DFS 에서 섬으로 카운트 된 땅이다.

## BFS
 BFS로도 구현해보았다. DFS와 마찬가지로 첫 땅을 밟는 순간 섬 개수를
 늘리고, 인접한 모든 땅(섬)을 방문으로 기록한다.

 collections 모듈에 deque가 있으니 이걸 쓰면 된다.

```python
from collections import deque
def numIslands(grid):
    visited = set()
    m, n = len(grid), len(grid[0])

    def bfs(x, y):
        visited.add((x, y))
        q = deque()
        q.append((x, y))

        while q:
            cx, cy = q.popleft()
            for nx, ny in [(cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)]:
                if 0 <= nx < m and 0 <= ny < n and grid[nx][ny] == '1' and (nx, ny) not in visited:
                    visited.add((nx, ny))
                    q.append((nx, ny))

    num = 0
    for x in range(m):
        for y in range(n):
            if grid[x][y] == '1' and (x, y) not in visited:
                bfs(x, y)
                num += 1

    return num
```


# [Number of Islands II](https://leetcode.com/problems/number-of-islands-ii/)
 위 문제를 살짝 비튼 문제다.

 `m x n` 2D 그리드의 *사이즈*가 주어진다. 처음에 **모든** 그리드는
 `0`, 즉 물이다.

 각 단계마다 물을 땅으로 바꾸는 조작(`0 -> 1`)을 할 수 있다. 위치 배열
 `positions`가 입력으로 같이 들어오는데, `positions[i] = (r_i, c_i)`
 이고 `(r_i, c_i)` 위치의 물을 땅으로 바꾼다. 그리고 이 작업은 `i`
 번째 단계에 수행되어야 한다.

 이때, 각 단계마다 조작을 수행한 후의 **땅의 개수**를 구하자. 즉, 답은
 땅의 개수를 담은 리스트가 될 것이다.

 - ` 1 <= m, n, positions.length <= 10^4`


## Disjoint Set or Union Find
 가장 단순한 방법은, 매 단계마다 땅을 추가한 다음 위에서 구현한 *섬의
 개수를 구하는 함수*를 호출해서 정답 리스트에 쌓아 나가면 된다. 단,
 이렇게하면 매 단계마다 `O(n^2)`의 검사가 필요하기 때문에, 아주
 비효율적이다.

 여기서 **서로소 집합**을 떠올릴 수 있어야 한다.

 *섬*은 연결된 땅의 집합을 뜻한다. 이때, 어떤 땅이 두 개 이상의 섬에
 속하는 것은 불가능하다. 즉, 다시 말하면 모든 섬은 **공통 원소(같은
 위치의 땅)가 없다**. 이렇게 상호 배타적인 부분 집합들로 나눠진
 원소들에 대한 정보를 저장/조작하는 자료구조가 바로 서로소 집합이다.

 즉, 이 문제를 풀기 위한 알고리즘을 설명하면 대략 이렇다.
 1. 섬의 정보를 저장하기 위한 서로소 집합을 만든다.
 2. 각 `positions` 마다, 땅을 추가하고, 서로소 집합에 추가한다.
 3. 추가된 땅의 4방향 중 땅이 있는 모든 곳은 *합친다(Union)*.
 4. 그 후에 서로소 집합에 있는 모든 섬의 개수를 기록한다.

 서로소 집합만 떠올리고, 구현한다면, 생각보다 쉽게 풀리는 문제다.

### Optimized Disjoint Set
 [서로소
 집합](https://ko.wikipedia.org/wiki/%EC%84%9C%EB%A1%9C%EC%86%8C_%EC%A7%91%ED%95%A9_%EC%9E%90%EB%A3%8C_%EA%B5%AC%EC%A1%B0)이
 필요하다는 걸 알았으니 구현해보자. 가장 단순하게 구현하는 방법은
 다음과 같이 배열(또는 해시테이블)을 이용해서 각 서로소 집합의 대표
 원소(부모)를 기록하는 방법이다. 일종의 트리라고 볼 수 있다.

```python
function MakeSet(x)
  x.parent := x

function Find(x)
  if x.parent == x
    return x
  else
    return Find(x.parent)

function Union(x, y)
  xRoot := Find(x)
  yRoot := Find(y)
  xRoot.parent := yRoot
```

 위키피디아에 있는 수도 코드를 가져왔다. `MakeSet`은 `x` 하나로
 이루어진 서로소 집합을 만드는 연산이다. `Find`는 `x`가 속한 서로소
 집합의 대표 원소, 즉 앞서 말한 트리의 루트 노드를 찾는
 연산이다. `Union`은 `x`와 `y`를 같은 서로소 집합에 속하게 만드는
 연산이다.

 근데 이렇게 나이브하게 구현하면 트리에서 Skewed Tree가 발생하는 것과
 같은 이치로, 점점 균형이 깨질 것이다. 그러면 각 연산의 복잡도가
 `O(n)`에 수렴한다. 좋지 않다.

 이를 위해 두 가지 최적화 방법이 있는데,
 1. Union by Rank: Rank를 기록해서, `Union` 연산을 할 때 항상 더 작은
    길이의 트리를 더 큰 길이의 트리에 합치는 방법이다.
 2. Path Compression: `Find` 연산을 할 때마다, 모든 속한 원소의 부모를
    하나의 대표 원소를 가리키게 하는 방법이다.

 몇 가지 실험을 해보니까, Union by Rank는 (적어도 파이썬 구현에
 한해서는) 크게 재미를 보지 못했다. 일단 랭크를 저장하기 위해서
 데이터가 추가로 필요하고, 매 연산마다 랭크를 찾아서 비교해야 하기
 때문인 것 같다. 반면 경로 압축은 엄청난 효과를 보았기 때문에 여기서는
 경로 압축만을 적용해서 최적화된 서로소 집합을 만들 것이다.

 아, 그리고 그전에 한 가지 더 필요한 작업이 있다. 위의 수도 코드에서는
 `Find`나 `Union`에 파라미터로 넘어가는 원소들은 항상 그 전에
 `MakeSet`으로 원소 하나 짜리 집합을 만들 필요가 있었다. 그런데
 여기서는 *섬의 개수*를 세는 연산을 효율적으로 하기 위해서,
 `MakeSet`이 호출될 때 개수를 하나 늘리고, `Union` 에서 서로 다른
 서로소 집합끼리 합쳐질 때 개수를 하나 줄인다. 이렇게하면 개수를 셀
 때마다 전체 데이터를 다 훑지 않아도(즉, `Find(x) == x` 검사) 된다.

 이제 여기까지 왔으니 서로소 집합 연산을 위한 클래스를 구현해보자.

```python
class DisjointSet:
    def __init__(self):
        self._data = dict()
        self._count = 0

    def __len__(self):
        return self._count

    def make_set(self, x):
        if x not in self._data:
            self._data[x] = x
            self._count += 1

    def find(self, x):
        if x != self._data[x]:
            self._data[x] = self.find(self._data[x])

        return self._data[x]

    def union(self, x, y):
        parentx, parenty = self.find(x), self.find(y)

        if parentx != parenty:
            # decrease connected counts
            self._count -= 1
            self._data[parentx] = parenty
```

 - 개수를 캐싱하기 위해서 `_count` 변수도 유지한다. `__len__`은 단순히
   이 값을 리턴해서 `O(1)`을 유지한다.
 - `find` 연산을 경로 압축으로 최적화했다. `x`의 부모가 `x`가 아니면
   `x`의 루트까지 타고 올라가서 루트를 부모로 업데이트 한다.
 - `union`은 랭크 최적화는 진행하지 않았다. 대신 합치려는 두 서로소
   집합이 다를 때 개수도 함께 줄인다.

 그러면 이렇게 만든 서로소 집합으로 다음과 같이 문제를 풀 수 있다.

```python
def num_islands_2(m, n, positions):
    answer = []
    dset = DisjointSet()
    lands = set()

    for x, y in positions:
        dset.make_set((x, y))
        lands.add((x, y))

        for nx, ny in ((x+1, y), (x-1, y), (x, y+1), (x, y-1)):
            if (nx, ny) in lands:
                dset.union((x, y), (nx, ny))

        answer.append(len(dset))

    return answer
```
 - 지금까지 땅으로 바뀐 위치를 기록하기 위해서 `lands`를
   만들어뒀다. 이게 필요한 이유는, 현재 단계에서 연산을 한 다음
   4방향을 살필 때 이게 땅인지 아닌지를 빠르게 판단하기 위해서다. `m x
   n` 그리드를 직접 만들어도 된다.
 - 현재 단계의 위치를 땅으로 만든 후 (`dset.make_set`, `lands.add`),
   4방향의 **땅** 위치를 Union 한다. 이때, `lands` 를 기록하고 있기
   때문에 굳이 `0 <= nx < m` 또는 `0 <= ny < n`를 확인할 필요는 없다.
