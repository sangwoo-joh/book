---
layout: page
tags: [problem-solving, leetcode, python, tree]
title: Binary Tree - Maximum Path Sum
---

# [Binary Tree - Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/)

 바이너리 트리 안의 **경로**란 인접한 두 노드 사이에 엣지가 있는
 노드의 시퀀스를 말한다. 노드는 **최대 한번** 그 시퀀스에 나타날 수
 있다. 경로가 꼭 **루트를 지날 필요는 없다는 것을 알아두자.**

 **경로 합**이란 어떤 경로에 있는 모든 노드의 값의 합을 뜻한다.

 바이너리 트리의 루트 노드가 주어졌을 때, **비어있지 않은** 경로
 중에서 **경로 합**의 최대 값을 구하자.

 노드 개수의 범위는 $$ 1 \sim 3 \times 10^4 $$ 이고 값은 -1,000~1,000
 사이이다.

## 풀이

 하드 문제 다운 난이도이다. 일단 트리이긴 하지만 **경로**를 고려해야
 하고, 또 노드의 값이 **음수**가 될 수 있기 때문에 까다롭다.

 몇 가지 기본적인 관찰을 해보자.
 - 노드에 서브트리가 없을 때에는 노드의 값 그 자체가 된다.
 - 트리으 노드가 전부 음수이면, 노드 중 가장 큰 값이 곧바로 답이
   된다. 노드를 하나라도 더 골라서 경로를 만들면 음수가 더해져서 계속
   작아지기 때문이다.
 - 음수가 가능하기 때문에, 어떤 노드의 왼쪽과 오른쪽 서브트리를 볼 때,
   **이득**만을 따져야 한다. 즉, 어떤 서브트리의 노드 값을 다 더해서
   오히려 마이너스가 될 수 있기 때문에, 아예 안따지는 경우(즉, 0)와
   비교해야 한다.
 - 현재 노드를 **루트 노드로 포함하는 경로**에서 **가능한 이득**을
   따질 때에는 결국 세 가지를 다 따져야 한다: (1) 현재 노드만 따졌을
   때, (2) 왼쪽 서브트리의 이득, (3) 오른쪽 서브트리의 이득. 이 값이
   이전 최대 값보다 크면 업데이트 해야 한다.
 - 현재 노드를 **포함하는 경로**를 생각한다면, 양쪽 서브트리의 이득 중
   더 큰 값만을 더해야 한다. 왜냐하면 **경로**이기 때문에, 양쪽
   서브트리를 다 포함할 수는 없다.

```python
def maxPathSum(root):
    maxsum = float('-inf')

    def max_gain_include_path(node):
        """
        Returns max profit with the node as root
        """
        if node is None:
            return 0

        left_profit = max(max_gain_include_path(node.left), 0)
        right_profit = max(max_gain_include_path(node.right), 0)
        profit = node.val + left_profit + right_profit
        nonlocal maxsum
        maxsum = max(maxsum, profit)

        return node.val + max(left_profit , right_profit)

    max_gain_include_path(root)
    return maxsum
```


 설명에 비해서 코드는 꽤 짧은 편이다. 결국 위에서 설명한 걸 그대로
 적은 것인데,
 - `left_profit`과 `right_profit`은 현재 노드의 양쪽 서브트리안의
   경로에서 얻을 수 있는 최대한의 이득을 계산한 뒤에, 이 값과 0 중 더
   큰 값을 취해서 음수인 경우를 처리한다.
 - `profit`은 현재 노드를 **루트 노드로 포함한 경로**에서 가능한
   이득을 따진다. 즉, 현재 노드의 부모 노드를 타고 올라가는 경로는
   여기서 고려되지 않는다. 그리고 이 값을 `maxsum`에 업데이트 한다.
 - 리턴 값은 현재 노드를 **포함하는 경로**에서 가능한 이득을
   리턴한다. 즉, **현재 노드의 부모 노드를 타고 올라가는 경로**를
   고려한다. 이때에는 경로의 정의에 따라 왼쪽과 오른쪽 중 하나의
   서브트리만을 택할 수 있기 때문에, 둘 중 더 큰 값을 더한다.
 - `maxsum`을 한번만 업데이트해도 되는 이유는, 베이스 케이스에서
   노드가 null이면 0을 리턴하기 때문이다. 덕분에 리턴 값을 한번 더
   `maxsum`과 비교해서 업데이트하지 않아도 재귀 호출 어딘가에서
   처리된다.
 - 최종적으로 구한 값은 `maxsum`에 저장되므로 이 값을
   리턴한다. `max_gain_include_path`는 **현재 노드의 부모 노드를 타고
   올라가는 경로**를 고려했을 때 최대 값을 리턴하는 함수이므로, 이
   값을 리턴하면 안된다.
