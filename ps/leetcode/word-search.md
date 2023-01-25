---
layout: page
tags: [problem-solving, leetcode, python, string, matrix, backtracking, trie]
title: Word Search
last_update: 2023-01-25 18:30:00
---

# [Word Search](https://leetcode.com/problems/word-search/)

 `m x n` 크기의 글자 보드 `board`와 단어 `word`가 주어진다. 보드에 이
 단어가 있는지 없는지를 확인하자.

 단어는 인접한 칸에 있는 글자를 연결해서만 만들 수 있다. 인접한 칸이란
 어떤 칸을 기준으로 위, 아래, 오른쪽, 왼쪽에 있는 이웃 칸을
 뜻한다. 글자를 만들 때는 같은 칸을 두 번 이상 쓸 수 없다.

 m, n은 모두 1~6 사이의 값이고 단어의 길이는 15이다. 모두 알파벳
 소문자로 이루어져 있다.

## 백트래킹

 보드를 탐색하는 백트래킹 문제이다. 어디서 글자가 완성될지 모르기
 때문에 보드를 전부 다 훑긴 해야한다. 하지만 목표가 딱 정해져있기
 때문에, 즉 "단어"를 완성하는 것이기 때문에, 많은 탐색 공간을 프루닝할
 수 있다.

 백트래킹 함수 `backtrack(row, col, wid)`에 대해서, 베이스 케이스를
 생각해보자. `(row, col)`은 지금 상태에서 방문할 보드의 위치이고,
 `wid`는 지금까지 매칭된 단어의 인덱스이다.
 - 단어를 끝까지 다 훑었으면 당연히 `True`이다.
 - 보드 위치가 보드 사이즈를 벗어났으면 더 이상 단어를 매칭할 수
   없다는 의미이므로 `False`이다.
 - 이제 가능한 다음 칸을 모두 재귀적으로 찾을 것인데, 도중에 단어가
   매칭되었다면 더 이상 다른 공간을 탐색할 필요가 없다. 바로 `True`를
   리턴하면 된다.

 단, 한 가지 주의할 점은 조건에 따라 단어를 만들 때 **같은 칸을 두 번
 이상 쓸 수 없다**는 점이다. 이것은 까다롭게 구현할 필요없이,
 백트래킹을 시작하기 전 지금 방문한 칸의 글자를 다른 글자(`#` 같은)로
 잠깐 수정했다가, 백트래킹이 끝나고 나면 다시 원복하는 방법이 주로
 쓰인다.

 이 방법을 구현하면 다음과 같다.

```python
def exist(board, word):
    n, m = len(board), len(board[0])

    def backtrack(row, col, wid):
        if wid == len(word):
            return True

        if row < 0 or row >= n or col < 0 or col >= m:
            return False

        if board[row][col] != word[wid]:
            return False

        board[row][col] = '#'
        res = False
        for dx, dy in ((1, 0), (0, 1), (-1, 0), (0, -1)):
            res = backtrack(row + dx, col + dy, wid + 1)
            if res:
                break
        board[row][col] = word[wid]
        return res

    for row in range(n):
        for col in range(m):
            if backtrack(row, col, 0):
                return True
    return False
```

---

 여기서 보드가 엄청 커졌을 때 추가적인 프루닝을 할 수 있을까? 몇 가지
 떠오르는 방법은 다음과 같은 것들이 있다:
 - 사이즈 체크. `n * m` 보다 단어 길이가 크면 불가능하기 때문에 곧바로
   `False`이다. 그런데 이건 보드 사이즈가 커졌을 때에는 별로 소용이
   없을 것 같다.
 - 알파벳 체크. 보드에 있는 글자 집합에 단어에 있는 글자 집합이
   속하는지를 확인하면 곧바로 `False`인 경우를 알 수 있다. 즉, 단어에
   있는 글자 중 일부가 보드에 속하지 않는다면, 어차피 보드를
   탐색해봐도 소용없음을 알 수 있다.
 - 탐색하면서 알파벳 체크. 아무리 생각해도 보드가 커졌을 때 가능한
   프루닝은 이 방법 뿐이다. 어차피 보드 전체를 한번은 탐색해야
   한다. 그러면 보드 전체에 대해서 백트래킹을 하기 전에, 보드 전체에
   대해서 각 칸이 가망있는 칸인지, 즉 단어에 포함되는 글자인지를 미리
   계산해둘 수 있다. 그러면 다시 전체 보드 칸에 대해서 각각 백트래킹을
   할 때, 다음 칸이 가망있을 때에만 가면 된다.

# [Word Search II](https://leetcode.com/problems/word-search-ii/)

 `m x n` 크기의 글자 보드 `board`와 단어 목록 `words`가
 주어진다. 이때, 단어 목록에 포함되면서 보드에서 만들 수 있는 모든
 단어 목록을 구하자.

 각각의 단어는 인접한 칸에 있는 글자를 연결해서만 만들 수 있다. 인접한
 칸이란 어떤 칸을 기준으로 위, 아래, 왼쪽, 오른쪽에 있는 이웃 칸을
 뜻한다. 같은 글자 칸은 한 단어를 만드는데 딱 한번만 쓰일 수 있다.

 보드와 단어는 모두 알파벳 소문자로만 이뤄진다. 단어 목록은 최대 $$ 3
 \times 10^4 $$개 들어 있다. 단어의 길이는 1~10 사이이다. 단어 목록
 안의 단어는 중복이 없다.

