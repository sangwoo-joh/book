---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Find And Replace in String
---

# [Find And Replace in String](https://leetcode.com/problems/find-and-replace-in-string/)

 어떤 단어 `s`가 주어지고 여기에 `k`번의 교체 연산을 하려고 한다. 교체
 연산은 다음과 같은 0부터 시작하는 인덱스를 기준으로, 세 배열
 `indices`, `sources`, `targets`로 주어지며 길이는 모두 `k`이다.

 `i` 번째 교체 연산은 다음과 같이 이뤄진다:
 1. 부분 문자열 `sources[i]`이 원본 문자열 `s`의 인덱스 `indices[i]`에
    있는지 확인한다.
 2. 만약 없으면, 아무것도 안한다.
 3. 만약 있으면, 이 부분 문자열을 `targets[i]`랑 교체한다.

 예를 들어서 `s = "abcd"`이고 `indices[i] = 0`, `sources[i] = ab`,
 `targets[i] == eee` 라면, 이 교체 연산의 결과는 `eeecd`가 된다.

 모든 교체 연산은 **동시에** 수행되어야 한다. 즉, 교체 연산으로
 문자열이 수정되었을 때, 서로 다른 교체 연산에게 (특히 인덱싱 관련)
 영향을 주지 않아야 한다. 입력은 이런 교체 연산끼리 수정하는 부분이
 겹치지 않음이 보장된다.

 예를 들어, `s = "abc"`이고 `indices = [0, 1]`, `sources = ["ab",
 "bc"]`인 경우는 절대 입력으로 주어지지 않음이 보장된다. 왜냐하면
 `"ab"`와 `"bc"`를 교체하는 연산이 서로 겹치기 때문이다.

 모든 연산을 수행한 결과 문자열을 계산하자.

 문자열 `s`의 길이는 1 ~ 1,000 사이이고 $$ 1 \leq k \leq 100 $$
 이다. 세 교체 연산 배열의 크기는 모두 `k`이다. 부분 문자열 `source`와
 교체 문자열 `target`의 길이는 1 ~ 50이다. 모든 문자열은 알파벳
 소문자만 포함한다.

## 역방향으로 수정하기

 얼핏보면 쉬워 보이지만, 문제는 모든 연산이 **동시에** 수행되어야
 한다는 점이다. 이는 바꿔말하면 어떤 연산이 다른 연산에게 영향을
 미치면 안된다는 것이다. 특히, 문자열을 수정한 뒤 길이가 바뀌는
 경우에, 다른 교체 연산의 **인덱스**에 영향을 미치면 안된다.

 예를 들어 `s = "abcd"`이고 `indices = [0, 2]`, `sources = ["ab,
 "cd]`, `targets = ["eeee", "ddd"]`라고 하자. 이걸 순서대로 첫번째
 연산부터 수행하면 `abcd`가 `eeeecd`가 되는데, 이러면 두번째 연산의
 인덱스 `2` 위치에 `cd`가 아닌 `ee`가 있어서 두번째 연산이
 실패한다. 하지만 동시에 연산을 수행하면, `ab`와 `cd`를 `eeee`와
 `ddd`로 바꿔서 정상적으로 `eeeeddd` 결과를 얻을 수 있다.

 위와 같이 **서로 다른 연산에게 영향을 주지 않으려면** 어떤 순서로
 연산을 해야할까? 키 포인트는 교체 연산을 **인덱스의 역순**으로 하는
 것이다. 위의 예시에서 `cd -> ddd` 연산을 먼저 하면 이후 `ab -> eeee`
 연산을 하는데 영향을 주지 않는 것을 알 수 있다. 이런 관찰에 따라,
 교체 연산을 먼저 인덱스의 역순으로 정렬한 후에 차례로 수행하면 될 것
 같다.

```python
def findReplaceString(s, indices, sources, targets):
    res = s
    for idx, subs, tgt in sorted(zip(indices, sources, targets), reverse=True):
        if res.find(subs, idx) == idx:
            res = res[:idx] + target + res[idx + len(subs):]
    return res
```

 - `zip` 연산으로 세 교체 연산을 튜플로 묶었다. 이때 인덱스 정보를
   가장 앞쪽에 두어서 역순으로 정렬한다.
 - 조건에 따라 `string.find` 연산으로 부분 문자열이 있을 때에만 교체를
   한다. 이때, `find(subs)`가 아니라 `find(subs, idx)` 처럼 **시작
   인덱스**를 넘겨줘야 올바른 위치를 교체할 수 있다.
 - 파이썬의 슬라이싱 연산을 통해서 교체 결과 문자열을 쉽게 계산할 수
   있다. 반 열린 구간인 `[start, end)`를 뜻하는 `[start:end]`
   연산이므로, `res[:idx]`는 부분 문자열이 나타난 바로 직전까지의 부분
   분자열이고, `res[idx + len(subs):]`는 부분 문자열이 나타난 이후부터
   끝까지의 문자열이 된다.

 이렇게 하면 정렬에 `O(nlogn)`, 전체 반복에 `O(ns)` (`s`는 부분
 문자열의 최대 길이) 복잡도가 소요되고 이때 문제의 조건에 따라
 `logn`(=`log1000`)는 `s`(=50)보다 훨씬 작기 때문에 `O(sn)`이 최종
 복잡도가 된다.

## 정방향으로 수정하기

 그럼 역방향이 아니라 정방향으로는 어떻게 할 수 있을까? 여기서는
 파이썬의 동적인 성질을 이용해보자.

 먼저 입력 문자열을 쪼개서 글자의 리스트로 만든다. 예를 들어 `abcd`는
 `[a, b, c, d]`로 만든다. 그 후 순서에 상관없이 교체 연산을
 수행하는데, 이때 다음과 같이 진행한다.
 - 먼저 **원본 문자열**에서 연산에 쓰이는 부분 문자열이 있는지
   확인한다.
 - 교체해야 하는 경우, 먼저 `indices[i]` 부분의 인덱스에다 곧바로
   `targets[i]`를 덮어씌운다. 그 후 `sources[i]`의 **길이 만큼**
   글자의 리스트를 빈 글자로 만든다. 예를 들어 이전 예시의 `ab ->
   eeee` 교체 연산을 한다면, `[a, b, c, d]` 리스트를 `[eeee, '', c,
   d]`로 만든다.
 - 마지막으로 파이썬의 `join` 연산으로 글자 리스트를 하나의 문자열로
   합친다.

 이 아이디어를 구현하면 다음과 같다.

```python
def findReplaceString(s, indices, sources, targets):
    res = list(s)
    for idx, sub, tgt in zip(indices, sources, targets):
        if s.find(sub, idx) != idx:
            continue
        res[idx] = tgt
        for i in range(idx+1, idx+len(sub)):
            res[i] = ''
    return ''.join(res)
```
