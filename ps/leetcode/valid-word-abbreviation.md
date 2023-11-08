---
layout: page
tags: [problem-solving, leetcode, python, string]
title: Valid Word Abbreviation
last_update: 2023-11-08 17:18:33
---


# [Valid Word Abbreviation](https://leetcode.com/problems/valid-word-abbreviation/)

 생각보다 함정이 많아서 문제의 조건을 꼼꼼하게 따져서 하나 씩 검사해야 한다.

 1. 요약어의 숫자가 0으로 시작하면 안됨
 2. 요약 숫자 개수만큼만 스킵해야 함
 3. 요약어와 단어가 정확히 매칭되어야 함


 세 가지 조건에 주의하면서 구현하면 다음과 같다.

```c++
bool validWordAbbreviation(string word, string abbr) {
  int wi = 0, ai = 0;
  while (wi < word.size() && ai < abbr.size()) {
    if (word[wi] == abbr[ai]) {
      wi++, ai++;
      continue;
    }

    if (!isdigit(abbr[ai])) return false;

    string number = "";
    while (ai < abbr.size() && isdigit(abbr[ai])) {
      number += abbr[ai++];
    }

    // 1.
    if (number.size() > 0 && number[0] == '0') return false;

    int count = stoi(number);
    // 2.
    if (wi + count > word.size()) return false;
    wi += count;
  }

  // 3.
  return (wi == word.size() && ai == abbr.size());
}
```
