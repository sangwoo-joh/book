---
layout: page
tags: [problem-solving, theory, python, string, palindrome]
title: Palindrome
last_update: 2023-01-25 23:50:09
---

# 팰린드롬

 팰린드롬이란 어떤 시퀀스가 앞으로 가나 뒤로 가나 똑같은 시퀀스를 것을
 말한다. 예를 들면 `토마토` 라던가 `racecar` 같은 거다. 어떤 문자열이
 팰린드롬인지 아닌지는 이 성질을 이용해서 `text == text[::-1]`로
 확인할 수 있다.

 그럼 어떤 문자열에서 **가장 긴 팰린드롬**을 찾으려면 어떻게 할 수
 있을까? 브루트 포스로는 해당 문자열의 모든 길이의 [부분 문자열을
 생성](/python/short-tips#어떤-문자열의-길이-k인-모든-부분-문자열-생성하기)한
 다음, 위의 성질을 이용해서 일일이 다 체크하면 된다. 이러면 복잡도가
 터지겠지만. 따라서 조금 더 똑똑한 방법은 다음 성질을 이용한다.

 일단 문자열을 뒤집는 연산은 시간과 공간 복잡도 모두 `O(n)`이 걸리므로
 이걸 하면 안된다. 팰린드롬인지 아닌지를 확인하는 좀더 빠른 방법은
 다음과 같다: 어떤 인덱스를 기준으로, **앞 뒤로 동시에 포인터**를
 이동하는데, 이때 두 포인터 위치의 원소가 같을 때에만 이동한다. 즉,
 팰린드롬의 **중심**이 될 것 같은 인덱스부터 앞 뒤를 동시에 보면서
 팰린드롬 여부를 확인하는 것이다. 이때 중요한 것은 팰린드롬의 길이가
 **짝수**인 경우도 고려해줘야 하기 때문에, 중심 인덱스 하나를 받는
 것이 아니라 앞 뒤 인덱스를 다 받되 `(i, i)`와 `(i, i+1)`을 넘겨줘야
 한다. 즉, `aba`와 `abba`를 모두 고려해야 한다.

``` python
def max_length_from_center(string, forward, backward):
    if not string or backward < forward:
        return 0

    num_of_palindrome = 0  # 모든 팰린드롬 개수를 세고 싶을 때는 여기서 셀 수 있다.
    while forward >= 0 and backward < len(string) and string[forward] == string[backward]:
        forward -= 1
        backward += 1
        num_of_palindrome += 1
    return (backward - forward - 1)
    # or, return num_of_palindrome for the number of palindromes found
```

 `forward`는 문자열의 앞쪽, 즉 `0`번 인덱스를 향해 감소하는
 인덱스이고, `backward`는 문자열의 끝쪽, 즉 `len(string)`을 향해
 증가하는 인덱스이다.

 `while` 루프는 유효한 팰린드롬의 조건을 만족하는 동안 계속
 돈다. 따라서, 해당 루프를 빠져나온 순간의 `forward`와 `backward` 값은
 가장 긴 팰린드롬의 시작과 끝 인덱스가 **아니라**, `(시작 - 1)`과
 `(끝 + 1)` 인덱스임에 주의하자. 따라서 가장 긴 팰린드롬의 길이를
 구하려면, `(끝 + 1) - (시작 - 1) = 끝 - 시작 + 2`가 되므로 여기서 1을
 빼주면 길이가 된다. 따라서 `backward - forward - 1`이 우리가 원하는
 길이이다.

 이렇게 만든 함수를 이용하면 다음과 같이 짝수/홀수 길이의 팰린드롬을
 모두 고려해서 어떤 문자열의 부분 문자열 중 가장 긴 팰린드롬을 구할 수
 있다.

```python
def longest_palindrome(string):
    if not string or len(string) < 1:
        return ''

    start, end = 0, 0
    for i in range(len(string)):
        cand = max(max_length_from_center(string, i, i),
                   max_length_from_center(string, i, i+1))
        if cand > (end - start):
            start = i - (cand - 1) // 2
            end = i + cand // 2

    return string[start:end+1]
```

 여기서 `start`와 `end`는 모두 인덱스이다. 현재 인덱스 `i`를 중심으로
 하는 가장 긴 팰린드롬의 길이를 찾고나면, 이 길이로부터 팰린드롬의
 시작과 끝 인덱스를 위와 같이 구할 수 있다. 예를 들어 길이가 홀수인
 5라면 시작 인덱스는 `i - 2`, 끝 인덱스는 `i + 2`가 되는 것이고,
 길이가 짝수인 6이라면 `(i-2, i+3)`이 된다. 즉, 현재 인덱스 `i`로 부터
 가장 긴 팰린드롬을 구할 때 앞 뒤 포인터를 `(i, i+1)`로 설정했기
 때문에, 길이를 구하고 나면 시작 인덱스에서 빼줄 때에 `(길이 - 1) //
 2` 만큼을 빼서 인덱스를 구하는 것이다.

 근데 이렇게하면 사실 복잡도는 꽤 비싸다. 팰린드롬의 최대 길이가
 문자열 길이만큼일 수 있기 때문에, 실제 복잡도는 `O(n^2)`이
 된다. 앞에서 구한 팰린드롬 정보를 활용해서 동적 프로그래밍으로 이를
 구하는 [Manacher의
 알고리즘](https://en.wikipedia.org/wiki/Longest_palindromic_substring#Manacher's_algorithm)을
 이용하면 `O(n)` 복잡도를 달성할 수 있지만 아직 이건 이해하지 못했다.
