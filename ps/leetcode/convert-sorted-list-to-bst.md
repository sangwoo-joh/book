---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Convert Sorted List to Binary Search Tree
last_update: 2023-04-05 09:46:55
---

# [Convert Sorted List to Binary Search Tree](https://leetcode.com/problems/convert-sorted-list-to-binary-search-tree/)

 *오름차순으로 정렬*된 링크드 리스트의 헤드 노드가 입력으로 들어왔을
 때, 이걸 *밸런스가 맞춰진* 바이너리 서치 트리로 바꾸는
 문제이다. 여기서 *밸런스*는 모든 노드의 양 쪽 서브트리 높이의 차이가
 최대 1만큼 나는 친구다.

## Inorder Traverse

 트리를 순회하는 방법은 기본적으로 왼쪽 -> 오른쪽이고 루트를 언제
 방문하느냐에 따라 세 가지로 나뉜다.
 - 전위 순회: 루트 -> 왼 -> 오
 - 중위 순회: 왼 -> 루트 -> 오
 - 후위 순회: 왼 -> 오 -> 루트

 이 중에서 중위 순회가 가장 우리의 직관과 맞닿아 있다. 특히, BST를
 중위순회하면 정렬된 순서로 노드를 방문하게 된다. 이 성질을 이용해볼
 수 있다.

 중위 순회는 결국 루트 노드를 기준으로 왼쪽 서브트리를 먼저 다 뒤지고,
 그 다음 루트 노드를 뒤지고, 그 다음 오른쪽 서브트리를 다 뒤지는
 것이다. 만약 (1) 트리가 균형이 맞고, (2) 트리의 노드 수를 알고
 있다면, 다음 성질 또한 알 수 있다: 루트 노드가 항상 노드 수를 절반 씩
 나누게 된다.

 마침 우리는 *밸런스가 맞춰진* 트리를 복원하는 것이 목표이므로, 이
 성질을 이용해서 중위 순회를 시뮬레이션할 수 있다.

```python
def inorder(low, high):
    if low > high:
        return None
    mid = (low + high) // 2

    inorder(low, mid - 1)
    # make tree node from linked list
    # forward linked list
    inorder(mid + 1, high)
```

 즉, 리스트 전체 사이즈를 먼저 구해서 `low`와 `high`를 가지고 중위
 순회를 돌면서, 더 이상 절반으로 쪼개지지 않으면 null을 매달고, 그게
 아니라면 링크드 리스트의 노드로부터 트리의 노드를 만들면 된다. 문제의
 조건 덕분에 이런 시뮬레이션이 가능하다.

```python
def sortedListToBST(head):
    high = 0
    node = head
    while node:
        high += 1
        node = node.next
    high -= 1

    node = head
    def inorder(low, high):
        nonlocal node
        if low > high:
            return None
        mid = (low + high) // 2
        left = inorder(low, mid - 1)
        root = TreeNode(node.val)
        node = node.next
        root.left = left

        root.right = inorder(mid + 1, high)
        return root
    return inorder(0, high)
```

 - `low`와 `high`는 모두 인덱스임에 주의하자. 따라서 `high`는 링크드
   리스트의 길이에서 1을 빼줘야 한다.
 - 중위 순회의 방문 순서를 충실하게 지키고 있음을 눈여겨 보자. 먼저
   왼쪽 서브트리를 방문한다. 그 결과를 `left`에다 우선 저장해둔다. 그
   후 현재 `node`의 값으로부터 지금 위치의 루트 노드를 만든다. 루트
   노드의 왼쪽 서브트리를 미리 순회해둔 포인터로 설정한다. 마지막으로
   오른쪽 서브트리를 방문할 건데 이때는 곧바로 루트 노드의 오른쪽에
   박아둔다. 최종적으로 루트 노드를 리턴한다.
