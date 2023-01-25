---
layout: page
tags: [problem-solving, leetcode, python, tree, trie]
title: Implement Trie
---

# [Implement Trie](https://leetcode.com/problems/implement-trie-prefix-tree/)

 제목 그대로 트라이를 구현하는 문제다.

 - `Trie()`: 생성자
 - `void insert(String word)`: `word`를 추가
 - `boolean search(String word)`: `word`가 트라이에 있으면 `true`,
   아니면 `false`
 - `boolean startsWith(String prefix)`: `prefix`로 시작하는 단어가
   있으면 `true`, 없으면 `false`
 - 모든 단어와 접두어는 소문자 영어로만 구성되며, 길이는 2천을 넘지
   않는다.
 - 최대 $$ 3 \times 10^4 $$ 번의 `insert`, `search`, `startsWith` 함수
   호출이 일어난다.


## 구현

 특별한 것은 없고 파이썬에서 트라이를 구현할 때의 팁이랄지 유의해야 할
 부분만 조심하면 되겠다.

```python
class Trie:
    class Node:
        def __init__(self):
            self.child = [None] * 26
            self.end = False

        def __getitem__(self, key):
            return self.child[ord(key) - ord('a')]

        def __setitem__(self, key, value):
            self.child[ord(key) - ord('a')] = value

    def __init__(self):
        self.trie = Trie.Node()

    def insert(self, word):
        node = self.trie
        for char in word:
            if node[char] is None:
                node[char] = Trie.Node()
            node = node[char]
        node.end = True

    def search(self, word):
        node = self.trie
        for char in word:
            if node[char] is None:
                return False
            node = node[char]
        return node.end

    def startsWith(self, prefix):
        node = self.trie
        for char in word:
            if node[char] is None:
                return False
            node = node[char]
        return True
```

### `Trie.Node`

 트라이의 노드를 따로 구현했다. `Trie` 트라이 안에 구현했기 때문에
 호출할 때에는 `Trie.Node`로 경로를 다 줘야한다.

 입력 단어가 모두 소문자 알파벳으로만 구성되기 때문에 자식 노드를
 26개의 `None`으로 초기화한다. `end` 필드는 지금 노드의 위치가 단어의
 끝인지 아닌지를 기록한다.

 파이썬의 클래스 어트리뷰트에는 `__getitem__`과 `__setitem__`이
 있다. 이 어트리뷰트 함수를 적절히 오버로딩해서 트라이 노드의 자식에
 접근하거나 자식 노드에 새 노드를 추가할 때 번거로운 계산을 이쪽으로
 빼둘 수 있다. 파이썬에는 문자 타입이 없기 때문에, C처럼 char 타입을
 int 대신 써서 아스키코드를 곧바로 쓰고.. 이런건 못한다. 대신 `ord`
 라는 함수를 통해서 문자열의 아스키 코드 값을 직접 계산해야 한다. 자식
 노드는 리스트로 관리하기 때문에 `ord('a')`를 빼줘야 올바른 0-인덱스가
 된다. 이걸 `__getitem__`과 `__setitem__` 모두에 적용하면 된다.

### `insert`

 `word`의 각 문자에 대해서 트라이 노드를 쭉 따라간다. `node[char]`는
 `__getitem__`으로 해석되고 따라서 자식 노드를 바로 빼올 수
 있다. `None`이면 아직 자식이 추가 안된거니 `node[char] = ...` 를
 이용해서 `__setitem__`을 호출하여 자식 노드를 만들어 둔다.

 이렇게 `word`의 끝까지 순회하면서 트라이 노드를 함께 움직이고 나면
 `node`는 단어의 마지막 문자의 노드를 가리킨다. 따라서, `node.end =
 True`로 기록해야 이 단어가 해당 노드에서 끝난다는 것을 기록할 수
 있다.

### `search`, `startsWith`

 `search`와 `startsWith`은 딱 하나만 빼고 동일하다: 입력 단어를 따라
 트라이 노드를 쭉 이동했을 때, 해당 노드가 단어의 끝인지 아닌지를
 판단해야 하는지 여부다. `search`는 이걸 판단해야 하고 `startsWith`는
 곧바로 `True`를 리턴하면 된다. 왜냐하면 해당 문자들로 시작하는 단어가
 아예 없었다면 애초에 자식 노드가 `None`이었을 것이기 때문이다.
