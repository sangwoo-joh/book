---
layout: page
title: Web Crawler
---

# [Web Crawler](https://leetcode.com/problems/web-crawler/)

문제의 요구사항 자체는 간단한 그래프 탐색 문제이다.

만약 실제 업무에서 크롤러를 구현하게 된다면 탐색 공간이 엄청나게 커지기 때문에 고려해야 할 것이 많다. 예를 들어, 같은 호스트 네임을 갖는 웹 사이트마다 다른 속도, 링크가 무한히 이어지는 경우, 등을 고려할 수 있다. 그래서 보통은 서로 다른 도메인에는 DFS를 이용하고 같은 도메인에서는 BFS를 이용한다. 추가로 방문 체크를 위해서 해시 셋 이전에 블룸 필터 같은 것을 두기도 한다.

```python
def crawl(startUrl: str, htmlParser: 'HtmlParser') -> List[str]:
    hostname = 'http://' + startUrl[len('http://'):].split('/', 1)[0]
    results = [startUrl]

    visited, q = set(), deque()
    visited.add(startUrl)
    q.append(startUrl)
    while q:
        url = q.popleft()
        for follow in htmlParser.getUrls(url):
            if follow in visited or not follow.startswith(hostname):
                continue
            visited.add(follow)
            q.append(follow)
            results.append(follow)
    return results
```
