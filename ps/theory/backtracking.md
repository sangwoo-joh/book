---
layout: page
tags: [problem-solving, theory, backtracking]
title: Backtracking
---

# 백트래킹

 백트리킹이란 CSP(Constraint Satisfaction Problem)이라고 불리는
 제약조건만족문제를 풀기위한 일반적인 방법론을 말한다. 주로 정답의
 후보를 점진적으로 만들다가 후보가 정답이 아니라는 것을 알면 그걸
 버리고 이전으로 돌아가서 다시 후보를 만들어 가는 과정이다.

 개념적으로는 (탐색 공간의) **트리 탐색** 과정과 유사하다. 루트
 노드에서부터 시작해서 리프 노드에 있는 정답 후보를 탐색한다. 중간에
 있는 노드는 **부분적인** 정답 후보이고 최종 정답이 될 가능성이
 있다. 각각의 노드에서는 노드의 자식 노드를 하나씩 골라서 정답으로 한
 단계씩 나아갈 수 있다. 어떤 노드가 절대로 정답이 안될 거라고
 판단되면, 지금 노드를 버리고 **뒤로 돌아가서(backtrack)**, 즉 부모
 노드로 올라가서 다른 가능성을 찾아본다. 이런 특징 때문에 백트래킹은
 완전탐색(Brute Force)보다 훨씬 빠르게 동작한다.

## 템플릿

 백트래킹 문제의 알고리즘은 대부분 어떤 패턴을 갖고 있다.

```python
def backtrack(candidate):
    if find_solution(candidate):
        output(candidate)
        return

    # iterate all possible candidates
    for next_candidate in list_of_candidates:
        if is_valid(next_candidate):
            # try this partial candidate solution
            place(next_candidate)
            # given the candidate, explore further
            backtrack(next_candidate)
            # backtrack
            remove(next_candidate)
```

 - 전체적으로 후보군을 만드는 일은 두 레벨로 진행된다. 먼저 함수는
   재귀적으로 구현된다. 각 재귀 함수 호출에서 함수는 최종 정답으로 한
   단계씩 진행한다. 두 번째로, 재귀 안에서는 모든 후보군을 탐색하는
   반복을 통해 최종 정답으로 나아가고 있다.
 - 백트래킹은 재귀 안의 반복 레벨에서 나타난다.
 - 완전탐색과는 다르게, 백트래킹에서는 지금까지 만들어낸 부분 정답
   후보가 탐색할 가치가 있는지를 확인할 수 있다(코드의
   `is_valid(next_candidate)`). 이를 통해 탐색 공간을 가지치기할 수
   있다. 이는 제약조건이라고도 하는데, 예를 들면 N-퀸 문제에서 퀸이 갈
   수 있는 좌표값이 있다.
 - 두 개의 대칭적인 함수에 주목하자. 부분 후보를 한 단계 진행시키는
   결정을 하는 `place(candidate)`과, 이 결정을 취소하는
   `remove(candidate)`이다.
