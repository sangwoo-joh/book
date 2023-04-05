---
layout: page
tags: [problem-solving, leetcode, python, string, simulation]
title: Text Justification
---

# [Text Justification](https://leetcode.com/problems/text-justification/)
 (뱀발: justify 뜻 중에 "인쇄되는 텍스트의 행 끝을 나란히 맞추다"라는
 뜻이 있더라...)

 단어의 리스트랑 `maxWidth`가 주어졌을 때, 이 단어를 잘 나열해서 각
 라인이 정확하게 `maxWidth` 길이 만큼이 되게끔 *완전히* (즉,
 양방향으로) 나란히 맞추자.

 여러 단어를 한 줄에 맞출 때 그리디하게 접근해야 한다. 즉, 각 줄에는
 최대한 많은 단어를 우겨 넣어야 한다. 그리고 필요하다면 추가적인 공백
 `' '`을 추가해서 각 라인이 정확하게 `maxWidth` 길이를 갖도록 해야
 한다.

 단어 사이의 추가적인 공백은 **최대한** 균등하게 퍼져야 한다. 만약
 단어 사이의 공백 수를 균등하게 맞출 수 없다면, 왼쪽부터 채워 나간다.

 제일 마지막 줄은 왼쪽 정렬을 한다. 즉, 단어 사이의 추가적인 공백이
 없어야 한다.

 - 단어에는 공백이 없다.
 - `0 < word.length <= maxWidth`
 - 단어 리스트에는 최소 1개의 단어는 있다.

## 대체 뭘 어쩌란 건지
 아주 드러운 문제다. 설명이 장황하면 보통 엄청 어려운 알고리즘이
 필요하거나 코너 케이스가 많거나 둘 중 하나더라.

 일단 문제부터 이해해보자. 그래서 대체 뭘 어쩌란 걸까? 이건 예시를
 봐야 좀 이해가 된다.

### 예시

```python
words = ["This", "is", "an", "example", "of", "text", "justification."]
maxWidth = 16
output:
[
  "This    is    an",
  "example  of text",
  "justification.  "
]
```

 - 각 줄 길이를 16에 맞추기 위해서 첫 번째 줄 단어 사이에 각각 4개의
   공백이 들어갔다. ㅇㅋ. 균등하다.
 - 두번째 줄에는 균등하게 공백을 못 맞추기 때문에, 왼쪽에 공백이 1개
   더 추가됐다. ㅇㅋ. 균등하지 않으면 왼쪽부터 채워 나간다.
 - 마지막 줄은 왼쪽 정렬을 한다. 즉, 최대 길이를 맞추기 위해서 뒤에
   공백을 쫙 깔아준다.

 예시를 보니 조금 이해가 되는 것 같다. 근데 마지막 줄에 만약 단어가
 여러 개 이면 어떨까? 마침 예시가 하나 더 있다.

```python
words = ["What", "must", "be", "acknowledgement", "shall", "be"]
maxWidth = 16
output:
[
  "What   must   be",
  "acknowledgment  ",
  "shall be        "
]
```

 이제 첫줄은 이해된다. 둘째줄은 단어 두개를 놓으면 최대 길이를 넘기
 때문에 단어를 하나만 해야하고, 그래서 오른쪽에만 공백이 채워졌는데,
 이게 바로 코너 케이스다. 그리고 마지막줄을 보면 오른쪽이 전부
 공백이다. 즉, 만약 단어가 여러 개라면, 단어 사이에는 1개의 공백만을
 갖게 하고 나머지 길이만큼 오른쪽을 전부 공백으로 채우면 된다.

