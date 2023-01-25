---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Search Suggestions System
---

# [Search Suggestions System](https://leetcode.com/problems/search-suggestions-system/)

 단어 목록 `products`와 단어 하나 `searchWord`가 주어진다.

 `searchWord`의 각 글자가 타이핑 될 때마다, `products`에서 최대 3개의
 제품 목록을 추천하는 시스템을 디자인하자. 추천되는 제품은 타이핑 된
 `searchWord`의 부분 문자열을 접두사로 가져야 한다. 조건을 만족하는
 제품이 세 개 이상이라면 사전순으로 3개의 제품만 리턴하자.

 `searchWord`의 각 글자가 타이핑될 때마다 추천되는 모든 제품 목록의
 리스트를 리턴하자.

 `products`는 최대 1,000개이고 각 제품 단어의 길이는 최대
 3,000이다. 모든 제품 단어의 길이의 합은 최대 $$2 \times 10^4$$를 넘지
 않는다. 모든 제품 이름은 알파벳 소문자로만 구성되며 유니크하다. 검색
 단어 길이는 최대 1,000이며 알파벳 소문자로만 구성된다.

## 트라이 말고 정렬 + 필터링

 *접두사*라는 문제의 설명 때문에 무지성으로 트라이를 끼얹고 싶은 그런
 문제이지만, 사실 이와 유사한 문제를 이미 풀어봤다. 바로 [검색
 자동완성 시스템
 디자인하기](../design-search-autocomplete-system)이다. 이 문제에서는
 처음에 트라이로 접근했지만 생각만큼 속도가 나와주지 않아서
 정렬+필터링의 조합을 적용했었다. 여기서는 곧바로 정렬+필터링 조합을
 적용해보자.

 알고리즘은 이렇다.
 1. 단어 목록에서 검색할 단어의 첫 글자와 같은 단어만 남겨둔다.
 2. 필터링된 단어 목록을 사전순으로 정렬한다.
 3. 검색할 단어를 한 글자씩 만들어 가면서 단어 목록을 계속 필터링한다:
    1. 검색할 단어보다 길이가 긴 단어
    2. 지금 글자와 같은 글자를 가진 단어
    3. 필터링 할 때마다 최대 3개를 정답 목록에 추가한다.

 이게 트라이보다 훨씬 빠르고 간단하게 구현할 수 있다.

```python
def suggestProducts(products: List[str], searchWord: str) -> List[List[str]]:
    answer = []
    matched = [p for p in products if p[0] == searchWord[0]]
    matched.sort()
    answer.append(matched[:3])

    i = 1
    while 1 < len(searchWord):
        matched = [p for p in matched if len(p) > i and p[i] == searchWord[i]]
        answer.append(matched[:3])
        i += 1

    return answer
```

 - 파이썬의 슬라이스 연산자로 최대 3개의 추천 목록을 쉽게 뽑아낼 수
   있다.
 - 단어 길이가 항상 1보다 크기 때문에 첫 번째 `matched`를 필터링할 때
   예외 처리를 하지 않아도 된다.
 - 두 번째 글자부터 필터링할 때, `searchWord[1:]`를 `enumerate`하면 첫
   번째 글자가 사라진 부분 문자열의 인덱스를 새로 만들기 때문에
   인덱스가 다시 0부터 시작해서 좀 까다로워진다. 그냥 클래식하게
   인덱스를 직접 이용해서 `while` 루프를 돌리는 게 더 편하다.
