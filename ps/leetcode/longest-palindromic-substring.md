---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Longest Palindromic Substring
---

# [Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/)

 주어진 단어에서 가장 긴 팰린드롬 부분문자열을 구하자.

 단어의 길이는 1~1,000 사이이고 알파벳 소문자와 숫자만 담고 있다.

## 접근 - 중심부에서 세기
 - *가장 긴* 팰린드롬을 찾아야 한다.
 - 인덱스 `i`를 중심으로 가장 긴 팰린드롬의 길이를 찾는 함수 O(N),
   이를 모든 글자에 대해서 해봐야 하므로 O(N^2) 복잡도가 든다.
 - 중심이 되는 글자는 한 글자와 두 글자 모두 가능한 것을 주의하자.
 - 중심부에서 팰린드롬 범위를 세는 함수의 `while` 루프가 **끝나는
   순간**의 `left, right`는 팰린드롬 인덱스 범위를 하나 씩
   벗어나있음에 주의하자.
 - 정답 범위의 초기 값에 주의하자. 빈 문자열을 나타내기 위해서 `[0,
   -1]`과 같은 조금 비 직관적인 값을 줘야 한다. 그래야 문자열 길이
   계산 공식에 따라 `-1 - 0 + 1 = 0`이 된다.

```python
def lognestPalindrome(s):
    def palindrome_range(left, right):
        while left >= 0 and right < len(s) and s[left] == s[right]:
            left -= 1
            right += 1
        return (left + 1, right - 1)

    answer_start, answer_end = 0, -1
    for i in range(len(s)):
        start, end = palindrome_range(i, i)
        if (answer_end - answer_start + 1) < (end - start + 1):
            answer_start, answer_end = start, end
        start, end = palindrome_range(i, i+1)
        if (answer_end - answer_start + 1) < (end - start + 1):
            answer_start, answer_end = start, end

    return s[answer_start:answer_end+1]
```
