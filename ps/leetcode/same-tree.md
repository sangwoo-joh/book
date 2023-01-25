---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Same Tree
---

# [Same Tree](https://leetcode.com/problems/same-tree/)

 주어진 두 개의 바이너리 트리가 서로 같은지 아닌지를 판단하는 함수를
 만들어보자.

 두 바이너리 트리가 같다는 것은 (1) 트리의 구조가 같아야 하며 (2) 같은
 위치의 노드는 같은 값을 가져야 한다.

## O(N)

 두 트리의 노드에 대해서 다음 경우를 판단하면 된다.

  - 둘 다 null 이면 같다.
  - 둘 중 하나만 null이면 다르다.
  - 두 개의 값이 같으면 같다.
  - 이후 양 쪽 자식 노드에 대해서 똑같은걸 계속 체크한다.

 그리고 이 모든 결과값은 `and` 연산으로 묶여야 한다.

```python
def isSameTree(p, q):
    def traverse(nodep, nodeq):
        if not nodep and not nodeq:
            return True
        if not nodep or not nodeq:
            return False
        return (nodep.val == nodeq.val) and traverse(nodep.left, nodeq.left) and traverse(nodep.right, nodeq.right)

    return traverse(p, q)
```
