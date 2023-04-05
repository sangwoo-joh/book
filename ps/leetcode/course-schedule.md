---
layout: page
tags: [problem-solving, leetcode, python, graph]
title: Course Schedule
---

# [Course Schedule](https://leetcode.com/problems/course-schedule/)

 총 `numCourses` 개의 수업을 들어야 한다. 배열 `prerequisites`이
 주어지는데 `prerequisites[i] = (ai, bi)`는 수업 `bi`를 듣기 전에
 **반드시** 들어야 하는 선행 과목 `ai`를 나타낸다. 예를 들어 `(0, 1)`
 튜플은 수업 `0`을 들어야만 수업 `1`을 들을 수 있다는 뜻이다.

 수업을 다 끝낼 수 있는지를 확인하자.

 수업의 개수는 1~100,000 이고, 입력으로 들어오는 선행 과목은 0~5,000
 사이이다. 선행 과목 정보의 쌍은 모두 `[0, numCourses)` 범위의
 값이다. 모든 선행 과목 정보 쌍은 유니크하다.

## 위상 정렬

 샘플 케이스를 보면서 감을 잡자.

```python
numCourses = 2
prerequisites = [(1,0)]
```

 위의 경우, `1 -> 0` 순으로 수업을 들으면 수업을 모두 끝마칠 수 있다.

```python
numCourses = 2
prerequisites = [(1,0), (0,1)]
```

 위의 경우, `1 -> 0`과 `0 -> 1`을 동시에 만족시키는 것은 불가능하기
 때문에, 수업을 모두 들을 수 없다.

---

 즉, 이 문제는 그래프와 관련이 있다. `numCourses`는 그래프의 노드
 수이고, `prerequisites`는 그래프의 엣지를 나타낸다. 이로부터 그래프를
 그렸을 때, **싸이클**이 있다면, 어떤 수업을 듣기 위해서 선행해야 하는
 과목이 무한 루프를 이루므로 수업을 끝마치는 것(=모든 노드를 방문하는
 것)이 불가능하다. 따라서, 이 문제는 [그래프에서 싸이클을 찾는
 방법](../../theory/topological-ordering)을 적용하면 된다.

 그래프 탐색은 보통 방문 여부를 배열이나 집합으로 기록하면서
 진행된다. 만약 모든 엣지를 따라 나가다가 이전에 방문한 노드를 또
 방문하게 되었다면, 이는 싸이클이 있는 것이다.

 그 외의 엣지 케이스는 없을까? 만약 선행 과목 정보에 아무것도 없으면
 어떻게 될까? 이때는 어떤 과목을 듣기 위해서 필수적으로 들어야 할 게
 아무것도 없으므로 그냥 아무거나 들으면 된다. 즉, 위의 싸이클만
 확인하면 된다.

 파이썬에서 그래프를 표현하기 위한 가장 쉬운 방법은 그래프를 **집합의
 딕셔너리**로 만드는 것이다. 즉, 말하자면 엣지 정보만 담은 일종의
 Adjacency List라고 볼 수 있다. Matrix로 표현하는 것도 가능하지만
 파이썬은 이게 훨씬 편하다. 이때 한 가지 주의할 점은
 `defaultdict(set)`으로 구현하는 것보다는, 전체 노드 정보를 알고
 있다면 `{node: set() for node ...}`로 초기화하는 것이 좋다는
 점이다. `defaultdict(set)`으로 만든 그래프 딕셔너리는 원소가 없는
 `(source, sink)` 쌍을 무지성으로 넣기에는 편하지만, 그래프 자체에다가
 `for` 반복문을 아무 생각없이 돌려버리면 `dictionary size changed
 during iteration` 예외가 발생한다. 왜냐하면, 아무런 엣지도 없는
 노드를 키 값으로 접근하는 순간 `KeyError` 예외가 발생하게 되고,
 `defaultdict`의 구현에 따라 `__missing__`이 호출되면서 해당 키 값에
 `set()`을 추가하게 되는데, 이렇게 되면 예외 메시지가 뜻하는 것처럼
 딕셔너리 사이즈가 변하기 때문이다.

 싸이클을 찾기 위한 탐색은 DFS가 좋다. BFS로도 할 수 있는데, 구현이
 까다롭다.

```python
def canFinish(numCourses, prerequisites):
    graph = {node: set() for node in range(numCourses)}
    for (src, snk) in prerequisites:
        graph[src].add(snk)

    visiting = set()
    visited = set()
    def dfs(node):
        nonlocal visited
        nonlocal visiting
        if node in visited:
            return
        visiting.add(node)
        for sink in graph[node]:
            if sink in visiting:
                raise TypeError("Cycle detected")
            if sink not in visited:
                dfs(sink)
        visiting.remove(node)
        visited.add(node)

    try:
        for node in graph:
            dfs(node)
    except TypeError:
        return False

    return True
```

 - 정석대로 `visiting`과 `visited` 집합과 DFS를 이용해서 그래프에서의
   싸이클 체크를 구현하였다. 싸이클이 발견되면 `TypeError`를 던지도록
   했다.

---

 풀고나서 파이썬 라이브러리를 뒤져봤더니, 3.10 버전부터는 아예
 [`graphlib`](https://docs.python.org/3/library/graphlib.html) 이라는,
 이터러블 객체의 딕셔너리를 그래프로 입력받아서 위상 정렬을 할 수 있는
 라이브러리가 추가된 것을 확인할 수 있었다. 사용법은 대충 그래프를
 위와 같은 방법으로 만든 다음 `graphlib.TopologicalSorter(graph)`에다
 넘기고 `static_order()`를 호출해서 위상 정렬을 진행하는 것인데, 이
 문제처럼 단순히 싸이클 유무만 판단하고 싶을 때에는 그냥 `prepare()`를
 호출하면 된다. 그리고 구현을 잘 해놔서 `defaultdict(set)`을 그래프로
 사용해도 잘 동작한다.

```python
import graphlib
from collections import defaultdict
def canFinish(numCourses, prerequisites):
    graph = defaultdict(set)
    for (src, snk) in prerequisites:
        graph[src].add(snk)

    try:
        graphlib.TopologicalSorter(graph).prepare()
    except graphlib.CycleError:
        return False
    return True
```

 - 문서에 따르면 `TopologicalSorter().static_order()`가 동작하는 도중
   싸이클을 발견하면 `CycleError`를 던지고, 실제로 `prepare()`를
   호출하는 코드와 동일한 의미라고 하는데, 버그가 있는 것인지
   리트코드에서 `static_order()`를 호출해서 제출하면 싸이클이 있는
   테스트 케이스를 통과하지 못한다. 그러니 이정도 구현은 그냥
   라이브러리의 힘을 빌리지말고 직접 구현하는 것이 더 나을 것 같다.
