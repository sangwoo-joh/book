---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Binary Tree Level Order Traversal
---

# [Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/)

 바이너리 트리의 루트 노드가 주어졌을 때, 트리를 레벨 순서로 순회한
 결과를 리턴하자. 레벨 순 순회란 왼쪽에서 오른쪽으로, 레벨(깊이)
 순서로 순회하는 것이다. 결과는 리스트로, 같은 레벨에 있는 값은
 왼쪽에서 오른쪽 순으로 들어가있도록 한다.

 예를 들어 다음과 같은 트리가 있다면,

![tree](https://assets.leetcode.com/uploads/2021/02/19/tree1.jpg)

 레벨 순서로 순회한 결과는 `[[3], [9, 20], [15, 7]]`이 된다.

 노드의 개수는 0~2,000 이고 노드의 값은 -1,000~1,000이다.

## 재귀

 모든 트리의 순회는 루트로부터 시작할 수 밖에 없기 때문에, 레벨은 결국
 루트에서 0으로 시작해서 아래로 내려갈 때마다 1씩 증가하는 정수
 값이라고 생각해도 무방하다.

 같은 레벨일 때에는 왼쪽을 먼저 방문하면 된다.

 순회 결과는 방문한 순서대로 결과를 같은 레벨의 리스트에 추가해야
 하므로, `레벨 -> 방문 목록`을 기록하는 자료구조가 있으면 충분할 것
 같다. 여기서는 파이썬의 딕셔너리, 그 중에서도 `defaultdict`를
 활용하면 첫 방문 시에 null check를 피할 수 있다.

```python
from collections import defaultdict
def levelOrder(root):
    traversal = defaultdict(list)
    def levelorder(node, level):
        if node is None:
            return
        nonlocal traversal
        traversal[level].append(node.val)
        levelorder(node.left, level+1)
        levelorder(node.right, level+1)

    levelorder(root, 0)
    return traversal.values()
```

 - 방문 결과를 `defaultdict`에 쌓는다. 쌓을 곳은 `level`을 인덱스로
   접근한 리스트이다.
 - 방문이 다 끝나고 나면 결과는 딕셔너리 형태로 저장되어 있는데,
   `values()` 함수를 이용하면 키 값이 아닌 값들을 묶어서 리스트로
   반환할 수 있다.

 `values()`에 대해 좀더 정확한 설명을 하자면 이렇다. 일단 `values()`는
 정확하게는 리스트를 리턴하는 게 아니라 [view 객체를
 리턴한다](https://docs.python.org/3/library/stdtypes.html#dict.values). view
 객체는 엔트리의 동적인 뷰를 제공해줘서 원본 딕셔너리가 업데이트되면
 뷰에도 즉각 반영된다. 그 외에는 다 같아서 이건 문제 푸는데 크게
 상관없다.

 중요한 것은 `values()` 결과 리스트에 들어가있는 원소의 **순서**인데,
 파이썬 3.7부터는 딕셔너리에 삽입한 순서를 보장한다. 원래는 3.6
 CPython의 구현 디테일이었는데 3.7부터 표준에 반영된 것 같다.

> Dictionaries preserve insertion order. Note that updating a key does
> not affect the order. Keys added after deletion are inserted at the
> end.

> Changed in version 3.7: Dictionary order is guaranteed to be
> insertion order. This behavior was an implementation detail of
> CPython from 3.6.


 즉, 문제에서 레벨 순으로 트리를 방문한다는 것은 곧 레벨의
 오름차순으로 방문하는 것과 같기 때문에, 딕셔너리가 내부적으로는 해시
 테이블이지만 결국 레벨의 오름차순 방문이 보장되어 `values()`를
 사용해도 무방한 것이다. 만약 순서가 보장되지 않는다면 먼저
 `items()`를 가져와서 `(key, value)` 쌍의 리스트를 만들고, `key`를
 기준으로 정렬하는 과정을 반드시 거쳐야 한다.

## Queue

 트리의 레벨 오더 순회는 본질적으로는 루트로부터 시작한 BFS와
 같다. 따라서 큐를 이용한 BFS로도 구현할 수 있다. 다만 여전히 레벨에서
 방문한 목록은 기록해야 하기 때문에 `defaultdict`에 저장하는 것은
 필요하다.

```python
from collections import deque, defaultdict
def levelOrder(root):
    traversal = defaultdict(list)
    q = deque()
    q.append((0, root))
    while q:
        lv, node = q.popleft()
        if node is None:
            continue
        traversal[lv].append(node.val)
        q.append((lv+1, node.left))
        q.append((lv+1, node.right))
    return traversal.values()
```

 - 큐에 노드를 곧바로 집어넣는 것이 아니라 `(레벨, 노드)` 정보를
   넣는다. 그러면 (1) 레벨 오더 순회가 보장되면서 (2) 현재 레벨을 같이
   알 수 있다.
