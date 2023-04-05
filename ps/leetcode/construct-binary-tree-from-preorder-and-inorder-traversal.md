---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Construct Binary Tree from Preorder and Inorder Traversal
last_update: 2023-04-05 09:47:46
---

# [Construct Binary Tree from Preorder and Inorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)


 어떤 바이너리 트리가 있다. 이 트리를 Inorder로 순회한 결과 배열과
 Preorder로 순회한 결과 배열이 입력으로 주어졌을 때, 이 바이너리
 트리를 복원하고 루트 노드를 리턴하자.

 입력으로 들어오는 Preorder, Inorder 배열의 길이는 같고 1~3,000 사이의
 값이다. 각각의 배열 값은 -3,000~3,000 사이의 값을 갖고 항상 유니크한
 값을 담고 있다. Inorder에 나타난 모든 값은 Preorder에도
 존재한다. Preorder와 Inorder는 동일한 바이너리 트리를 각각 Preorder와
 Inorder로 순회한 결과임이 보장된다.

## 해시 테이블 해킹

 이거랑 유사한 문제가 [그래프 클론하기](../clone-graph)인데, 이런 류의
 문제는 주로 (1) 올바른 순서로 탐색하면서 (2) 해시 테이블에 **노드**를
 직접 저장해뒀다가 꺼내 쓰는 것이 주요한 접근으로 보인다.

 일단 트리의 순회는 기본적으로 왼쪽 -> 오른쪽이고, 루트 노드를 언제
 방문하느냐에 따라 다음 세 가지 방법이 있다:
 1. Pre-order: 루트 -> 왼쪽 -> 오른쪽
 2. In-order: 왼쪽 -> 루트 -> 오른쪽
 3. Post-order: 왼쪽 -> 오른쪽 -> 루트

 우리에게 주어진 것은 1과 2의 순회 결과이다. 일단 여기서 알 수 있는
 것은 다음 두 가지이다.
 - Pre-order 결과의 첫번째 원소는 전체 트리의 루트 노드이다.
 - In-order 결과는 항상 루트를 중간에 탐색하므로, 만약 어떤 서브트리의
   루트 위치를 알고 있다면, 왼쪽과 오른쪽 서브트리를 알게 된다.

 이해를 위해 구체적인 예시를 살펴보자. 다음과 같은 트리가 있을 때,

```python
           3
           |
  +--------+--------+
  |                 |
  9                20
  |                 |
+--+--+          +--+--+
|     |          |     |
1     2          15    7
```

 입력으로 들어오는 `preorder`와 `inorder`는 다음과 같다.

```python
preorder: [3, 9, 1, 2, 20, 15, 7]
inorder: [1, 9, 2, 3, 15, 20, 7]
```

 이때 관찰대로 `preorder`의 첫번째 인덱스 `3`은 전체 트리의
 루트노드이다. 그러면 이 값의 `inorder`에서의 위치를 살펴보면, `3`을
 기준으로 왼쪽에 있는 모든 원소는 왼쪽 서브트리이고 오른쪽에 있는 모든
 원소는 오른쪽 서브트리가 된다. 즉,

```python
inorder: [1, 9, 2,          3,        15, 20, 7  ]
         |               | root  |               |
         |  left subtree |       | right subtree |
```

 한 단계만 더 나아가보자. `preorder`의 다음 원소인 `9`는 `3`의 왼쪽
 서브트리의 루트노드인 것을 알 수 있다. 따라서, `inorder`에서 `3`의
 왼쪽 서브트리 부분에서 `9`를 찾으면, 이번에도 왼쪽 서브트리와 오른쪽
 서브트리를 알아낼 수 있다.

```python
inorder: [1,                 9,            2     ]
         |               | root  |               |
         |  left subtree |       | right subtree |
```

 이제 실마리가 보이는 것 같다. 즉, 우리가 해야할 일은 다음과 같다.

 1. 먼저 노드 -> Inorder의 인덱스로 가는 해시 테이블을 만든다.
 2. 노드는 Preorder 순으로 빌드할 것이다. 전역 인덱스 0을 만들어서
    현재 Preorder 순회의 어디인지 추적한다.
 3. Preorder 순으로 노드를 만들면서 진행하는 재귀함수는 다음 일을
    한다:
    - 범위가 벗어났으면 `None`
    - 범위가 적절하다면, 현재 Preorder 인덱스 위치의 값을 가져와서
      현재 서브 트리의 루트 노드를 생성하고 인덱스를 증가
    - 노드의 양쪽 서브 트리를 재귀적으로 호출해서 만들건데, 이때
      범위를 적절하게 줌

 즉, 키 아이디어는 Inorder 순회 결과에서 루트 노드의 위치를 알면,
 왼쪽과 오른쪽 범위를 가지고 서브 트리 정보를 알아낼 수 있다는 점을
 이용하고, 이때 루트 노드의 정확한 위치를 Preorder를 가지고 알아내는
 것이다.

 아이디어를 구현하면 다음과 같다.

```python
def buildTree(preorder, inorder):
    inorder_index_of = {}
    for idx, val in enumerate(inorder):
        inorder_index_of[val] = idx

    preorder_index = 0
    def pre_order(left, right):
        nonlocal inorder_index_of
        nonlocal preorder_index

        if left > right:
            return None

        root_value = preorder[preorder_index]
        root = TreeNode(root_value)
        preorder_index += 1

        root.left = pre_order(left, inorder_index_of[root_value] - 1)
        root.right = pre_order(inorder_index_of[root_value] + 1, right)
        return root
    return pre_order(0, len(preorder)-1)
```

 - 일종의 이분 탐색이라고 봐도 되겠다. Preorder에서 루트 노드의
   인덱스를 기준으로 양 옆을 쪼개면서 트리를 구성해간다.
 - 솔직히 이 문제를 시간 안에 풀 자신은 없다.
