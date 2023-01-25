---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Binary Tree Cameras
---

# [Binary Tree Cameras](https://leetcode.com/problems/binary-tree-cameras/)

 이진 트리의 루트 노드가 주어진다. 트리의 노드에 카메라를 설치해서
 노드 자신과 부모, 그리고 자식 노드를 관찰하려고 한다.

 트리의 모든 노드를 관찰하기 위해서 필요한 최소 카메라의 수를 구하자.

 노드 수는 최대 1,000 이고 모든 노드의 값은 0이다.

 예를 들어 아래와 같은 트리는, 카메라를 1개만 설치하면 모든 노드를 다
 관찰할 수 있다.

![tree1](https://assets.leetcode.com/uploads/2018/12/29/bst_cameras_01.png)

## 음..?

 이걸 무슨 알고리즘이라고 불러야될지 모르겠다. 솔루션에는 DP라고
 나와있는데 DP가 아니어도 풀 수 있는 것 같고, 그리디도 아닌것 같고..

 트리를 리프 노드부터 훑어서 루트 노드까지 올라올 때, 각 노드가 가질
 수 있는 상태는 총 세 가지이다:
 1. 카메라가 설치됨
 2. 카메라가 설치되지 않았지만, 인접한 노드에 의해서 관찰됨
 3. 카메라가 설치되지도 않았고 인접한 노드에도 없어서 관찰도 안됨

 그러면 자식 노드의 상태에 따라서, 지금 노드의 상태를 알 수 있고, 이때
 카메라를 설치해야 하는 노드도 알 수 있다. 즉,
 - null 노드는 2번 상태라고 볼 수 있다. null이기 때문에 카메라를
   설치할 수는 없지만, null이라서 특별히 관찰하지 않아도 관찰되고 있기
   때문이다.
 - 현재 노드의 자식 노드에 따라서 현재 노드의 상태가 나눠진다. 즉,
   - 자식 노드 중 하나라도 카메라도 없고 관찰되고 있지도 않으면, 지금
     노드에 카메라를 설치해야 한다.
   - 자식 노드 중 하나라도 카메라가 있다면, 지금 노드는 관찰되고 있는
     상태이다.
   - 위의 두 경우가 아니라면 카메라도 없고 관찰되고 있지도 않은
     상태이다.

 이 중 카메라를 설치해야 하는 경우에 카메라 개수를 늘리면 된다.

 다만, 이때 한 가지 코너 케이스가 있는데, 바로 루트 노드에 카메라도
 없고 관찰되지도 않는 경우이다. 이때는 추가적으로 루트 노드에 카메라를
 설치해줘야 한다. 예를 들어, 루트 노드 하나만 있는 경우이거나, 혹은
 아래와 같이 Skewed Tree일 때 이런 케이스가 생긴다:

```
^  O -------------> not monitored ! -> need to install camera
|   \
|    O -----------> monitored
|     \
|      O  --------> camera
|       \
|        O    ----> not monitored
|
see upward
```

 따라서 아래와 같이 구현할 수 있다.

```python
def minCameraCover(root):
    CAMERA = 0
    MONITORED = 1
    NOT_MONITORED = 2

    camera_count = 0
    def dfs(node):
        nonlocal camera_count
        if not node:
            return MONITORED

        left, right = dfs(node.left), dfs(node.right)
        if NOT_MONITORED in (left, right):
            camera_count += 1
            return CAMERA
        elif CAMERA in (left, right):
            return MONITORED
        return NOT_MONITORED

    if dfs(root) == NOT_MONITORED:
        # corner case
        camera_count += 1
    return camera_count
```
