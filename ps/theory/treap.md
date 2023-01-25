---
layout: page
tags: [problem-solving, theory, tree]
title: Treap
---

# Treap

```cpp
typedef int KeyType;

class Node {
    KeyType key;

    int priority;
    int size;   // of subtree
    Node *left, *right;

    Node(const KeyType& key) : key(key), priority(rand()),
        size(1), left(nullptr), right(nullptr) { }

    void setLeft(Node* left) {
        this->left = left;
        updateSize();
    }

    void setRight(Node* right) {
        this->right = right;
        updateSize();
    }

    void updateSize() {
        size = 1;
        if (left) size += left->size;
        if (right) size += right->size;
    }
};

typedef pair<Node*, Node*> NodePair;

/* Split a treap into two treaps with values less than
  key and values grater than key */
NodePair split(Node* root, KeyType key) {
    if (root == nullptr) {
        return NodePair(nullptr, nullptr);
    }

    if (root->key < key) {
        NodePair rs = split(root->right, key);
        root->setRight(rs.first);
        return NodePair(root, rs.second);
    }

    NodePair ls = split(root->left, key);
    root->setLeft(ls.second);
    return NodePair(ls.first, root);
}

Node* insert(Node* root, Node* node) {
    if (root == nullptr) {
        return node;
    }

    if (root->priority < node->priority) {
        NodePair splitted = split(root, node->key);
        node->setLeft(splitted.first);
        node->setRight(splitted.second);
        return node;
    }
    else if (node->key < root->key) {
        root->setLeft(insert(root->left, node));
    }
    else {
        root->setRight(insert(root->right, node));
    }
    return root;
}

Node* merge(Node* a, Node* b) {
    if (a == nullptr) return b;
    if (b == nullptr) return a;
    if (a->priority < b->priority) {
        b->setLeft(merge(a, b->left));
        return b;
    }

    a->setRight(merge(a->right, b));
    return a;
}

Node* erase(Node* root, KeyType key) {
    if (root == nullptr) return root;

    if (root->key == key) {
        Node* ret = merge(node->left, node->right);
        delete root;
        return ret;
    }

    if (key < root->key) {
        root->setLeft(erase(root->left, key));
    }
    else {
        root->setRight(erase(root->right, key));
    }
    return root;
}

Node* kth(Node*, int k) {
    int leftSize = 0;
    if (root->left != nullptr) leftSize = root->left->size;
    if (k <= leftSize) return kth(root->left, k);
    if (k == leftSize + 1) return root;
    return kth(root->right, k - leftSize - 1);
}

int countLessThan(Node* root, KeyType key) {
    if (root == nullptr) return 0;
    if (root->key >= key) {
        return countLessThan(root->left, key);
    }
    int ls = (root->left ? root->left->size : 0);
    return ls + 1 + countLessThan(root->right, key);
}
```
