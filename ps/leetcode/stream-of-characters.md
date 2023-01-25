---
layout: page
tags: [problem-solving, leetcode, python, trie]
title: Stream of Characters
---

# [Stream of Characters](https://leetcode.com/problems/stream-of-characters/)

 먼저 단어 목록 `words`가 주어진다. 그 후 문자의 스트림이
 들어온다. 이때, 문자 스트림의 접미사가 이 단어 목록 중 하나의 단어와
 일치하는지를 판단하자.

 예를 들어, 단어 목록이 `[abc, xyz]`이고 스트림이 `a, x, y, z` 라면,
 `xyz` 접미사가 단어 목록에 존재함을 알 수 있다.

 `StreamChecker`의 두 가지 함수를 구현해야 한다.
 - `StreamChecker(String[] words)`: 단어 목록을 가지고 초기화
 - `boolean query(char letter)`: 새로운 문자를 입력 받는다. 이전까지
   입력받은 스트림까지 포함해서, 단어 목록 중 하나가 접미사가 된다면
   `True`를 리턴한다.


 각 단어의 길이는 1~2,000 이고 단어 목록의 크기는 1~2,000 이다. 단어와
 스트림은 모두 영문 소문자만 포함한다. 최대 $$ 4 \times 10^4 $$ 번의
 `query` 함수가 호출된다.

## 트라이

 접미사가 아니라 접두사라면, 이 문제는 [트라이](../../theory/trie)를
 이용해서 쉽게 풀 수 있다. 하지만 *접미사*인 점이 까다롭다.

 더 큰 문제는, 우리가 탐색해야 할 공간이 고정된 길이의 문자가 아니라
 지속적으로 입력이 들어오는 *스트림* 이라는 점이다. 그럼 어떻게
 해야할까?

 한 가지 관찰은, 단어 목록의 **끝 문자**와 항상 매칭이 되어야 한다는
 점이다. 즉, 우리는 **접미사**를 찾아야 한다. 이 관찰로부터, 뭔가
 트라이와 스트림에서 **거꾸로** 연산을 적용하는 아이디어를 얻을 수
 있다.

 먼저, 트라이 사전을 만들 때, 단어를 **뒤집어서** 만들어둔다. 그러면
 어떤 단어가 들어왔을 때, 그 단어의 끝에서부터 트라이를 매치한다면
 단어의 접미사가 트라이 사전에 있는지 확인할 수 있을 것이다. 따라서,
 **스트림 역시 뒤집어서** 관리하면 가능해 보인다.

 이 알고리즘을 구현하면 다음과 같다.

```python
class Trie:
    def __init__(self):
        self.child = [None] * 26
        self.end = False
    def __getitem__(self, key):
        return self.child[ord(key)-ord('a')]
    def __setitem__(self, key, value):
        self.child[ord(key)-ord('a')] = value
    def __contains__(self, key):
        return bool(self[key])
    def done(self):
        self.end = True
    def is_word(self):
        return self.end

from collections import deque
class StreamChecker:
    def __init__(self, words):
        self.sentinel = Trie()
        self.stream = deque()
        for word in words:
            self.add(word)

    def add(self, word):
        node = self.sentinel
        for char in reversed(word):
            if char not in node:
                node[char] = Trie()
            node = node[char]
        node.done()

    def query(self, letter):
        self.stream.appendleft(letter)
        node = self.sentinel

        for char in self.stream:
            node = node[char]
            if node is None:
                return False
            if node.is_word():
                return True
```

 - `StreamChecker`에 `add()` 함수를 추가해서 단어를 하나씩 트라이
   사전에 넣도록 했다. 이때, 단어를 뒤집어서 넣는다.
 - `query` 에서는 먼저 `letter`를 `stream`의 앞쪽에 넣는다. 즉,
   스트림을 거꾸로 유지한다. 그 후 스트림을 훑으면서 접미사 검사를
   거꾸로 수행한다. 중간에 하나라도 노드가 없다면 거짓이다. 중간
   노드가 단어의 끝(즉, 뒤집은 접미사의 끝 == 올바른 접두사의
   시작)이라면, 참이다. 스트림 문자의 체크는 무조건 이 둘 중 하나의
   조건에 걸리기 때문에, 항상 루프 안에서 리턴된다.
 - 여기서는 스트림을 거꾸로 유지하는데 큐를 썼지만, 그냥 리스트에 때려
   박고 거꾸로 루프를 순회해도 된다.
