---
layout: page
tags: [problem-solving, leetcode, python, ]
title: Encode and Decode Strings
---

# [Encode and Decode Strings](https://leetcode.com/problems/encode-and-decode-strings/)

 문자열 리스트를 하나의 문자열로 인코딩하는 함수와, 이렇게 인코딩된
 문자열을 다시 원래의 문자열 리스트로 디코딩하는 함수를 구현하자.

 문자열은 모두 아스키코드 범위(0~256)의 글자만 담고있다.

## 오답 노트
 - 캐릭터가 전부 아스키코드 범위이기 때문에, `;`든 `#`든 아니면 여러
   문자를 합친 것이든 리스트 구분자로 쓸 수 없다.

## 올바른 접근
 - 아스키 코드 범위를 벗어나는 글자를 구분자로 써야 한다.

```python
def encode(strs):
    return chr(300).join(strs)

def ecode(s):
    return s.split(chr(300))
```
