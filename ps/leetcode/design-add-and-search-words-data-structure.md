---
layout: page
tags: [problem-solving, leetcode, python, tree, string]
title: Design Add and Search Words Data Structure
---

# [Design Add and Search Words Data Structure](https://leetcode.com/problems/design-add-and-search-words-data-structure/)

 새로운 단어를 사전에 추가하는 기능과, 사전에서 단어를 검색하는 기능을
 지원하는 데이터 구조를 구현하자. `WordDictionary` 클래스에는 다음
 함수가 있다.
 - 생성자
 - `void addWord(word)`: 단어 추가
 - `bool search(word)`: 단어 검색

 단어의 길이는 1~25이고 모두 알파벳 소문자로만 이뤄진다. 검색할
 단어에는 `.`이 포함될 수 있는데, 이는 모든 알파벳과
 매칭된다. 검색에는 최대 3개의 `.`이 포함될 수 있다. 최대 $$10^4$$번의
 함수 호출이 이뤄지는 환경을 고려하자.

## 트라이

 요런 검색 문제는 보통 트라이가 가장 쉬운 접근이다. 단어가 추가될
 때마다 트라이에 단어를 추가하면 된다. 단, 고려해야 하는 부분은 바로
 검색에서 `.`이 있는 부분이다. 모든 알파벳이 매칭될 수 있기 때문에,
 검색 부분을 잘 구현해야 한다.

```python
class WordDictionary:
    def __init__(self):
        self.trie = {}

    def addWord(self, word):
        node = self.trie
        for letter in word:
            if letter not in node:
                node[letter] = {}
            node = node[letter]
        node['$'] = True

    def search(self, word):

        def dfs(node, idx):
            if not node:
                return False
            if idx == len(word):
                return '$' in node

            letter = word[idx]
            if letter == '.':
                for key in node:
                    if key != '$' and dfs(node[key], idx + 1):
                        return True
                return False
            if letter not in node:
                return False
            return dfs(node[letter], idx + 1)
        return dfs(self.trie, 0)
```

 - 트라이는 간단히 딕셔너리로 구현했다. 단어의 끝을 알리기 위해서
   특별한 키 `$`를 사용했다.
 - 검색 함수의 경우 DFS로 구현했는데, 베이스 케이스와 다음 공간을 잘
   구분해야 한다. 특히 인덱스가 단어의 끝에 왔을 때에는 `$` 키가
   있는지를 확인해야 한다. 현재 단어가 `.`일 때에는 모든 키에 대해서
   DFS를 수행해야 한다. 이때 Early Return을 위해서 중간에 단어를
   찾으면 곧바로 리턴한다.

 이렇게하면 기능은 잘 구현하긴 한데, 이런 트라이 문제를 풀 때마다
 느끼는게 생각보다 트라이가 빠르진 않은 것 같다. 데이터가 더 큰
 상황에서 잘 동작하려나? 아무튼 10초 이상이 걸린다.

## 탐색

 그러면 좀더 빠르게, 좀더 똑똑하게 탐색하는 방법을 생각해보자.

 일단 프루닝을 생각해보자. 가장 먼저 떠오르는 것은 검색 단어에 `.`이
 없는 경우이다. 이때는 곧바로 사전에서 탐색해볼 수 있다.

 문제의 조건에서 단어의 길이가 최대 25인 것을 활용해보자. 최대 10,000
 번이 호출되기 때문에 데이터가 잘 분포되어 있다면 같은 길이의 단어가
 10,000 / 25 = 400개가 될 것이라고 기대할 수 있다. 400개는 리얼
 월드에서는 아주 적은 데이터이고, 이 정도 사이즈에서 탐색/정렬하는
 것은 아주 값싼 작업이다. 이 관찰을 근거로, 사전을 트라이가 아니라
 같은 단어끼리 묶어서, 일종의 버킷을 만들어서 관리할 수 있다.

 이렇게하면 `.`가 포함되지 않았을 때의 단어 검색은 해시 테이블과 해시
 셋을 이용해서 `O(1)`에 가능하다. 문제는 `.`인데, 이때는 특별한
 방법없이 일일이 다 검색해도 좋다.

```python
from collections import defaultdict
class WordDictionary:
    def __init__(self):
        self.buckets = defaultdict(set)

    def addWord(self, word):
        self.buckets[len(word)].add(word)

    def search(self, word):
        if '.' not in word:
            return word in self.buckets[len(word)]

        candidates = self.buckets[len(word)]
        for cand in candidates:
            for cand_letter, word_letter in zip(cand, word):
                if word_letter != '.' and cand_letter != word_letter:
                    break
            else:
                return True
        return False
```

 - 검색 키워드에 `.`가 있는 경우, 단어 길이의 버킷에서 후보 목록을 다
   꺼내와서 일일이 맞춰본다. 이때 Early Return을 위해서 파이썬의 [`for
   else`](https://book.pythontips.com/en/latest/for_-_else.html)
   구문을 사용하고 있다. `for` 반복문이 **정상적으로 완료되고 나면**
   `else` 부분을 실행한다. 만약 도중에 `for` 반복문 안에서 `break`가
   일어나서 강제적으로 루프를 빠져나온다면 `else`는 실행되지
   않는다. 즉, 검색 키워드와 단어 후보를 매칭하면서 키워드의 글자가
   `.`이 아닌데 단어 후보의 글자와 다르면 빠져나오고, 그렇지 않으면
   `for` 반복문을 끝까지 수행하게 되는데 이 케이스가 바로 매칭되는
   단어를 찾은 경우이고 `else`에 들어갈 수 있다.
