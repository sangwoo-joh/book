---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Group Anagrams
---

# [Group Anagrams](https://leetcode.com/problems/group-anagrams/)

 단어 배열이 주어졌을 때, 아나그램끼리 배열로 묶어서 배열로
 리턴하다. 배열 안에서의 아나그램 순서는 상관없다.

 아나그램이란 원래 단어의 글자의 순서를 바꿔서 다른 단어를 만들어내는
 것이다.

 단어는 모두 알파벳 소문자만 담고 있다.

## 접근 1 - 정렬
 - 아나그램이면 단어를 이루는 글자의 개수가 같다. 따라서, 단어의
   글자를 알파벳 순으로 정렬하면 모든 아나그램은 다 같은 단어로
   정규화할 수 있다.
 - 정규화된(정렬된) 단어를 키 값으로 하는 해시테이블에 *원래 단어*를
   누적한다. (순서 상관 없음)

```python
def groupAnagrams(strs):
    answer = defaultdict(list)
    for word in strs:
        key = ''.join(sorted(word))
        answer[key].append(word)
    return answer.values()
```


## 접근 2 - 인코딩
 - 어떻게든 아나그램을 하나의 표현으로 정규화하기만 하면 된다는 걸
   깨달았다.
 - 아나그램의 정의에 따라 단어에 쓰인 글자의 개수가 같으면
   아나그램이다. 이 개수를 직접 정규화된 키로 쓸 수 있다. 알파벳
   소문자만 담겨있기 때문에 26개의 글자에 대해서만 세면 된다.

```python
def groupAnagrams(strs):
    def norm(word):
        counts = [0] * 26
        for letter in word:
            counts[ord(letter) - ord('a')] += 1
        return tuple(counts)
    answer = defaultdict(list)
    for word in strs:
        key = norm(word)
        answer[key].append(word)
    return answer.values()
```
