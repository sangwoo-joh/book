---
layout: page
tags: [problem-solving, leetcode, python, hash-table]
title: Two Sum
---

# [Two Sum](https://leetcode.com/problems/two-sum/)
 상징적인 리트코드 1번 문제다.

 정수 배열 `nums`와 어떤 정수 `target`이 주어졌을 때, 정수 배열의 두
 원소 중 합이 `target`이 되는 인덱스 두 개를 찾는 문제이다.

 이때, 입력은 항상 **정확히 하나**의 해를 가지며, **같은** 원소를 두
 번 쓸 수 없다. 인덱스 두 개의 순서는 상관없다.

## 접근 1 - Brute Force
 - 모든 가능한 쌍을 탐색

 ```python
def two_sum(nums, target):
    for i1, n1 in enumerate(nums):
        for i2 in range(i1 + 1, len(nums)):
            if n1 + nums[i2] == target:
                return (i1, i2)
```

## 접근 2 - 해시 테이블
 - 문제의 조건 덕분에 가능한 접근: (1) 항상 유일한 답이 있고 (2) 같은
   원소가 두 번 쓰이지 않음
 - 정수 `x`가 있을 때 어딘가에 반드시 `target - x`(보수)가 있어야 함
 - 따라서, 정수 -> 인덱스로 가는 해시 테이블을 이용할 수 있음
 - 문제 조건에 유의해야 함:
   - 정답은 **인덱스**의 튜플
   - 같은 원소가 두 번 쓰이면 안됨


```python
def two_sum(nums, target):
    comps = {}
    for i, n in enumerate(nums):
        comps[n] = i

    for i, n in enumerate(nums):
        comp = target - n
        if comp in comps and i != comps[comp]:
            return (i, comps[comp])
```


# [Two Sum II - Input Array Is Sorted](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)

 같은 문제인데 입력 배열이 정렬되어 있는 경우.

 위의 접근 2를 그대로 활용할 수 있지만 좀더 잘 할 수 있다.


## 접근 - O(1) 공간 복잡도
 - *정렬*되어 있는 성질을 이용하여 이분 탐색 아이디어를 활용할 수
   있음
   - 두 개의 포인터 `(low, high)`를 두고 양 끝에서 시작
   - 두 값의 합이 `target`보다 작으면, 합을 더 크게 만들기 위해서는
     `low`를 증가하는 수 밖에 없음
   - 두 값의 합이 `target`보다 더 크면, 합을 더 작게 만들기 위해서는
     `high`를 줄이는 수 밖에 없음


```python
def twoSumII(numbers, target):
    low, high = 0, len(numbers)-1
    cand = 0
    while low < high:
        cand = numbers[low] + numbers[high]
        if cand == target:
            return [low+1, high+1]  # the problem is 1-indexed.
        elif cand < target:
            low += 1
        else:
            high -= 1

    raise ValueError
```


# [Two Sum IV - Input is a BST](https://leetcode.com/problems/two-sum-iv-input-is-a-bst/)

 만약 입력이 배열이 아니라 BST면 어떻게 해야할까?

 역시 앞의 두 접근을 모두 사용할 수 있는데,
  1. BST를 한번 순회하면서 보수의 해시 테이블을 만든 다음, 다시 한번
     BST를 순회하면서 해시 테이블을 확인하는 방법과,
  2. BST로부터 정렬된 배열을 복원한 뒤 투 포인터로 확인하는 방법

 두 가지가 모두 가능하다. BST를 중위순회하면 정렬된 순서로 노드를
 방문할 수 있다는 성질을 이용한 2번 접근을 코드로 구현하면 다음과
 같다.

```python
def findTarget(root, k):
    ordered = []
    def inorder(node):
        if not node:
            return
        inorder(node.left)
        ordered.append(node.val)
        inorder(node.right)
    inorder(root)

    low, high = 0, len(ordered)-1
    while low < high:
        cand = ordered[low] + ordered[high]
        if cand == k:
            return True
        elif cand < k:
            low += 1
        else:
            high -= 1
    return False
```
