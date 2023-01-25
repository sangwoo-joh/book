---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Find Leaves of Binary Tree
---

# [Find Leaves of Binary Tree](https://leetcode.com/problems/find-leaves-of-binary-tree/)

 바이너리 트리의 루트 노드가 주어졌을 때, 다음 결과를 구하자:

 1. 모든 리프 노드의 값을 수집한다.
 2. 모든 리프 노드를 지운다.
 3. 트리가 빌 때까지 1, 2를 반복한다.

 따라서 결과 값은 리스트의 리스트가 된다. 같은 리프 노드 집합 안에서의
 순서는 상관없다.

 - 노드 개수: 1~100
 - 노드 값: -100~100

## 재귀적으로 구현
 - 레벨 오더 탐색의 일종이라고 생각해도 될듯. 리프 노드부터 레벨 0으로
   시작해서 루트 노드까지 1씩 증가하면서 거꾸로 올라오면 된다.
 - 트리를 재귀적으로 탐색하면 항상 어떤 서브 트리의 루트 노드를 보게
   되므로, 리프 노드가 레벨 0이라는 것을 올바르게 계산하려면 현재 루트
   노드의 양 서브 트리의 높이를 계산한 다음 둘 중 더 큰 것을 취하면
   된다.
 - 즉, 일반적인 트리의 높이를 구하는 것과 같다. 재귀적으로 트리의
   높이를 구하면서 동시에 내 높이 (= 레벨) 에 값을 덧붙이면 된다.

```python
def findLeaves(root):
    levels = defaultdict(list)

    def heights(node):
        if node is None:
            return 0

        lh, rh = heights(node.left), heights(node.right)
        curh = max(lh, rh)
        levels[curh].append(node.val)
        return curh + 1

    heights(root)
    return levels.values()
```
