---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Lowest Common Ancestor of a Binary Search Tree
---

# [Lowest Common Ancestor of a Binary Search Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/)

 이진 탐색 트리의 루트 노드와 두 개의 노드가 주어진다. 두 노드는
 BST안에 반드시 존재하는 노드이다. 이때 두 노드의 LCA(Lowest Common
 Ancestor)를 구하자.

 LCA의 정의는 위키피디아에 따르면 다음과 같다: 두 노드 `p`와 `q`의
 LCA는 `p`와 `q`를 자손으로 가지면서 트리의 가장 낮은 위치에 있는
 노드이다. 이때, 노드는 그 자신의 자손이다.

 예를 들어서, 다음과 같은 BST 있을 때

![BST](https://assets.leetcode.com/uploads/2018/12/14/binarysearchtree_improved.png)

 - `2`와 `8`의 LCA는 루트인 `6`
 - `3`과 `5`의 LCA는 `4`
 - `0`과 `2`의 LCA는 `2`
 - `0`과 `5`의 LCA는 `2`

 가 된다.

 노드의 수는 2~100,000이고 모든 노드의 값은 유니크하다. `p`와 `q`는
 서로 다르며 반드시 BST 안에 있음이 보장된다.

## General Approach

 일반적인 트리에서 LCA를 구하는 가장 직관적인 방법은 다음과 같다.

 1. 일단 트리의 모든 노드의 레벨(또는 높이)를 구한다. 여기서는
    레벨이라고 하자.
 2. 노드에 부모 포인터가 없다면 부모로 가는 정보도 구해둔다.
 3. 두 노드의 레벨을 같도록 맞춘다. 레벨이 더 큰 쪽의 노드가 작은 쪽과
    같아질 때까지 부모를 따라 거슬러 올라간다.
 4. 두 노드가 같은 레벨에 있게 되면, 두 노드가 같아질 때까지 함께
    부모를 거슬러 올라간다.
 5. 두 노드가 같아지면 종료. 이 노드가 LCA이다.

 이 방법은 일종의 Bottom-Up 방법이다. 일단 두 노드가 같은 레벨에
 있도록 맞춘 다음, 서로 만날 때까지 부모를 거슬러 올라간다. 아주
 직관적인 방법이다. 이 아이디어를 구현하면 다음과 같다.

```python
def lowestCommonAncestor(root, p, q):
    levels = {}
    def set_levels(node, lv):
        if node is None:
            return
        levels[node] = lv
        set_levels(node.left, lv+1)
        set_levels(node.right, lv+1)
    set_levels(root, 0)

    parents = {}
    def set_parent(node):
        if node is None:
            return
        if node.left:
            parents[node.left] = node
        if node.right:
            parents[node.right] = node
        set_parent(node.left)
        set_parent(node.right)
    set_parent(root)

    if levels[p] < levels[q]:
        p, q = q, p
    # now levels(p) >= levels(q)
    while levels[p] != levels[q]:
        p = parents[p]
    while p != q:
        p, q = parents[p], parents[q]
    return q
```

 BST의 균형에 대한 조건은 언급되어 있지 않기 때문에, 트리 노드의
 개수를 N이라고 하면 O(N)의 시간 및 공간 복잡도를 얻는다.

## Use Search Property

 그런데 문제에서 트리가 그냥 트리가 아니라 BST라고 했다. BST는 Search
 Property라고 불리는 다음 성질을 만족하는데:
 - 모든 노드에 대해서, 노드의 값은 왼쪽 서브트리의 모든 값보다 크고
   오른쪽 서브트리의 모든 값보다 작다.

 이 성질을 이용할 수는 없을까?

 1. 일단 루트 노드에서 출발한다.
 2. 두 노드의 값이 루트 노드보다 **작다면**, 두 노드는 반드시 루트의
    왼쪽 서브트리에 있다.
 3. 두 노드의 값이 루트 노드보다 **크다면**, 두 노드는 반드시 루트의
    오른쪽 서브트리에 있다.
 4. 만약 둘다 아니라면, 이 뜻은 **처음으로** 두 노드 사이에 있는
    노드에 도달했다는 뜻이다. 그리고 이게 바로 LCA이다.

```python
def lowestCommonAncestor(root, p, q):
    node = root
    while node:
        if p.val < node.val and q.val < node.val:
            node = node.left
        elif p.val > node.val and q.val > node.val:
            node = node.right
        else:
            return node
```

 아무런 저장 공간을 소모하지 않으므로 O(1)의 공간 복잡도를 소모한다.


# [Lowest Common Ancestor of a Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/)

 이 문제는 위의 문제에서 입력이 BST가 아닌 일반 트리로 바뀐 것
 뿐이다. 따라서, 위의 첫 번째 솔루션을 그대로 활용할 수 있다. 여기서는
 추가로 재귀적인 솔루션을 살펴보려고 한다.

 1. 루트부터 시작해서 재귀적으로 탐색해 나아간다.
 2. null 노드이거나, 찾고자 하는 LCA의 대상 노드 중 하나라면, 곧바로
    리턴한다. 이는 곧 LCA가 되거나 또는 `p`, `q` 둘 중 하나의 조상노드
    중 하나가 된다.
 3. 양쪽 서브트리에서 재귀적으로 가능한 LCA 또는 `p`, `q`의 조상
    노드가 될 수 있는 노드를 찾는다. 만약 양쪽에서 모두 null이 아닌
    노드를 발견한다면, 지금 있는 루트노드가 곧 LCA가 된다. 그게
    아니라면, 둘 중 null이 아닌 노드가 LCA이다.

```python
def lowestCommonAncestor(root, p, q):
    if root in [None, p, q]:
        return root

    left = lowestCommonAncestor(root.left, p, q)
    right = lowestCommonAncestor(root.right, p, q)
    if left and right:
        return root
    return left or right
```

 - 마지막의 `return left or right`는 파이썬의 트릭 중 하나로, C에서
   `return left != null ? left : right;`와 같은 의미이다.
