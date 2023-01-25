---
layout: page
tags: [problem-solving, leetcode, python, string, dynamic-programming]
title: Longest Common Subsequence
---

# [Longest Common Subsequence](https://leetcode.com/problems/longest-common-subsequence/)

 두 문자열 `text1`과 `text2`가 주어졌을 때, 공통 부분열(common
 subsequence) 중 가장 길이가 긴 것의 길이를 구하자. 공통 부분열이
 없다면 `0`을 리턴하자.

 어떤 문자열의 **부분열(subsequence)**이란 원래 문자열이 담고 있는
 글자들 사이의 순서를 바꾸지 않고 0개 이상의 글자를 삭제해서 얻을 수
 있는 문자열을 뜻한다. 예를 들어 "ace"는 "abcde"의 부분열이다.

 두 문자열의 **공통 부분열(common subsequence)**이란 양쪽 문자열에
 모두 존재하는 부분열이다.

 두 문자열의 길이는 최대 1,000이고 모두 소문자 알파벳만을 담고 있다.

## 아아 다이나믹 프로그래밍이여

 아주 유명한 다이나믹 프로그래밍 문제이다. 여기서 파생되는 문제가 꽤
 있는 편이라서, 최장길이 공통 부분열 또는 LCS 문제는 필수적으로 짚고
 넘어가야 한다. 또 현실 세계의 문제에서도 LCS가 응용되는 곳이
 많다. 예를 들면 `diff`도 결국 두 문자열 중에서 다른 부분열을 찾는
 것이기 때문에 이 방법을 응용할 수 있다. 그리고 가장 유명한 것은 역시
 유전체 분석이다. 염기 서열을 일종의 문자열로 볼 수 있기 때문에 특히
 문자열과 관련된 알고리즘에 대한 연구는 끊임없이 이뤄지고 있다.

 아무튼 어떻게 접근할지 차근차근 살펴보자. 일단 다이나믹
 프로그래밍에는 두 가지 방법이 있는데, 하나는 탑 다운 방식의 재귀적인
 접근이고 다른 하나는 바텀 업 방식의 (미리) 반복문으로 계산하는
 접근이다.

### 탑 다운 - 1

 일단 탑 다운 접근을 먼저 고민해보자. 보통 재귀적인 점화식을 쉽게
 생각해낼 수 있고, 문제의 사이즈가 부분 문제를 다 풀어야 하는 경우 탑
 다운이 방식의 구현이 직관적이고 이해하기 쉽다.

 일단 이 문제를 부분 문제로 쪼개보자.

 `text1`에서 `text2`에도 있는 글자 `c`를 골랐을 때, 가능한 경우는 두
 가지이다: (1) 이 글자가 최적해에 들어있거나, (2) 이 글자가 최적해에
 없거나. `c`가 최적해에 포함된다면, 나머지 부분열은 두 문자열에서 `c`
 이후에 있는 부분 문자열에서 골라야 하고, 그렇게 구한 길이에서
 `c`만큼의 길이 `1`을 더한 값이 원하는 값이다. 만약 최적해에 포함되지
 않는다면, 이 말은 곧 이 글자를 무시하고 나머지 전체를 부분 문제로
 생각해야 한다.

 문제는 이 둘 중 어떤 게 올바른 방향인지를 모른다는 거다. 그러므로
 우리는 **두 경우 다** 고려해야 한다.

 그러면 위의 케이스를 생각하면서 알고리즘을 구성해보자. 두 문자열의
 LCS 길이를 구하는 함수 `LCS(text1, text2)`는 다음과 같이 동작한다.
 1. 일단 베이스 케이스. 둘 문자열 중 하나라도 빈 문자열이면 자연히
    답은 0이다.
 2. `text1`의 첫번째 글자 `letter1`을 뽑는다.
 3. `letter1`이 `text2`에서 *처음으로* 나타나는 위치를 찾는다. 이를
    `first_occur`라고 하자.
 4. 앞서 두 가지 경우를 모두 고려해서 후보를 각각 구한다:
    1. `first_occur` 위치가 최적해에 포함되는 경우를 구한다. 즉, `1 +
       LCS(text1[1:], text2[first_occur+1:])`이다. `1`은 `letter1`의
       길이이다. `letter1`을 포함했기 때문에, 나머지 부분 문자열은
       각각 `text1[1:]`과 `text2[first_occur+1:]`이 된다.
    2. `first_occur` 위치가 최적해에 포함되지 않는 경우를 구한다. 이는
       단순히 `LCS(text1[1:], text2)`가 된다. `letter1`이 포함되지
       않고, `text2`에서 이 글자가 나타난 위치를 무시하면 된다.
 5. 이렇게 구한 두 후보 값 중 최대 값을 리턴한다.


 이 알고리즘에서 빠진 부분은 `letter1`이 `text2`에 없으면 어떻게
 해야할지 이다. 이 경우는 그냥 더 탐색할 부분 문제가 없는 것이기
 때문에, 그냥 무시하면 된다.

 따라서 이 알고리즘을 구현하고, 추가로 탑 다운 방식의 다이나믹
 프로그래밍, 즉 메모이제이션까지 적용한 코드는 다음과 같다.