## Round Robin
 사실 이 글은 리트코드 디스커션에서 아주 똑똑한 솔루션(댓글: "smart
 ass")을 보고 감명 받아서 작성한다.

 요지는 문제에서 설명하는, "단어 사이의 공백은 최대한 균등하게 맞추고
 왼쪽부터 채워나간다"는 **라운드 로빈** 스케쥴링을 말하는 아주 길고
 이상한 방식이라는 것이다.

 라운드 로빈은 간단하다. 작업 사이에 우선순위를 두지 않고 그냥
 순서대로 작업을 할당하는 것이다. 즉, 여기서도 단어 사이에 우선순위를
 두지 않고, 그냥 왼쪽부터 시작해서 단어 사이에 공백을 하나씩
 채워나가면 된다. 라운드 로빈 그 자체다.

 그럼 어떻게 하면 될까? 전체적인 틀은 다음과 같다.
 1. "현재 줄" (단어 리스트) 정보를 유지한다.
 2. 각 단어에 대해서, "지금 단어를 현재 줄에 추가하면 `maxWidth`를
    넘는가?"를 체크한다.
 3. 넘으면, 코너 케이스를 잘 생각해서, 라운드 로빈 방식으로 각 단어
    사이에 공백을 추가한다. 그리고 현재 줄 정보를 **초기화한다**.
 4. 안넘으면, 현재 줄에 단어를 추가한다.
 5. 마지막 단어까지 훑었는데 현재 줄에 단어가 남아있으면, 현재 줄의
    단어를 공백 하나 띄우고 합친 다음에 남는 길이만큼 오른쪽에 공백을
    채운다.

 참고로, 파이썬에는 `str.ljust(width)`와 `str.rjust(width)` 함수가
 있어서 이걸 활용하면 좀더 쉽게 할 수 있다. `ljust(width)`는 단어를
 `width` 길이에 맞추되, 왼쪽에 단어를 배치하고 나머지 길이만큼은
 공백으로 채우는 함수다. 그럼 `rjust(width)`는 뻔하다. 그러므로 우리가
 활용해야 할 건 `ljust`다.

 그럼 이걸 차근차근 코드로 구현해보자.

```python
def text_justification(words, maxWidth):
    answer = []
    line = []  # current line that contains word
    letters = 0  # length of accumulated words in the current line

    for word in words:
        if letters + len(word) + (len(line) - 1) >= maxWidth:
            # len(line) - 1: the minimum number of spaces required.
            if len(line) == 1:
                # edge case: when only a single word exists in the line
                answer.append(line[0].ljust(maxWidth))
            else:
                # do round-robin, except for the last word
                spaces = [0] * len(line)
                for i in range(maxWidth - letters):
                    idx = i % (len(line) - 1)  # skip the last word
                    spaces[idx] += 1

                for i in range(len(line)):
                    line[i] += ' ' * spaces[i]

                answer.append(''.join(line))

            # clear
            line = []
            letters = 0

        line.append(word)
        letters += len(word)


    if line:
        # use ljust to left-justify
        answer.append(' '.join(line).ljust(maxWidth))

    return answer
```

 - 현재 라인뿐만 아니라 편의를 위해서 현재 라인에 속한 단어 길이의
   누적 합 `letters`도 유지한다.
 - "지금 단어를 현재 라인에 추가하면 오버플로우나나요?"를 체크하기
   위한 로직을 잘 보자. `letters`는 앞서 말했던 현재 라인에 속한 단어
   길이의 합이다. `len(word)`는 지금 단어의 길이다. 여기까진
   자명하다. 그럼 `len(line) - 1`은 뭘까? 단어 사이사이에 최소한
   공백이 1개는 필요하다는 것은 곧 현재 줄의 단어 개수에서 1개를 뺀
   값이 필요한 공백의 최소 개수와 같다는 것을 뜻한다. 따라서, 이 세
   값의 합이 `maxWidth`를 넘는지 확인하면, 언제 라운드 로빈을
   시작해야할 지 알 수 있다.
 - 위의 두 번째 예시의 두 번째 줄에서 본 코너 케이스를 처리한다. 현재
   줄에 놓을 수 있는 단어가 1개 뿐이면, 그냥 단어를 left-justification
   하면 된다. 파이썬의 `ljust`를 이용하면 쉽게 공백을 채울 수 있다.
 - 라운드 로빈을 어떻게 하는지 생각해보자. 여기서는, 현재 줄에 있는
   단어 중 마지막 단어를 제외한 나머지 단어의 뒤에 공백을 균등하게
   추가하는 접근을 했다. 먼저 단어 사이의 공백 개수를 0으로
   초기화한다. 추가할 수 있는 공백 개수는 총 `maxWidth - letters`
   개다. 제일 마지막 단어를 제외한 나머지 단어의 뒤에 공백을 붙일
   것이므로 총 `len(line) - 1` 개의 단어를 훑을 것이다. 이때, 왼쪽부터
   균등하게 한다는 것은 곧 인덱스 `0`부터 순환적으로 추가하면 되므로,
   모듈러 연산을 활용할 수 있다. 이렇게 필요한 공백의 수를 세고 나면
   Pythonic하게 문자열 곱셈으로 공백 개수를 맞추면 된다.
 - 라인 수를 넘어서 라운드로빈을 하고 나면, 현재 라인 정보와 누적 단어
   길이를 초기화하는 것을 잊으면 안된다.
 - 이렇게 모든 단어를 훑고 나서 `line`이 남아 있으면, 남은 단어를 모두
   공백 1개 기준으로 합친 후에 `maxWidth` 만큼 나머지 오른쪽을
   공백으로 채우면 된다.

 안틀리고 한번에 잘 구현하기 꽤 어려운 문제다.
