---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Palindromic Substrings
---

# [Palindromic Substrings](https://leetcode.com/problems/palindromic-substrings/)

 주어진 문자열 안에 있는 팰린드롬인 모든 가능한 부분문자열의 개수를
 구하자. 문자열의 길이는 최대 1000이고, 영어 소문자만 담고 있다.

 참고로, 같은 문자로 이루어진 팰린드롬이라도 위치가 다르면 서로 다른
 팰린드롬으로 취급해야 한다. 예를 들어서, `aaa` 문자열의 경우 가능한
 팰린드롬은 `a`, `a`, `a`, `aa`, `aa`, `aaa`의 총 6가지 인데, 이는
 같은 문자열이라도 팰린드롬의 위치가 다르기 때문에 별개의 팰린드롬으로
 취급하기 때문이다.


## 팰린드롬 세기

 내 블로그 이전 글 중 [팰린드롬](../../theory/palindrome)을 참조하면
 좋다.

 팰린드롬을 셀 때 앞이나 뒤에서 세면 좀 까다롭다. 팰린드롬의 성질을
 이용해서 어떤 문자열의 **중앙**에서부터 양 옆으로 체크해 나아간다고
 생각하면 쉽다. 대신, 팰린드롬은 길이가 짝수일 수도 있으므로, 시작점인
 *중앙*을 하나의 포인트가 아니라 두 개의 포인트로 받아야 한다는 점만
 유의하자.

```python
def countSubstrings(s):
    def count_palindrome_from(left, right):
        count = 0
        while left >= 0 and right < len(s) and s[left] == s[right]:
            count += 1
            left -= 1
            right += 1
        return count

    if not s or len(s) < 1:
        return 0

    total = 0
    for i in range(len(s)):
        total += count_palindrome_from(i, i)
        total += count_palindrome_from(i, i+1)

    return total
```

 - `left`, `right`가 시작할 중앙 부분이다. `s[left] == s[right]`인
   조건을 만족하면 팰린드롬이다. `left`는 빼서 왼쪽으로, `right`는
   더해서 오른쪽으로 가면서 개수를 센다.
 - `count_palindrome_from`을 호출할 때에는 앞서 말했다시피 짝수인
   케이스를 고려해야 하기 때문에 `(i, i)`뿐만 아니라 `(i, i+1)`도
   호출해줘야 한다. 함수 안에서 범위 오버플로우 체크를 해주고 있기
   때문에 그냥 곧바로 호출해도 괜찮다.
