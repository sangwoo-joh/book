---
layout: page
tags: [problem-solving, leetcode, python, string, dynamic-programming]
title: Longest String Chain
---

# [Longest String Chain](https://leetcode.com/problems/longest-string-chain/)

 알파벳 소문자로만 이뤄진 단어 목록 `words`가 주어진다.

 단어 `word_a`의 어떤 위치든 **딱 한 글자**만 추가하고 **다른 단어의
 순서를 바꾸지 않으면서** `word_b`를 만들 수 있으면, `word_a`는
 `word_b`의 **predecessor**라고 한다. 예를 들면, "abc"는 "abac"의
 predecessor이지만 "cba"는 "bcad"의 predecessor가 아니다.

 **단어 체인**이란 `k >= 1`에 대한 단어의 수열 `[word_1, word_2, ...,
 word_k]`이면서, 어떤 `i`에 대해서 `word_i`가 `word_(i+1)`의
 predecessor인 것을 말한다. 정의에 따라 단어 하나인 목록은 `k == 1`인
 단어 체인이 된다.

 주어진 단어 목록에서 만들 수 있는 **가장 긴 단어 체인의 길이**를
 구하자.

 단어 목록의 크기는 최대 1,000 이고 단어 하나의 길이는 최대
 16이다. 모두 알파벳 소문자만 담고 있다.

## 탑 다운 다이나믹 프로그래밍

 Predecessor 때문에 그래프 문제인가 싶었지만 다이나믹 프로그래밍
 문제다. 힌트를 다 까봤는데, predecessor를 순서대로, 즉 어떤 단어에서
 가능한 모든 글자를 모든 위치에 하나 씩 추가해가면서 만들기 보다는,
 반대로 어떤 단어에서 **한 글자씩 빼서** 거꾸로 만들어 보라고
 하더라. 그래서 이것저것 코드 구조를 잡아 봤는데 잘 안되어서 솔루션을
 보고 무릎을 탁 쳤다.

 일단 단어 `word`가 주어졌을 때, 여기서 한 글자씩 빼서 만들 수 있는
 모든 predecessor를 만드는 것은 파이썬에서 다음과 같이 할 수
 있다. 파이썬이 half-open interval로 시퀀스를 표현하기 때문에
 가능하다.

```python
for i in range(len(word)):
    pred_cand = word[:i] + word[i+1:]
```

 그러면 힌트에 충실하게 거꾸로 만들어가는 과정을 고민해보자. 어떤
 단어가 주어졌을 때, 그 단어와 주어진 단어 목록을 가지고 만들 수 있는
 단어 체인의 길이 중 가장 긴 것을 구하는 함수 `max_word_chain`을
 만들자. 한 글자를 빼서 만든 predecessor 후보 단어가 단어 목록에
 없으면, 정의에 따라 가장 긴 단어 체인의 길이는 1이 된다. 그렇지 않은
 경우, 다음과 같은 점화식이 성립한다: `1 +
 max_word_chain(pred_cand)`. 문제의 조건에 따라 주어진 단어 목록만 쓸
 수 있기 때문에, 단어 하나에 대해서 단어 체인의 최대 길이를 구할 때
 발생하는 모든 부분 문제는 반복되어 나온다. 따라서 이 부분을 캐싱하면
 아주 빠르게 구할 수 있다.

```python
from functools import cache
def lognestStrChain(words):
    word_set = set(words)

    @cache
    def max_word_chain(word):
        maxlen = 1
        for i in range(len(word)):
            pred_cand = word[:i] + word[i+1:]
            if cand in word_set:
                maxlen = max(maxlen, 1 + max_word_chain(cand))
        return maxlen

    answer = 0
    for word in words:
        answer = max(answer, max_word_chain(word))
    return answer
```

 - 단어 목록을 미리 해시 셋으로 만들어 둔다. 그러면 단어에서 한 글자를
   뺀 predecessor 후보 단어가 주어진 단어 목록에 있는지 `O(1)`만에
   확인할 수 있다.
 - 단어 목록 전체를 훑을 때 단어 순서는 상관이
   없다. `max_word_chain`이 구하려고 하는 것은 어떤 단어에서 **글자를
   하나씩 빼가면서** 만들 수 있는 단어 체인의 길이 중 최대를 구하는
   것이기 때문이다. 만약 바텀 업 접근이라면 단어를 방문하는 순서도
   영향을 미칠 것이다.
