---
layout: page
title: Hash
---

# Hash

충돌을 최대한 덜 나게 하는 암호학적 해시 함수를 만드는 일반적인 방법은 [머클-담가드 쌓기](https://en.wikipedia.org/wiki/Merkle%E2%80%93Damg%C3%A5rd_construction)라는 방법이다. 이 방법의 단순한 버전은 꽤 잘 동작하는 범용 해시 함수를 만드는데 쓸 수 있다. 입력 메시지(데이터)가 주어질 때, 이 방법은 다음과 같이 동작한다.

1.  *초기 상태* 를 초기화 한다.
2.  메시지에서 N 비트 씩 한번에 소모한다. 이를 *블록* 이라고 부르며 보통은 32비트, 64비트, 128비트 등으로 커진다.
3.  현재 블록과 내부 상태 (이전 상태)를 가지고 **믹스** 연산을 수행해서 새로운 내부 상태를 만든다.
4.  소모할 블록이 더이상 남아있지 않을 때까지 2로 돌아가서 블록을 소모한다.
5.  내부 상태를 마무리짓고(finalize) 해시 값을 최종 리턴한다.

여기서 *내부 상태* 란 최소한 해시 값의 크기만큼은 되는 메모리를 말한다. 1번에서 초기화된 값을 보통 초기화 벡터(Initialisation Vector)라고 한다. 이 상태 값은 이후 블록에 대한 믹싱 연산을 진행할 때 체이닝되어 사용되는데, 이를 통해 메시지 블록 사이의 데이터 종속성을 담을 수 있다.

5번에서 내부 상태를 마무리짓는 과정은 최종적으로 리턴할 해시 값을 준비하는 과정이다. 예를 들어 내부 블록 체이닝 연산에 쓰인 중간 값이 최종 해시 값보다 큰 경우 이를 잘라내거나, 기타 매직 넘버를 이용해서 한번 더 최종 해싱을 하는 등의 작업을 한다.


## Hash Functions

### RS Hash

C 책에 나오는 Robert Sedgwicks의 알고리즘이다.

```c++
unsigned int RSHash(const char* str, unsigned int length) {
  unsigned int b = 378551;
  unsigned int a = 63689;
  unsigned int hash = 0;
  unsigned int i = 0;
  for(; i < length; ++str, ++i) {
    hash = hash * a + (*str);
    a = a * b;
  }
  return hash;
}
```

### JS Hash

by Justin Sobel

```c++
unsigned int JSHash(const char* str, unsigned int length) {
  unsigned int hash = 1315423911;
  unsigned int i = 0;
  for (; i < length; ++str, ++i) {
    hash ^= ( (hash << 5) + (*str) + (hash >> 2) );
  }
  return hash;
}
```

### PJW Hash

르네상스 테크놀로지의 Peter J. Weinberger 가 만든 알고리즘이다. 컴파일러 책에서 이 방법을 언급한다고 한다.

```c++
unsigned int PJWHash(const char* str, unsigned int length) {
  const unsigned int BitsInUnsignedInt = (unsigned int) (sizeof(unsigned int) * 8);
  const unsigned int ThreeQuarters = (unsigned int) ((BitsInUnsignedInt * 3) / 4);
  const unsigned int OneEighth = (unsigned int) (BitsInUnsignedInt / 8);
  const unsigned int HighBits = (unsigned int) (0xFFFFFFFF) << (BitsInUnsignedInt - OneEighth);

  unsigned int hash = 0, test = 0, i = 0;
  for (; i < length; ++str, ++i) {
    hash = (hash << OneEighth) + (*str);
    if ((test = hash & HighBits) != 0) {
      hash = ((hash ^ (test >> ThreeQuarters)) & (~HighBits));
    }
  }
  return hash;
}
```

### ELF Hash

PJW Hash랑 비슷한데 32비트 프로세서를 위한 트윅이 들어가있다. 유닉스 기반 운영체제에서 많이 쓰인다.

```c++
unsigned int ELFHash(const char* str, unsigned int length) {
  unsigned int hash = 0, x = 0, i = 0;
  for (; i < length; ++str, ++i) {
    hash = (hash << 4) + (*str);
    if ((x = hash & 0xF0000000L) != 0) {
      hash ^= (x >> 24);
    }
    hash &= ~x;
  }
  return hash;
}
```

### DJB Hash

Daniel J. Bernstein 교수가 제안한 해시 방법으로 유즈넷 뉴스그룹 comp.lang.c 에서 처음 공개되었다. 발표된 것중 가장 효율적인 해시 함수 중 하나이다.
```c++
unsigned int DJBHash(const char* str, unsigned int length) {
  unsigned int hash = 5381, i = 0;
  for (; i < length; str++, i++) {
    hash = ((hash << 5) + hash) + (*str);
  }
  return hash;
}
```
