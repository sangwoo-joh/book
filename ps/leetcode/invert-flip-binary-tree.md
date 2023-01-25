---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Invert/Flip Binary Tree
---

# [Invert/Flip Binary Tree](https://leetcode.com/problems/invert-binary-tree/)

 바이너리 트리의 루트 노도가 주어졌을 때, 해당 트리를 뒤집어서 새로운
 트리를 리턴하자.

![inverted](https://assets.leetcode.com/uploads/2021/03/14/invert1-tree.jpg)

## 재귀

 딱 봐도 재귀적인 접근이 먹힐 것 같다. 루트를 기준으로 왼쪽과 오른쪽
 노드를 바꾼 다음, 계속 내려가면 된다.

```python
"""
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right
"""
def invertTree(root):
    def invert(node):
        if node is None:
            return
        node.left, node.right = node.right, node.left
        invert(node.left)
        invert(node.right)
    invert(root)
    return root
```

 위 코드는 원래 트리를 직접 수정한다. 만약 트리를 수정하지 않고 뒤집은
 트리를 새롭게 만들어서 리턴해야 하는 경우는 어떻게 하면 될까? 다음과
 같이 `invert` 함수가 뒤집은 트리 노드를 매번 돌려주면 된다.

```python
def invertTree(root):
    def invert(node):
        if node is None:
            return None
        fresh = TreeNode(val=node.val)
        fresh.left, fresh.right = invert(node.right), invert(node.left)
        return fresh
    return invert(root)
```
