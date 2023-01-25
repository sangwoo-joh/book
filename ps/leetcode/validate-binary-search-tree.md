---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Validate Binary Search Tree
---

# [Validate Binary Search Tree](https://leetcode.com/problems/validate-binary-search-tree/)

 BST로 추정되는 트리의 루트 노드가 주어졌을 때, 이게 진짜 BST인지
 확인하자.

 BST는 다음의 Search Property를 만족해야 한다:
 - 노드의 왼쪽 서브트리는 노드의 키 값보다 작은 값만 담아야 한다.
 - 노드의 오른쪽 서브트리는 노드의 키 값보다 큰 값만 담아야 한다.
 - 왼쪽과 오른쪽 서브트리도 역시 위의 조건을 재귀적으로 만족해야 한다.

 노드의 개수는 1~10,000개, 노드의 값은 32비트 정수가 포함할 수 있는
 모든 범위에 걸쳐 있다.

## 재귀적으로 범위 나누기

 노드를 중심으로 범위를 나눈다고 생각해보자. 조건에 따라 왼쪽
 서브트리의 모든 노드의 키 값은 현재 노드의 키 값보다 작아야
 한다. 오른쪽 서브트리는 이와 반대로 커야 한다. 이걸 범위로
 생각해보자. 초기의 범위는 $$ [-\infty, \infty] $$ 이다. 루트는 항상
 이 범위 안에 들어간다. 루트를 기준으로 왼쪽 서브트리의 범위는 조건에
 따라 $$ [-\infty, root.val) $$이 된다. 자연스럽게 오른쪽 서브트리의
 범위는 $$ (root.val, \infty] $$ 임을 알 수 있다. 이런식으로
 재귀적으로 범위를 계속 쪼개가면서, 현재 노드의 값이 이 범위 안에
 들어가는지를 확인하면 Search Property를 만족하는지 알 수 있다.

```python
def isValidBST(root):
    def validate(node, low=float('-inf'), high=float('inf')):
        if node is None:
            return True
        return (low < node.val < high) and validate(node.left, low, node.val) and validate(node.right, node.val, high)
    return validate(root)
```

 - 파이썬의 `float('inf')`와 `float('-inf')`를 이용해서 손쉽게
   무한소와 무한대를 표현할 수 있다.
 - 노드가 null이면 자연스럽게 만족한다고 할 수 있따.

## 트리의 중위 순회 순서 이용하기

 다른 방법으로는 트리의 중위 순회를 이용하는 방법이 있다. 트리의
 순회는 기본적으로 왼쪽 -> 오른쪽으로 이뤄지고, 루트 노드를 언제
 방문할 것인지에 따라 다음 세 가지가 있다.
 - Preorder: root -> left -> right
 - Inorder: left -> root -> right
 - Postorder: left -> right -> root

 이때 트리가 BST라면, Inorder 순위는 자연스럽게 Search Property를
 만족하는 정렬된 순서로 노드를 방문하게 된다. 이 성질을 이용해보자.

 먼저 이전 값을 저장해둘 필요가 있다. 초기값은 $$-\infty$$이다. 이
 값은 항상 32비트 최소값보다 작으므로 트리에 어떤 값이 담겨 있든 중위
 순회의 첫번째 방문 노드의 키 값보다 작을 것이다. 이후 중위 순회
 순서대로 진행하면서, 이 이전 값보다 지금 노드 값을 비교하고
 업데이트한다. 이렇게 끝까지 진행하면서 하나라도 순서가 이상한게
 있는지 체크하면 된다.

```python
def isValidBST(root):
    prev = float('-inf')
    def inorder(node):
        nonlocal prev
        if node is None:
            return True

        if not inorder(node.left):
            return False

        if not (prev < node.val):
            return False

        prev = node.val
        return inorder(node.right)
    return inorder(root)
```

 - 파이썬은 Expression 안에 Assignment를 쓸 수 없다. 그래서 리턴
   한줄에 조건을 우겨넣으면서 동시에 `prev` 값을 업데이트할 수
   없다. 위 코드처럼 하나씩 차근차근 해결하자.
 - 중위 순회의 정의에 따라 왼쪽을 먼저 확인하고, 그 다음 지금 노드를
   체크한다. 이때 반드시 `prev` 값을 업데이트해줘야 한다. 그래야
   올바른 체크가 된다.
