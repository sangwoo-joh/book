---
layout: page
tags: [problem-solving, leetcode, python, graph]
title: Clone Graph
---

# [Clone Graph](https://leetcode.com/problems/clone-graph/)

 연결 무향 그래프를 **깊은 복사**하자.

## 탐색하면서 기록하기

 일반적인 그래프 탐색을 생각해보자. DFS든 BFS든 보통 방문 여부를
 체크하기 위해서 visited 배열(집합)을 활용한다. 여기서는 이 visited를
 확장해서, 노드의 방문 여부 뿐만 아니라 해당 노드의 **복사 노드**를
 담고 있도록 하고, 모든 복사 노드를 연결하면 된다.

 혹시나 스택이 너무 커질 위험을 피하기 위해서 여기서는 BFS로
 구현해보았다.

```python
"""
class Node:
    def __init__(self, val=0, neighbors=None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []
"""

from collections import deque
def cloneGraph(root):
    if not root:
        return None

    q = deque()
    q.append(root)
    visited = {root: Node(root.val)}

    while q:
        node = q.popleft()
        for neighbor in node.neighbors:
            if neighbor not in visited:
                visited[neighbor] = Node(neighbor.val)
                q.append(neighbor)
            # deep copy
            visited[node].neighbors.append(visited[neighbor])

    return visited[root]
```

 - `visited`를 해시 테이블로 만들고 해당 노드와 같은 값의 새로운
   노드를 담도록 한다. 생성자를 보면 알겠지만 자식 노드 없이 만들어도
   빈 리스트가 들어간다.
 - 큐에서 노드를 하나씩 꺼내서 BFS를 하는 로직은 동일하다. 주의할 점은
   두 가지 인데, 하나는 아직 방문하지 않은 노드는 **깊은 복사**를
   해줘야 한다는 점이고, 다른 하나는 모든 복사한 자식 노드를 올바르게
   연결해줘야 한다는 점이다. 여기서 큐에서 꺼내어 방문 체크가 끝난
   노드는 **항상 해시 테이블에 짝이 되는 복사 노드가 있는** 것이
   보장된다는 점을 이용한다.

### 참조) 파이썬의 해싱 함수

 참고로 파이썬에는 디폴트 해시 함수가 있는데, 모든 클래스는 `object`를
 암묵적으로 상속 받기 때문에 노드 클래스에서 특별히 해시 함수를
 지정해주지 않아도 곧바로 해시 테이블의 키로 사용할 수 있다.

 그리고 이 해시 함수는 다음과 같이 정의된다:

```python
class Node:
    def __init__(self, val=0, neighbors=None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []

n = Node( ... )
hash(n) == (id(n) // 16)
```

 즉, 객체의 아이디 값을 16으로 나눈 값을 쓴다. 그리고 CPython에서
 객체의 아이덴티티를 계산하는 `id` 함수는 객체의 메모리 주소와
 같다. 즉, 기본 해시 함수는 메모리 주소를 쓴다고 봐도 무방하다.
