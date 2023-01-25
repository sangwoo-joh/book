---
layout: page
tags: [problem-solving, theory, python, trie]
title: Trie
---

{: .no_toc }
## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

# Trie

 트라이 노드는 다음과 같이 구현할 수 있다.

```python
class Trie:
    class Node:
        def __init__(self, char=None):
            self.child = [None] * 26
            self.end = False

        def __getitem__(self, key):
            return self.child[ord(key) - ord('a')]

        def __setitem__(self, key, value):
            self.child[ord(key) - ord('a')] = value

        def __contains__(self, key):
            return True if self[key] else False

        def done(self):
            self.end = True

        def is_word(self):
            return self.end

    def __init__(self):
        self.sentinel = Trie()

    def add(self, word):
        node = self.sentinel
        for char in word:
            if char not in node:
                node[char] = Trie()
            node = node[char]
        node.done()

    def startswith(self, prefix):
        node = self.sentinel
        for char in prefix:
            if char not in node:
                return False
            node = node[char]
        return True
```

 - 알파벳 소문자만 담는 트라이다.
 - `__getitem__`, `__setitem__`을 오버라이딩 하여 `Trie[key]`와
   `Trie[key] = value`로 사용할 수 있도록 한다.
 - `__contains__`를 오버라이딩 하여 `key in Trie`와 `key not in Trie`
   테스트가 가능하도록 한다.
