---
layout: page
tags: [problem-solving, leetcode, python]
title: Count Common Words with One Occurrence
---

# [Count Common Words with One Occurrence](https://leetcode.com/problems/count-common-words-with-one-occurrence/)

 두 개의 단어 배열 `words1`과 `words2`가 입력으로 들어왔을 때, 두 배열
 모두에서 각각 한 번씩만 등장하는 단어의 개수를 구하자.

## 그냥..센다

 그냥 양쪽 단어 목록에서 단어 개수를 센 다음, 개수가 1개인 단어만
 남겨서 교집합을 구하면 된다.

```python
from collections import Counter
def countWords(words1, words2):
    c1, c2 = Counter(words1), Counter(words2)
    c1set = set([c[0] for c in c1.items() if c[1] == 1])
    c2set = set([c[0] for c in c2.items() if c[1] == 1])
    return len(c1set & c2set)
```

 - 문자 그대로 단어의 개수를 각각 세고, 개수가 1개인 것만 집합으로
   모은 다음, 두 교집합의 길이를 리턴한다.
