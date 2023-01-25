---
layout: page
tags: [problem-solving, leetcode, python, tree, trie]
title: Design Search Autocomplete System
---

# [Design Search Autocomplete System](https://leetcode.com/problems/design-search-autocomplete-system/)

 말 그대로 검색 엔진의 자동완성 시스템을 디자인하고 구현하는 문제다.

 먼저 기존의 레거시가 입력으로 들어온다. 문장 배열 `sentences`와 해당
 문장이 몇 번 나타났는지를 나타내는 `times` 배열이
 들어온다. `sentences[i]`는 `times[i]`번 과거에 검색되었다. 두 배열의
 길이는 같다.

 각 입력은 한 글자씩 타이핑 된다. 특수 문자 `#`는 입력의 끝을 알리는
 것이다. 매 타이핑마다 과거의 기록 중 지금까지 타이핑한 문장이
 접두사로 일치하는 문장 중에서 가장 많이 검색된 것 탑 3를 찾아서
 리턴한다.

 - 문장의 "핫한 정도(hot degree)"는 정확히 같은 문장을 유저가 이전에
   몇 번이나 타이핑했는지에 따라 결정된다.
 - 핫한 정도에 따라 정렬된 문장 중 탑 3를 리턴한다. 같은 문장이 여러
   개 있다면 아스키 코드 순으로 정렬한 것이 먼저 나온다.
 - 탑 3개 3개 미만이라면 최대한 많이 찾아서 리턴한다.
 - 특수문자 `#`는 문장이 끝났다는 의미이며, 이 때는 빈 리스트를
   리턴한다.
 - 특수문자 `#`가 나오기 이전까지 작성한 문장은 히스토리에 기록되어야
   한다.

 입력으로 주어지는 문장 개수는 1~100개다. 최대 5천번의 함수 호출이
 이루어진다. 문장은 소문자 영어와 공백 뿐이다. 입력은 소문자 영어와
 공백, `#` 뿐이다.

## 트라이
 이 문제를 푸는 방법은 트레이드 오프에 따라 크게 두 가지가
 있다. 하나는 메모리를 왕창 써서 시간 복잡도를 줄이는 것이고, 다른
 하나는 메모리를 아끼는 대신 시간 복잡도를 조금 희생하는 것이다. 먼저
 메모리를 왕창 희생하는 버전을 보자.

 접두사가 일치하는 ... 이라는 문장에서 대놓고 힌트를 주듯이, 이 문제는
 트라이를 도입해서 풀 수 있다. 추가로 트라이의 각 노드에 부가적인
 정보를 매달아두면 메모리를 희생해서 복잡도를 잡을 수 있을 것 같다.

 그럼 각 노드에는 뭘 매달아야 할까? "핫한 정도"를 곧바로 매달면
 안될까? 문제의 조건에 따라 `#`로 문장이 끝나면 **입력된 문장이
 히스토리에 기록되어야**하기 때문에, 단순한 접근으로는 어렵다.

 처음에는 힙을 도입해서 검색 횟수대로 딱 3개만 남기려고 했는데, 아래
 두 가지 트레이드 오프가 있다.
 - 딱 3개만 남기면 문제의 조건을 만족하지 못한다. 예를 들어, 횟수만
   봤을 때 (3, 3, 2) 의 탑 3개만 유지하고 있었는데 만약 횟수 순으로
   4번째가 2회였고, 이번 입력으로 1이 증가된다면? 순서가 바뀌어야
   한다. 따라서, "탑 3"라고 해서 정말로 세개만 추적하면 안된다. 다
   기록해야 한다.
 - 힙은 가장 순서가 많은(혹은 적은) 딱 한가지 원소를 곧바로 빼올 때에
   유용하다. 우리는 탑 3개가 필요하고, 계속 기존 원소의
   우선순위(횟수)가 업데이트 되어야 한다. 뭔가 해킹할 여지는 있지만
   그러고 싶진 않다.

 그래서, 가능한 방법은 아래 두 가지이다.
 1. 메모리를 적당히 희생하는 방법: 트라이의 각 노드에 횟수를 기록하고,
    입력이 들어오면 일단 (횟수, 문장)을 전부 복원한 다음 횟수 순으로
    정렬해서 탑 3를 구하는 방법
 2. 메모리를 많이 희생하는 방법: 트라이의 각 노드에 해당 접두사를 갖는
    문장의 횟수를 전부 기록해두고, 입력이 들어오면 바로 정렬해서 탑
    3를 구하는 방법

 쉽게 말해 1번은 트라이 위에서 DFS/BFS를 이용해서 매번 문장을 다
 복원해준 뒤에 정렬하는 방법이고, 2번은 문장과 횟수를 노드마다 다
 유지해서 곧바로 정렬하는 방법이다. 1번이 그나마 메모리를 덜 쓰지만,
 매번 탐색해야 하고, 2번은 메모리를 엄청나게 쓸 것 같지만 탐색을
 덜한다.

 여기서는 2번으로 구현해 보았다.