```python
import functools
def longestCommonSubsequence(text1, text2):
    @functools.cache
    def lcs(text1, text2):
        # base case) empty
        if not text1 or not text2:
            return 0

        # case 1) include text1[0]
        first_occur = text2.find(text1[0])
        cand1 = 0
        if first_occur != -1:
            cand1 = 1 + lcs(text1[1:], text2[first_occur + 1:])

        # case 2) not include text1[0]
        cand2 = lcs(text1[1:], text2)

        # get best
        return max(cand1, cand2)
    return lcs(text1, text2)
```

 잘 동작한다. 하지만, 매번 부분 문자열을 복사해서 넘기기 때문에,
 여기서 생기는 오버헤드가 엄청나다. 어차피 입력 문자열이 바뀌는 것이
 아니기 때문에, 문자열을 파라미터로 직접 넘기기 보다는 문자열 안의
 인덱스만 계산하면 더 빠르게 할 수 있을 것 같다. 이 부분을 개선하면
 다음과 같다.

```python
def longestCommonSubsequence(text1, text2):
    @functools.cache
    def lcs(i1, i2):
        # base case) empty
        if i1 == len(text1) or i2 == len(text2):
            return 0

        # case 1) include text1[i1], from i2
        first_occur = text2.find(text1[i1], i2)
        cand1 = 0
        if first_occur != -1:
            cand1 = 1 + lcs(i1 + 1, first_occur + 1)

        # case 2) not include text1[i1]
        cand2 = lcs(i1 + 1, i2)

        # get best
        return max(cand1, cand2)
    return lcs(0, 0)
```

 여기서 `i1`의 의미는 명확한데, `i2`의 의미를 곱씹어 볼 필요가
 있다. `i2`는 `first_occur`를 찾을 때, 즉 `text1[i1]`이 `text2`에서
 처음으로 나타난 위치를 찾을 때 기준점 역할을 한다. 앞서 문자열을
 통째로 넘길 때에는 이 부분이 항상 부분 문자열로 넘어갔지만, 인덱스만
 유지하는 경우는 `text2`에서 `text1[i1]` 글자를 찾을 때 *어디서부터*
 찾아야 할지, 즉 어떤 부분 문자열에서 찾아야 할지를 가이드하는 역할을
 해야 올바른 정답을 찾을 수 있다.

 이렇게하면 시간 복잡도는 `O(M * N^2)`이 된다. `M`은 `text1`의
 길이이고 `N`은 `text2`의 길이이다.

### 탑 다운 - 2

 좀더 개선된 탑 다운 방식을 고민해보자.

 전체적인 접근은 1번 방법과 유사하지만, 부분 문제를 쪼개는 방식을 조금
 달리하면 개선의 여지가 있다.

 첫 번째 글자가 **같다면**, 이 글자를 최적해에 포함시킬 수
 있다. 따라서, LCS는 `1 + LCS(p1 + 1, p2 + 2)`이 된다. 왜냐하면 두
 글자가 이미 같다면, 이를 최적해에서 제외시킬 이유가 없기 때문이다.

 두 문자열의 첫 번째 글자가 **다르면**, 두 글자 중 하나 또는 둘 다가
 최적해에 포함되지 않을 것이다. 따라서, LCS는 `max(LCS(p1 + 1, p2),
 LCS(p1, p2 + 1))`이 된다.

```python
def longestCommonSubsequence(text1, text2):
    @functools.cache
    def lcs(i1, i2):
        if i1 == len(text1) or i2 == len(text2):
            return 0

        if text1[i1] == text2[i2]:
            # case 1) first letters are the same
            return 1 + lcs(i1 + 1, i2 + 1)
        else:
            # case 2) first letters are not the same
            return max(lcs(i1 + 1, i2), lcs(i1, i2 + 1))
    return lcs(0, 0)
```

 시간 복잡도는 `O(M*N)`이 된다. 각각의 부분 문제를 푸는 데에는 상수
 시간 `O(1)`이 든다. 더 이상 `text2`에서 검색하지 않기 때문이다. 부분
 문제의 개수는 `M * N` 만큼이 있기 때문에 이 복잡도를 얻는다.

 1, 2 모두 공간 복잡도는 `O(M * N)`이다.
