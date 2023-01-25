---
layout: page
tags: [problem-solving, leetcode, python, string, dynamic-programming]
title: Delete Operation for Two Strings
---

# [Delete Operation for Two Strings](https://leetcode.com/problems/delete-operation-for-two-strings/)

 두 문자열 `word1`과 `word2`가 주어졌을 때, `word1`과 `word2`를 같은
 문자열을 만들기 위한 삭제 연산의 최소 횟수를 구하자.

 한 번의 연산에서는 두 문자열 중 하나에서 딱 하나의 글자를 삭제할 수
 있다.

 문자열의 길이는 최대 500이고 알파벳 소문자만 담고 있다.

## LCS

 처음에 이 문제를 읽었을 때 "그냥 두 문자열에서 공통되는 글자만 남기면
 그게 답 아닌가?" 싶어서 다음과 같이 짰었다.

```python
from collections import Counter
def minDistance(word1, word2):
    intersect = Counter(word1) & Counter(word2)
    return len(word1) + len(word2) - sum(intersect.values()) * 2
```

 하지만 이렇게하니 바로 반례가 튀어나온다: "sea"와 "ate".

 즉, 위와 같이 공통된 글자만 남겨버리면, 글자 간의 *순서*를
 무시해버리기 때문에 올바른 답을 구할 수 없다.

 이 문제는 [공통 부분열의 최장 길이](../longest-common-subsequence)
 문제를 응용하면 쉽게 풀린다. 즉, 최소의 삭제 연산으로 남기는 최종
 결과물이 곧 두 문자열의 공통 부분열 중 가장 긴 문자열인
 것이다. 따라서, LCS를 알면 위의 틀린 접근의 수식과 거의 유사한
 방법으로 풀 수 있다.

```python
import functools
def minDistance(word1, word2):
    @functools.cache
    def lcs(i1, i2):
        if i1 == len(word1) or i2 == len(word2):
            return 0

        if word1[i1] == word2[i2]:
            return 1 + lcs(i1 + 1, i2 + 1)
        else:
            return max(lcs(i1 + 1, i2), lcs(i1, i2 + 1))

    return len(word1) + len(word2) - lcs(0, 0) * 2
```
