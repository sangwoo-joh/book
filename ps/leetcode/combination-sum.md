---
layout: page
tags: [problem-solving, leetcode, python, backtracking]
title: Combination Sum
---

# [Combination Sum](https://leetcode.com/problems/combination-sum/)

 중복 없는 정수 배열 `candidates` 와 정수 `target`이 주어졌을 때,
 `candidates`에서 고른 숫자 배열 합이 `target`이 되는 모든 유일한
 조합의 목록을 구하자. 순서는 상관없다.

 같은 값의 원소가 **무한 번** 선택될 수 있다. 선택된 숫자의 빈도가
 다를 때에만 유일한 조합으로 간주한다.

 - `candidates` 크기: 1~30
 - `candidates` 값의 범위: 2~40
 - `targete`: 1~500


## 백트래킹
 - **모든** 조합을 구해야 하므로 정직하게 다 찾아봐야 하긴 한다.
 - 하지만 애초에 불가능한 경우는 탐색할 필요가 없으므로, 적절히
   가지치기가 가능하다.
 - 따라서 백트래킹으로 충분히 가능해보인다.
 - 유지할 상태:
   - 지금 턴에서 살펴볼 원소의 인덱스
   - 지금까지 조합한 배열
   - 지금까지 쌓은 합 또는 `target`에서 빼면서 남은 값, 이건 근데
     배열을 유지할거면 매번 합을 구하는 방식으로 구해도 된다 (어차피
     문제 크기가 작음)
 - 같은 값을 무한 번 선택할 수 있음에 주의하자. 상태에서 현재
   인덱스로부터 다음 인덱스를 살펴볼 때 **항상 지금 인덱스를
   포함하도록** 다음 상태를 전이하면 된다.
 - 프루닝 가능한 부분: 지금까지 조합한 배열 합이 `target`을 넘겼을 때,
   이때는 더 이상 살펴봐도 의미없다.

```python
def combinationSum(candidates, target):
    answer = []
    def backtrack(comb, idx, cursum):
        if cursum == target:
            answer.append(comb[::])
            return
        elif cursum > target:
            return

        for i in range(idx, len(candidates)):
            comb.append(candidates[i])
            backtrack(comb, i, cursum + candidates[i])
            comb.pop()
    backtrack([], 0, 0)

    return answer
```