```python
from collections import Counter
class Trie:
    class Node:
        def __init__(self):
            self.children = [None] * 27
            self.counts = Counter()
        def __contains__(self, key):
            return self[key] is not None
        def __getitem__(self, key):
            idx = ord(key) - ord('a') if ord('a') <= key <= ord('z') else 26
            return self.children[idx]
        def __setitem__(self, key, value):
            idx = ord(key) - ord('a') if ord('a') <= key <= ord('z') else 26
            self.children[idx] = value

        def update(self, sentence, time=1):
            self.counts[sentence] += time

    def __init__(self, sentences, times):
        self.sentinel = Trie.Node()
        for s, t in zip(sentences, times):
            self.add(s, t)
    def add(self, sentence, time=1):
        node = self.sentinel
        for char in sentence:
            if char not in node:
                node[char] = Trie.Node()
            node = node[char]
            node.update(sentence, time)

    def top3(self, sentence):
        node = self.sentinel
        for char in sentence:
            if char not in node:
                return []
            node = node[char]
        return [n[0] for n in sorted(node.counts.items(), key=lambda x: (-x[1], x[0]))][:3]

class AutocompleteSystem:
    def __init__(self, sentences, times):
        self.trie = Trie(sentences, times)
        self.query = []
    def input(self, c):
        if c == '#':
            self.trie.add(''.join(self.query))
            self.query.clear()
            return []
        else:
            self.query.append(c)
            return self.trie.top3(self.query)
```
 - `top3` 함수는 매번 정렬을 한다. 이때 조건에 따라 (1) 횟수 기준
   오름차순, (2) 아스키코드 기준 내림차순으로 정렬하기 위해서 키로
   튜플을 넘겨준다.
 - `add` 함수는 문장을 넣을 때마다 모든 노드에 매달린 문장 횟수를
   업데이트 한다.

 이렇게하면 통과하긴 하지만, 문제의 입력이 생각보다 작아서 오히려
 시간이 그렇게 빠르지 않다.

## 매번 정렬
 그래서 두 번째 방법인, 메모리를 덜 쓰면서 시간 복잡도를 조금
 희생하는, 입력의 부분을 유지하면서 매번 정렬하는 방법을
 적용해보았다. 사실 이게 코드도 더 깔끔하고 입력이 작을 때 더
 빠르다. 파이썬 팀소트의 위력이다.

```python
from collections import Counter
class AutocompleteSystem:
    def __init__(self, sentences, times):
        self.query = []
        self.matches = []
        self.counts = Counter()
        for s, t in zip(sentences, times):
            self.counts[s] = t
    def input(self, c):
        if c == '#':
            s = ''.join(self.query)
            self.counts[s] += 1
            self.query.clear()
            self.matches = []
            return []

        if not self.query:
            self.matches = [(-c, s) for s, c in self.counts.items() if s[0] == c]
            self.matches.sort()
            self.matches = [s for _, s in self.matches]
        else:
            i = len(self.query)
            self.matches = [s for s in self.matches if len(s) > i and s[i] == c]

        self.query.append(c)
        return self.matches[:3]
```

 여기서의 핵심 아이디어는 쿼리가 비어있을 때, 즉 첫 글자가 들어왔을 때
 처리하는 로직이다. 먼저 이전까지의 횟수를 세어둔 `counts`
 딕셔너리에서 `(-횟수, 문장)`을 꺼내와서 원하는 순서로 정렬한
 `matches`를 만든다. 이때, **첫 글자가 지금 입력한 문자**인 애들만
 필터링한다. 그 다음 횟수를 드랍하고 문장만 냄겨둔다. 그 후 입력이
 들어오면, 이때까지 쌓아둔 쿼리의 길이를 이용해 문장에서 봐야하는
 접두사 인덱스를 알 수 있고, 이를 이용해서 매번 `matches`를
 필터링하기만 하면 된다. 이미 우리가 원하는 순서로 정렬을 해 두었기
 때문에, 여기서 필터링 되면 그냥 걔는 접두사 매치가 안된
 것이다. 이러면 매번 정렬하지 않아도 되고, 마지막에 `[:3]`로 최대
 3개만 리턴하면 된다.

 트라이보다 이게 훨씬 빠르게 동작한다.
