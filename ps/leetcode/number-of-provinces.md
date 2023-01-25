---
layout: page
tags: [problem-solving, leetcode, python, graph]
title: Number of Provinces
---

# [Number of Provinces](https://leetcode.com/problems/number-of-provinces/)
 주(Province)의 개수를 세는 문제이다. `n` 개의 도시가 있는데 도시끼리
 연결되어 있기도 하고 아니기도 하다. **주**는 직접/간접적으로 연결된
 도시의 그룹이다. `a`랑 `b`가 연결되어 있으면 이건 직접적으로 연결된
 거고, `b`랑 `c`가 연결되어 있다면 `a`랑 `c`는 간접적으로 연결된 거다.

 `isConnected[i][j]`가 주어지고 이게 1이면 i 도시랑 j 도시가 연결된
 거다. 도시의 개수가 `n`개 이므로 `n` x `n` 배열이다.

## DFS
 전형적인 그래프 순회 문제이다. 예전 섬의 개수 구하는 거랑 비슷하게,
 첫 방문하는 도시에 들어가자마자 주의 개수를 증가시키면서 연결된 모든
 도시를 다 방문해버리면 된다.

 `isConnected`가 항상 `n` x `n`이 보장되기 때문에 도시의 번호를 구하기
 쉽다. 그리고 이 정보는 무향 그래프이기 때문에 양방향을 다 고려해야
 한다.

```python
def numProvinces(isConnected):
    n = len(isConnected)

    visited = set()
    def dfs(c1, c2):
        if (c1, c2) in visited or (c2, c1) in visited:
            return

        visited.add((c1, c2))
        visited.add((c2, c1))

        for cn in range(n):
            if isConnected[c1][cn] and (c1, cn) not in visited:
                dfs(c1, cn)
            if isConnected[c2][cn] and (c2, cn) not in visited:
                dfs(c2, cn)

    num = 0
    for c1 in range(n):
        for c2 in range(n):
            if isConnected[c1][c2] and (c1, c2) not in visited:
                num += 1
                dfs(c1, c2)

    return num
```

 - 양방향을 모두 고려해서 `(c1, c2)`와 `(c2, c1)`을 다 세어주고 있다.
 - 나머지는 섬의 개수 세는 것과 거의 유사하다.
