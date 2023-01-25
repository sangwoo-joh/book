---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Longest Palindrome by Concatenating Two Letter Words
---

# [Longest Palindrome by Concatenating Two Letter Words](https://leetcode.com/problems/longest-palindrome-by-concatenating-two-letter-words/)

 **두 글자**로 이뤄진 단어 목록 `words`가 주어진다.

 이 단어 목록에서 단어를 골라서 이어붙였을 때 만들 수 있는 **가장 긴
 팰린드롬**의 길이를 구하자. 각각의 단어는 **최대 한번** 사용될 수
 있다.

 - 단어 목록의 크기는 1~100,000
 - 각 단어는 항상 두 글자임이 보장되고 소문자 알파벳만 포함한다.

## 정직한 접근
 - 두 종류의 단어가 중요하다.
   - 같은 글자로만 이뤄진 단어: `aa`, `bb`와 같은 것들. 얘네는
     팰린드롬의 중간에도 올 수 있고, 짝수 개인 경우 양 옆에도 붙일 수
     있다.
   - 단어와 거꾸로된 단어의 쌍: `(lr, rl)`과 같은 쌍들. 얘네는 양 끝에
     하나씩 이어붙여서 팰린드롬을 만들 수 있다. 길이만 구하면 되므로
     순서는 상관없다.
 - 일단 두 종류의 단어 개수를 따로 센다. 각각 `same`, `pair`라고 하자.
 - `same`의 개수 중 홀수인 친구는 그 중 하나를 빼서 팰린드롬의
   중간으로 쓸 수 있다.
 - 나머지 `same`은 짝수 개 만큼만 써서 팰린드롬을 만들 수 있다.
 - `pair`는 만드는 방법에 따라 만약 `lr`과 `rl`이 둘 다 들어있다면,
   그리고 짝이 맞을 때에만 갯수를 세었다면, 그냥 `pair`의 개수 곱하기
   글자 수(= 2) 만큼 더하면 된다.

```python
def longestPalindrome(words):
    word_counts = Counter(words)
    same, pair = Counter(), Counter()
    for word in words:
        rev = word[::-1]
        if word[0] == word[1]:
            same[word] += 1
        elif word_counts[rev] and word_counts[word]:
            pair[word] += 1
            pair[rev] += 1
            word_counts[word] -= 1
            word_counts[rev] -= 1

    answer = 0
    for word in same:
        if same[word] % 2 == 1:
            answer = 2
            same[word] -= 1
            break
    for word in same:
        cnt = same[word]
        answer += (cnt * 2 if cnt % 2 == 0 else (cnt - 1) * 2)
    for word in pair:
        answer += pair[word] * 2
    return answer
```

## 좀더 나은 접근
 - `Counter`로 단어 개수를 세었기 때문에 직접 이 갯수를 훑는게 더
   효율적이다. `words`보다 크기가 작을 것이기 때문이다.
 - 단지 중간에 올 수 있는 단어가 있는지만을 확인하기 위해서 루프를
   돌리기 보다는 한 번에 할 수 있으면 좋겠다. 따라서, 홀수인 경우에는
   플래그를 하나 세워두면서 값을 하나 깐 다음, 마지막에 플래그를
   확인하고 더할 수 있다.
 - 단어 목록이든 `Counter`든, 항상 같은 순서로 단어를 확인하도록
   강제할 수 있다. 예를 들어, 단어는 항상 두 글자이므로 `word[0] <
   word[1]` (또는 `word[0] > word[1]`) 인 경우에만 팰린드롬인 경우를
   확인한다고 하자. 그러면 자연스럽게 앞의 `pair` 경우를 한 번만
   확인해도 된다.
 - 순서가 강제되어서 `pair`를 확인할 때에는, `pair`를 이루는 두 단어의
   개수 중 **더 적은 쪽**의 개수가 팰린드롬의 크기를 결정한다.

```python
def longestPalindrome(words):
    word_counts = Counter(words)
    answer = 0
    has_center = False

    for word, count in word_counts.items():
        if word[0] == word[1]:
            answer += ((count - 1) * 2 if count % 2 else count * 2)
            if count % 2 == 1: has_center = True
        elif word[0] < word[1]:
            pair = word[1] + word[0]
            answer += 4 * min(count, word_counts[pair])
    return (answer + 2) if has_center else answer
```
