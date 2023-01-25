---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Find and Replace Pattern
---

# [Find and Replace Pattern](https://leetcode.com/problems/find-and-replace-pattern/)

 단어 목록 `words`와 문자열 `pattern`이 주어진다. 이때 `pattern`과
 *매치* 되는 단어 목록을 구하자. 단어 목록의 순서는 상관없다.

 어떤 단어가 패턴과 *매치*된다는 것의 의미는 다음과 같다: 단어에
 등장하는 글자 `x`를 다른 글자로 교체하는 어떤 순열(permutation)이
 존재해서, `p(x)`를 적용하면 두 단어가 같아지는 것이다. 이때 서로 다른
 글자가 같은 글자로 맵핑되면 안된다.

 단어와 패턴의 길이는 1~20이고 단어 목록의 크기는 1~50이다. 모두
 알파벳 소문자만 담고 있다.

 예를 들어 단어 "mee"는 패턴 "abb"와 매칭된다. a -> m, b -> e로 맵핑할
 수 있기 때문이다. 반면 "mem"과는 매칭되지 않는다.

## Alpha Conversion

 글자를 세거나 글자 위치를 찾는 문제랑은 다른 종류의 문제다. 설명에
 "교체(replace)"라는 단어가 있는데, 여기에 현혹되어서 진짜 글자랑 글자
 사이의 맵핑을 구하면 안된다.

 "글자 개수만 맞으면 되지 않을까?"라고 생각했는데, 같은 개수의
 글자라도 *상대적인 순서*가 중요하다는 걸 알았다. 그렇게 좀
 생각하다보니 이 문제는 PL에 친숙한 문제인 [Alpha
 Conversion](https://en.wikipedia.org/wiki/Lambda_calculus#%CE%B1-conversion)과
 같다는 것을 깨달았다.

 여기서는 De Bruijin 인덱스까지 쓸 필요는 없고 (애초에 Lambda
 Abstraction이 없으니), 그냥 왼쪽부터 쭉 읽어가면서 글자를 만나는
 순서대로 인덱스를 매기면 될 것 같다. 최종적으로는 하나의 비교 가능한
 튜플을 만들어 낸다면 단어 목록에서 필터해버리면 된다.

```python
def findAndReplacePattern(words, pattern):
    def alpha_conv(word):
        id_map = {}
        i = 0
        res = []
        for letter in word:
            if letter not in id_map:
                id_map[letter] = i
                i += 1
            res.append(id_map[letter])
        return tuple(res)

    palpha = alpha_conv(pattern)
    return list(filter(lambda word: alpha_conv(word) == palpha, words))
```
