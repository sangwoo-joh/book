---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Subtree of Another Tree
---

# [Subtree of Another Tree](https://leetcode.com/problems/subtree-of-another-tree/)

 두 개의 바이너리 트리의 루트 노드 `root`와 `subRoot`가 주어졌을 때,
 `subRoot`가 `root`의 서브트리인지 아닌지를 확인하자.

 어떤 트리의 서브트리는 해당 트리의 노드와 그 노드의 모든 자손을
 포함한다. 한 트리는 그 자체로 서브트리다.

 `root`의 노드 수는 1~2,000, `subRoot`의 노드 수는 1~1,000이다.

## 스텝 바이 스텝

 문제를 쪼개야 한다. 일단 두 트리의 루트 노드가 주어졌을 때, 두 트리가
 *완전히* 동일한 트리인지 확인하는 함수 `equal`을 생각해보자.

  - 두 노드 모두 null이면 같다.
  - 두 노드 중 하나만 null이면 다르다.
  - 두 노드의 값이 같**고**, 양쪽 자식에 대해서 똑같은 것을 확인한다.

 즉, `equal`은 다음과 같이 재귀적으로 작성할 수 있다.

```python
def equal(r1, r2):
    if not r1 and not r2:
        return True
    if (not r1 and r2) or (r1 and not r2):
        return False
    return r1.val == r2.val and equal(r1.left, r2.left) and equal(r1.right, r2.right)
```

 복잡도는 얼마일까? `r1`, `r2` 중 더 작은 트리의 노드 수 만큼 걸릴
 것이다. 그리고 대부분의 프로그래밍 언어에는 [Short-circuit
 evaluation](https://en.wikipedia.org/wiki/Short-circuit_evaluation)이
 구현되어 있으므로, 마지막 `and`로 묶인 리턴은 현실 데이터에서는
 생각보다도 빨리 끝날 것이다.

---

 그러면 이렇게 만든 `equal`을 가지고 다음과 같이 생각해볼 수 있다.

 - 일단 `root`와 `subRoot`가 같은지 확인한다.
 - 다르다면, `root`의 자식에 대해서 `subRoot`와 같은게 있는지를
   재귀적으로 확인해 나아간다.

 이를 코드로 작성하면 다음과 같다.

```python
def isSubtree(root, subRoot):
    return equal(root, subRoot) or (root and (isSubtree(root.left, subRoot) or isSubtree(root.right, subRoot)))
```

 - `isSubtree`를 호출하기 전에 `root`에 대해서 null 체크를 해주어야
   `root.left`나 `root.right`에 접근할 때 예외가 발생하지 않는다.

 이렇게하면 복잡도는 O(`len(root)` * `len(subRoot)`)가 걸리게 되고
 문제에서는 각각 2000, 1000 이라서 시간 초과가 나지 않는다.
