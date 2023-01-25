---
layout: page
tags: [problem-solving, leetcode, python, graph]
title: Minimum Genetic Mutation
---

# [Minimum Genetic Mutation](https://leetcode.com/problems/minimum-genetic-mutation/)

 유전자 스트링은 8개의 문자열로 나타낼 수 있고 각각의 글자는 `A`, `C`,
 `G`, `T` 중 하나이다.

 한 유전자 스트링 `start`에서 다른 유전자 스트링 `end`로 돌연변이가
 일어날 수 있는지 확인하려고 한다. 한번의 돌연변이는 유전자 스트링에서
 하나의 글자가 바뀌는 것을 뜻한다. 예를 들어, `AACCGGTT -->
 AACCGGTA`는 한 번의 돌연변이이다.

 유전자 은행 `bank`도 주어진다. 여기에는 모든 유효한 유전자 돌연변이가
 담겨있다. 어떤 유전자 스트링이 유효하려면 반드시 `bank`안에 들어있는
 유전자여야 한다.

 두 개의 유전자 스트링 `start`, `end`와 유전자 은행 `bank`가 주어졌을
 때, `start`가 `end`로 바뀌기 위해서 필요한 최소한의 돌연변이 횟수를
 계산하자. 불가능하다면 `-1`을 리턴하자.

 참고로 `start`는 항상 유효한 것으로 간주되기 때문에 `bank`에 없을수도
 있다.

 - `start`, `end`의 길이는 8이다.
 - `bank`의 크기는 0~10
 - `bank`에 있는 유전자의 길이는 8
 - 모든 유전자 스트링은 `A`, `C`, `G`, `T` 글자만 담고 있음이
   보장된다.

## 상태 공간 탐색하기

 - 어떤 유전자 스트링이 가능한 모든 돌연변이 수를 생각해보자. 하나의
   글자는 `A`, `C`, `G`, `T` 중 원래 글자가 아닌 3가지의 글자로 변이가
   가능하고 유전자 스트링의 길이는 항상 8이므로 $$ 3^8 = 6561 $$ 개의
   다음 상태가 가능하다.
 - 하지만 추가로 **유효한** 돌연변이가 되려면 항상 유전자 은행 안에
   속한 돌연변이로 변이해야 하므로 생각보다는 상태공간이 작다. 은행의
   크기가 최대 10이므로 가능한 돌연변이 횟수도 최대 10이다.
 - 일종의 상태 공간을 탐색하는 것이므로 BFS가 적절하다. 목적지에 도달
   가능한 최소 경로를 구하는 문제와도 동치이므로 더더욱 BFS를 활용해야
   한다.
 - BFS를 위해 큐에 상태(노드)를 넣을 때, 탐색할 상태 뿐 아니라 추가로
   지금까지 탐색한 경로의 수 (= 돌연변이 횟수)도 함께 기록한다. 이것이
   곧 문제가 요구하는 최소의 돌연변이 횟수가 된다.
 - BFS이므로 방문 체크를 해야한다. 그렇지 않으면 무한루프에 빠져서
   답을 계산할 수 없는 경우가 생긴다. 한번의 돌연변이에서 가능한
   6,561개의 다음 상태 중 은행에 있는 상태로만 변이할 수 있으므로, 한
   번 방문한 상태를 또 방문하게 되면 그래프에서 루프가 생기는 것과
   동일하다. 따라서 이 경우는 애초에 불가능하다.

```python
def minMutation(start, end, bank):
    from collections import deque
    q = deque()
    q.append((start, 0))
    bank_set = set(bank)
    visited = set()
    while q:
        cur, turn = q.popleft()
        if cur == end:
            return turn

        for i in range(8):
            for c in ('A', 'C', 'G', 'T'):
                if c == cur[i]:
                    continue
                cand = cur[:i] + c + cur[i+1:]
                if cand not in visited and cand in bank_set:
                    visited.add(cand)
                    q.append((cand, turn + 1))
    return -1
```
