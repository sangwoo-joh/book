---
layout: page
tags: [problem-solving, leetcode, python, string, hash-table, trie]
title: Short Encoding of Words
---

# [Short Encoding of Words](https://leetcode.com/problems/short-encoding-of-words/)

 단어 배열 `words`의 **유효한 인코딩**이란, 다음 조건을 만족하는 어떤
 레퍼런스 문자열 `s`와 인덱스의 배열 `indices`를 뜻한다:
 - `words.length == indices.length`
 - 레퍼런스 문자열 `s`는 `#`로 끝난다.
 - 각각의 인덱스 `indices[i]`에 대해서, `indices[i]`에서 시작해서 `#`
   직전에 끝나는 `s`의 **부분 문자열**은 `words[i]`와 같다.

 단어 배열 `words`가 주어졌을 때, `words`에서 만들 수 있는 모든 가능한
 유효한 인코딩 중에서 가장 짧은 레퍼런스 문자열 `s`의 길이를 구하자.

 단어 배열의 길이는 1~2,000 이고, 각 단어의 길이는 1~7이다. 단어는
 오직 알파벳 소문자로만 구성된다.

 예를 들어, `words = ["time", "me", "bell"]` 이라고 하자. 이로부터
 만들 수 있는 유효한 인코딩 중 가장 짧은 것은 `s = "time#bell#"`과
 `indices = [0, 2, 5]`, 또는 `s = "bell#time#"`과 `indices = [5, 7,
 0]`이다. 둘 모두 `s`의 길이는 10이므로 답은 10이다.

## 트라이 접근

 예시를 보면 `time`의 중간에 `me`가 있기 때문에 `time#** 하나로 이 두
 개의 단어를 인코딩할 수 있다. 즉, **접미사**를 공유하는 단어끼리는
 최대한 인코딩하는 것이 바로 해결책이다.

 그러면 접미사를 어떻게 구할 수 있을까? 트라이를 잘 구성하면
 된다. 일반적으로 *접두사*를 저장하는데 트라이를 사용하는데, 단어
 목록이 주어졌을 때 단어를 *역방향으로* 트라이를 구성하면 접미사를
 표현할 수 있다.

 그러면 주어진 단어 목록의 역방향, 즉 접미사의 트라이를 구했다면,
 이로부터 정답인 "가장 짧은 인코딩 문자열의 길이"는 어떻게 구할 수
 있을까? 먼저 우리가 관심이 있는 것은 단어의 *끝*이 아니라 단어의
 **길이**이므로, 트라이를 구성할 때 아예 단어의 길이를
 심어두자. 그러고 나면 트라이 전체를 탐색하면서, **모든 리프 노드에
 매달린 길이**를 합치면 우리가 원하는 답이 된다. 즉,

```
     (root of trie)
     /
    /
   e
   |
   m --- len: 2 (me)
   |
   i
   |
   t --- len: 4(time)
```

 위와 같은 트라이에서, 중간에 있는 길이 2가 아니라, 말단 노드에 있는
 길이 4를 원하는 것이다. 그리고 모든 말단 노드에 있는 단어가 곧 우리가
 원하는 인코딩에 쓰일 단어들의 목록이 된다.

 이 아이디어를 구현하면 다음과 같다.

```python
def minimumLengthEncoding(words):
    trie = {}
    for word in words:
        node = trie
        for letter in reversed(word):
            if letter not in node:
                node[letter] = {}
            node = node[letter]
        node['len'] = len(word)

    def dfs(node):
        if not node:
            return 0
        if 'len' in node and len(node) == 1:
            return node['len'] + 1
        acc = 0
        for letter in node:
            if letter == 'len':
                continue
            acc += dfs(node[letter])
        return acc

    return dfs(trie)
```

 - 단어를 거꾸로 (`reversed(word)`) 해서 트라이를 만들었고, 마지막
   리프 노드(즉, 원래 단어의 첫 글자)에는 단어의 길이를 매달아 둔다.
 - DFS로 모든 노드를 탐색하면서 답을 누적한다. 이때, 말단 노드의
   조건은 노드에 `len` 키 **만** 있는 것이기 때문에, `len`키가 있는지
   그리고 노드의 키 개수가 1인지를 확인하면 된다. 그러면 원하는 값은
   `단어의 길이 + 1` 인데, 이 `1` 은 `#`을 위한 길이이다.


## 해시 셋

 트라이를 적용하는 문제를 풀다가 느낀 점이, 꼭 트라이가 아니라 적당히
 정렬 또는 탐색 또는 해시로 풀어도 잘 풀리고 오히려 코드가 더 깔끔할
 때도 있다는 점이다. 여기서도 트라이가 아니라 다른 접근을 고민해보자.

 일단 단어를 빨리 검색하는 데에는 `O(1)`의 해시 셋이 있다. 해시 셋을
 이용해서, 예를 들어 `time`과 `me` 이 있다면 이 단어가 서로 접미사를
 공유하기 때문에 더 긴 단어인 `time`만 있어도 된다는 것을 확인할 수
 있으면 된다. 즉, `time`으로 만들 수 있는 모든 접미사인 `ime`, `me`,
 `e`를 해시 셋에서 다 빼버리면 우리가 원하는 단어 목록, **같은
 접미사**를 갖는 단어 중 가장 긴 단어만 남게 될 것이다. 이 문제에서는
 이렇게 얻을 수 있는 유효한 인코딩의 레퍼런스 문자열의 **최소 길이**만
 구하면 되기 때문에, 중간에 접미사(예를 들어 `me`)가 버려져도
 괜찮다. 어차피 최종 길이만 알면 된다.

 따라서 이 아이디어를 구현하면 다음과 같다.

```python
def minimumLengthEncoding(words):
    word_set = set(words)
    for word in words:
        for i in range(1, len(word)):
            suffix = word[1:]
            word_set.discard(suffix)

    return sum(len(word) + 1 for word in word_set)
```

 - 파이썬의 `set.discard`는 원소가 집합에 없어도 된다는 점만 빼면
   `set.remove`과 같다. 즉, 없는 원소를 호출해도 익셉션이 발생하지
   않는다. 어떤 원소가 집합에 없도록 만드는 데에 쓰기 좋다.
 - 파이썬의 슬라이싱 연산자를 이용해서 단어의 모든 접두사는 쉽게 만들
   수 있다.