## 트라이+백트래킹

 처음에 떠오른 방법은, 단어를 빨리 찾는 거니까 해시 셋을 끼얹는
 거였다. 그런데 결국 보드를 **한 글자 씩** 탐색해야 하므로, 탐색하는
 도중에는 결국 단어 전체보다는 단어의 **접두사**만을 보고 있는 상태가
 훨씬 많을 것이다. 따라서 여기에 적절한 자료 구조인 트라이를 적용해야
 한다.

 그럼 트라이를 쓰는 것 까지는 알겠는데, 어떻게 보드에서 탐색할 수
 있을까? 그냥 모든 칸에 대해서 탐색하면 복잡도가 터질 게
 뻔하다. 하지만 우리에게는 단어 목록이 있기 때문에, 이를 잘 활용하면
 탐색하는 도중 프루닝을 할 수 있는 지점이 보일 것이다. 이렇게 프루닝만
 해줘도 엄청나게 도움이 것이기 때문에, 우리는 백트래킹을 할 수 있다.

 일단 백트래킹 함수 `backtrack()`의 시그니쳐를 생각해보자. 보드의 어떤
 칸의 글자를 가지고 단어를 만드는 중인지를 알아야 탐색 공간을 프루닝할
 수 있기 때문에, 보드의 위치 `(row, col)`와 트라이의 노드가 있으면 될
 것 같다. 그러면 전체적인 알고리즘은 이렇다.
 1. 일단 단어 목록으로 트라이를 만든다.
 2. 모든 칸을 다 돌면서, 그 칸으로부터 단어를 만들 수 있으면
    백트래킹을 시작한다. 단어가 있으면 정답에 추가한다.

 여기서는 백트래킹을 할 때 트라이 노드를 들고 다녀야 하고, 또 나중에
 적용될 최적화를 위해서 [이전과 같은 방식으로 트라이를 만들기
 보다는](../implement-trie), 가볍게 딕셔너리를 이용해서 트라이를
 구성하는 게 좋다. 먼저 트라이를 만드는 코드를 보자.

```python
def findWords(board, words):
    WORD = 'word'
    trie = {}
    for word in words:
        node = trie
        for char in word:
            if char not in node:
                node[char] = {}
            node = node[char]
        node[WORD] = word
```

 즉, 노드를 오브젝트로 만들지 않고, 그냥 곧바로 딕셔너리로 만든다는
 점만 빼면 거의 동일하다. 그리고 여기에 한 가지 최적화가 적용되어
 있는데, 바로 한 단어의 추가가 완료되었을 때 이전 방법처럼 노드에
 `end` 같은 "단어의 끝"을 알리는 플래그를 두는 게 아니라, 단어를 담는
 특별한 키 값을 이용해서 **단어 자체**를 저장하고 있다. 이렇게하면
 백트래킹을 하면서 단어의 끝에 도달했을 때 곧바로 단어를 꺼내올 수
 있고, 정답 목록에 단어가 중복되면 안되니까 단어를 꺼내올 때 아예
 삭제해버림으로써 중복을 막을 수도 있다.

 그러면 이 트라이를 가지고 백트래킹을 해보자.

```python
def findWords(board, words):
    ...
    # build trie
    ...

    n, m = len(board), len(board[0])
    answer = []
    def backtrack(row, col, parent):
        char = board[row][col]
        node = parent[char]

        if WORD in node:
            # optimization 1) if we find a word, remove it to avoid duplicates
            answer.append(node.pop(WORD))

        # the same letter cell may not be used more than once in a word.
        board[row][col] = '#'

        for r, c in [(row+1, col), (row-1, col), (row, col+1), (row, col-1)]:
            if r < 0 or c < 0 or r >= n or c >= m:
                continue
            if board[r][c] in node:
                backtrack(r, c, node)

        # restore after constructing a word
        board[row][col] = char
```

 백트래킹 자체는 따라가기 쉽다. 먼저 보드의 현재 위치 `(row, col)`에
 있는 글자를 가져와서 이 글자가 현재 접두사의 어디에 있는지
 가져온다. 앞서 트라이를 구축할 때 적용한 최적화를 이용해서, 만약 지금
 노드에 단어가 매달려 있다면 (즉 `WORD` 키에 값이 있다면), 이 값이 곧
 지금 매칭된 단어의 끝이므로 곧바로 정답 목록에 추가한다. 이때, 노드에
 매달린 단어를 **삭제**해서, 이후 탐색에서 또 이 단어에 도달하더라도
 단어 목록에 중복되지 않도록 한다. 나머지 부분은 문제의 조건을 그대로
 구현한 것이다. 단어 하나를 만들 때에는 같은 칸의 글자가 여러 번 쓰일
 수 없다고 했기 때문에, 백트래킹으로 재귀적으로 타고 들어가기 전에
 미리 `#`으로 단어를 쓸 수 없게 만들었다가 이후에 백트래킹이 끝나고
 나면 복원한다. 다음 위치를 찾을 때에는 먼저 4방향의 유효한 칸의
 위치를 가져온 다음, 지금 트라이 노드의 위치에서 갈 수 있을 때에만, 즉
 해당 글자로 이어지는 접두사가 있을 때에만 백트래킹을 이어나간다.

 이렇게 만든 트라이와 백트래킹을 이용하면, 모든 보드 칸을 탐색해서
 정답을 구할 수 있다.

