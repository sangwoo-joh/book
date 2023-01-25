---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Kth Smallest Element in a BST
---

# [Kth Smallest Element in a BST](https://leetcode.com/problems/kth-smallest-element-in-a-bst/)

 이진 탐색 트리의 루트 노드와 정수 `k`가 주어졌을 때, `k` 번째로 작은
 값을 찾아라. 이때 `k`은 1-indexed 기준이다.

 트리의 노드 개수와 `k`는 1~10,000 이다.

## BST 탐색

 기본적으로 트리는 왼쪽 -> 오른쪽으로 탐색하는데, 루트 노드를 언제
 방문하느냐에 따라서 다음과 같이 세 가지 탐색 방법이 있다.
 - Preorder: 루트 -> 왼쪽 -> 오른쪽
 - Inorder: 왼쪽 -> 루트 -> 오른쪽
 - Postorder: 왼쪽 -> 오른쪽 -> 루트

 추가로, BST, 즉 이진 탐색 트리라면 모든 서브트리에 대해서 다음 Search
 Property를 만족한다: 어떤 서브트리에 대해서, 서브트리의 왼쪽
 서브트리의 모든 값은 서브트리의 루트 노드의 값보다 작고, 서브트리의
 오른쪽 서브트리의 모든 값은 서브트리의 루트 노드의 값보다 크다.

 따라서, BST 위에서 Inorder 탐색을 하면, 자연스럽게 오름차순으로
 노드를 방문하게 된다. 그러므로 우리는 BST를 Inorder로 방문하면서
 오름차순 배열을 만들 수 있고, 여기서 `k`번째 원소를 돌려주면 된다.

```python
def kthSmallest(root, k):
    arr = []
    def inorder(node):
        if node is None:
            return
        nonlocal arr
        inorder(node.left)
        arr.append(node.val)
        inorder(node.right)

    inorder(root)
    return arr[k-1]
```

 이때, `k`가 1-indexed 이므로 0-indexed인 배열에 맞춰 `k-1` 번째
 원소를 돌려주면 된다. 이렇게하면 O(N)의 시간 복잡도와 공간 복잡도를
 갖는다.

---

 그러면 O(1) 공간 복잡도의 접근도 가능하지 않을까? 방문 순서를 0으로
 초기화하고, Inorder로 탐색해 나아가면서 루트를 방문할 때마다 방문
 순서를 1씩 증가시키다가 `k`와 같아지는 순간 값을 구하면 될 것 같다.

```python
def kthSmallest(root, k):
    th, val = 0, None
    def inorder(node):
        if node is None:
            return
        nonlocal th
        nonlocal val
        if th > k:
            return
        inorder(node.left)
        th += 1
        if th == k:
            val = node.val
            return
        inorder(node.right)

    inorder(root)
    return val
```

 Inorder의 정의대로 왼쪽 -> 루트 -> 오른쪽만 잘 지킨다면 올바른 순서로
 `k` 번째 원소를 찾을 수 있다.
