---
layout: page
tags: [problem-solving, leetcode, python, ]
title: Valid Palindrome
---

# [Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)

 어떤 문장이 주어졌을 때, 모든 문장의 알파벳을 소문자로 바꾸고 알파벳
 또는 숫자가 아닌 모든 글자를 다 지워버린 문자열이 팰린드롬일 때, 해당
 문장은 팰린드롬이라고 정의한다.

 어떤 문장이 팰린드롬인지 아닌지를 확인하자.

 문장의 길이는 $$ 1 \sim 2 \times 10^5$$ 이고 문장은 모든 가능한
 아스키코드 글자를 담고 있다.

## 구현
 - 부분 문자열 중에서 팰린드롬의 개수를 세는 그런 복잡한 것도 아니고
   그냥 쌩 문자열이 팰린드롬인지 아닌지 확인하면 되는데, 정방향 문자와
   역방향 문자가 같은지 보면 된다.
 - (1) 문자열의 알파벳을 전부 소문자로, (2) 문자열에서 알파벳 또는
   글자가 아닌 글자는 모두 지워버리는, 두 단계의 정규화가 필요하다.
 - 정규화는 복잡하게 생각하지 말고 파이썬의 `isalnum()`을
   쓰자. 아스키코드를 확인해도 된다.
 - 정규화 -> 팰린드롬 인지 확인 하면 된다.


```python
def isPalindromePhrase(s):
    norm = [c.lower() for c in s if c.isalnum()]
    normed = ''.join(norm)
    return normed == normed[::-1]
```