```python
def findWords(board, words):
    ...
    # build trie
    # define backtracking function
    ...

    for row in range(n):
        for col in range(m):
            if board[row][col] in trie:
                backtrack(row, col, trie)
    return answer
```

### 최적화

 이렇게만 하면 올바른 답을 구할 수 있지만, 생각보다 느리다. 여기서
 최적화를 해보자.

 사실 이미 위의 코드에는 세 가지 최적화가 적용되어 있다.
 1. 백트래킹을 할 때 트라이의 현재 노드도 함께 실어간다. 이렇게하면
    백트래킹의 각 단계에서 트라이의 *처음부터* 검색할 필요가 없다.
 2. 단어의 마지막 트라이 노드에 단어 자체를 매달아 두었다. 플래그를
    두면 백트래킹을 진행하면서 단어를 직접 만들어야 하는데, 그러지
    않고 단어를 곧바로 꺼내올 수 있어서 이 수고를 덜었다.
 3. 매칭된 단어를 정답 목록에 넣고 나서 바로 *삭제*해버렸다. 이렇게
    하면 정답 목록에 중복을 체크하지 않아도 된다.

 그러면 여기서 뭘 더 할 수 있을까? 핵심 아이디어는 단어를 검색하는
 속도는 우리가 구성한 트라이의 크기에 영향을 받는다는 것이다. 어떤
 단어가 끝까지 매칭되어서 정답 목록에 추가되었다면, 해당 단어를
 삭제하는 것(3)에서 그치지 않고, 해당 단어가 있던 *노드*를 점진적으로
 프루닝하면서 전체 트라이 사이즈를 줄인다면, 이후에 탐색할 때 공간을
 덜 보게 되어서 성능이 좋아질 것이다. 핵심은 단어의 경로에 있는 모든
 노드를 삭제하는 것이 아니라, **리프 노드**를 점진적으로 삭제해
 나아가는 것이다.

 예를 들어 단어 사전에 `dogs`와 `dog`가 있고 보드에 어떤 경로든
 `dogs`가 매칭된다고 해보자. 그러면 같은 접두사를 가진 두 단어가
 차례로 매칭되다가, 더 긴 단어인 `dogs`까지 매칭이 된다. 이렇게 단어가
 트라이 노드 **끝까지** 매칭이 되고 나면, 3에 의해서 중복없이 단어가
 정답 목록에 추가되고, 그러면 더 이상 이 끝 노드까지 탐색할 필요가
 없다. 즉, 트라이에서 **리프 노드**까지 탐색한 경우, (1) 단어가
 매칭되었으면 이미 추가되었을 것이고, (2) 그렇지 않으면 단어가 없는
 것이므로, 이 경로를 점진적으로 프루닝할 수 있다. 중요한 것은,
 예시처럼 `dogs`가 매칭되었다고 해서 `dogs`까지 온 경로의 **모든
 노드를 삭제하면 안된다**. 왜냐하면 `dog`가 있기 때문이다. 따라서,
 **점진적으로** 리프 노드를 삭제해 가는 전략을 써야한다. 이렇게 하면
 안전하게 트라이 크기를 조금씩 줄여갈 수 있고 전체적으로 탐색 속도를
 높일 수 있다.

 이 최적화까지 고려한 전체 코드는 다음과 같다.

```python
def findWords(board, words):
    WORD = 'word'
    trie = {}
    for word in words:
        node = trie
        for char in word:
            if char not in node:
                node[char] = {}
            node = node[char]
        # optimization 2: hang whole word in the last trie node
        node[WORD] = word

    n, m = len(board), len(board[0])
    answer = []

    def backtrack(row, col, parent):
        # optimization 1: recursion with parent trie node
        char = board[row][col]
        node = parent[char]

        if WORD in trie:
            # optimization 3: remove matched word to avoid duplicates
            answer.append(node.pop(WORD))

        board[row][col] = '#'

        for r, c in [(row+1, col), (row-1, col), (row, col+1), (row, col-1)]:
            if r < 0 or c < 0 or r >= n or c >= m:
                continue
            if board[r][c] in node:
                backtrack(r, c, node)

        board[row][col] = char

        # optimization 4: incrementally remove the matched leaf node
        if not node:
            parent.pop(char)

    for row in range(n):
        for col in range(m):
            if board[row][col] in trie:
                backtrack(row, col, trie)
    return answer
```
