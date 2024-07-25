---
title: optimized_cpp-ch2
date: 2021-11-13 00:34:39
tags: 
- C++
categories: 
- 语言
---

# Ch2 实现智能指针

智能指针最基本的功能：对超出作用域的对象进行释放

<!-- more -->

```cpp
// class shape_type
enum class shape_type {
    circle,
    triangle,
    rectangle,
};
// create shape
shape* create_shape(shape_type type) {
    switch (type) {
    case shape_type::circle:
        return new circle();
    case shape_type::triangle:
        return new triangle();
    case shape_type::rectangle:
        return new rectangle();
    }
}
// wrapper
class shape_wrapper {
public:
  explicit shape_wrapper(shape* ptr = nullptr): ptr_(ptr) {}
  ~shape_wrapper() {
    delete ptr_;
  }
  shape* get() const { return ptr_; }

private:
  shape* ptr_;
};
// example function
void foo() {
    // ...
    shape_wrapper ptr_wrapper(create_shape(...));
    // ...
}
```

为了保证使用`create_shape`的返回值时，不会出现内存泄漏。我们需要把这个返回值放到一个本地变量中，并确保其析构函数会删除该对象。



`shape_wrapper`仍然缺少的功能：

* 这个类只适用于shape类
* 行为不太像指针
* 拷贝这类对象会引发异常



**包装任意类型的指针**

使用模板：

```cpp
template <typename T>
class smart_ptr {
public:
  explicit shape_wrapper(T* ptr = nullptr): ptr_(ptr) {}
  ~shape_wrapper() {
    delete ptr_;
  }
  T* get() const { return ptr_; }

private:
  T* ptr_;
};
```



**使`smart_ptr`行为更像指针**

指针可以：

* 用`*`解引用
* 用`->`指向对象成员
* 用在布尔表达式中



加几个成员函数：

```cpp
template <typename T>
class smart_ptr {
	//...
	T& operator*() const {return *ptr_;}
    T* operator->() const {return ptr_;}
    operator bool() const {return ptr_;}
    //...
};
```



**拷贝构造和赋值**

在拷贝智能指针时，因为对象并没有复制一份，因此可能会对同一块内存释放两次，导致程序崩溃。

因此需要禁用拷贝：

```cpp
template <typename T>
class smart_ptr {
	//...
    smart_ptr(const smart_ptr&)
        = delete;
    smart_ptr& operator=(const smart_ptr&)
        = delete;
};
```

但是```smart_ptr<shape> ptr2{ptr1}```仍然可能出现释放两次内存的错误。



因此尝试在拷贝时转移指针的所有权：

```cpp
template <typename T>
class smart_ptr {
    // 拷贝构造函数
    smart_ptr(smart_ptr& other) {
		ptr_ = other.release();
    }
    // 赋值函数
    smart_ptr& operator=(smart_ptr& rhs) {
		smart_ptr(rhs).swap(*this); // 构造临时对象
        return *this;
    }
    // 释放对指针的所有权
    T* release() {
        T* ptr = ptr_;
        ptr_ = nullptr;
        return ptr;
    }
    // 交换对指针的所有权
    void swap(smart_ptr& rhs) {
        using std::swap;
        swap(ptr_, rhs.ptr_);
    }
};
```

上面的实现的问题是：

如果把一个smart_ptr传递给另一个，你就不再拥有这个对象了。



**使用“移动”改善smart_ptr的行为**

```cpp
template <typename T>
class smart_ptr {
    // 移动构造
	smart_ptr(smart_ptr&& other) {
		ptr_ = other.release();
    }
    // 拷贝构造
    smart_ptr& operator=(smart_ptr rhs) {
        rhs.swap(*this);
        return *this;
    }
};
```

> C++的规则：
> 如果提供了移动构造函数而没有手动提供拷贝构造函数，那么后者会被禁用。

因此：

```cpp
smart_ptr<shape> ptr1{create_shape(shape_type::circle)};
smart_ptr<shape> ptr2{ptr1};             // 编译出错
smart_ptr<shape> ptr3;
ptr3 = ptr1;                             // 编译出错
ptr3 = std::move(ptr1);                  // OK，可以
smart_ptr<shape> ptr4{std::move(ptr3)};  // OK，可以
```

以上就是C++11的`unique_ptr`的基本行为



但是，一个`circle*`可以隐式地转换成`shape*`，而上面地`smart_ptr<circle>`却不能自动转换成`smart_ptr<shape>`，这还不够自然。

```cpp
template <typename U>
class smart_ptr {
	smart_ptr(smart_ptr<U>&& other) {
        ptr_ = other.release(); // 不正确的转换会在编译时报错
    }  
};
```

上面的这个构造函数不会被编译器看作是移动构造函数



**引用计数**

和`unique_ptr`相比，多个`shared_ptr`可以同时拥有一个对象，因此它们需要共享一个计数。

```cpp
class shared_count {
public:
	shared_count();
    void add_count();
    long reduce_count();
    long get_count() const;
private:
    long count;
};
```



添加了shared_count的smart_ptr：

```cpp
template <typename T>
class smart_ptr {
public:
    explicit smart_ptr(T* ptr = nullptr): ptr_(ptr) {
        if(ptr) {
            shared_count_ = new shared_count();
        }
    }
    ~smart_ptr() {
        if(ptr_ && shared_count_->reduce_count()) {
            delete ptr_;
            delete shared_count_;
        }
    }
private:
    T* ptr_;
    shared_count* shared_count_;
};
```



新的swap函数：

```cpp
void swap(smart_ptr& rhs) {
	using std::swap;
	swap(ptr_, rhs.ptr_);
	swap(shared_count_, rhs.shared_count_);
}
```



新的拷贝构造，移动构造函数：

```cpp
smart_ptr(const smart_ptr& other) {
    ptr_ = other.ptr_;
    if (ptr_) {
      other.shared_count_->add_count();
      shared_count_ = other.shared_count_;
    }
}
template <typename U>
smart_ptr(const smart_ptr<U>& other) {
    ptr_ = other.ptr_;
    if (ptr_) {
      other.shared_count_->add_count();
      shared_count_ = other.shared_count_;
    }
}
template <typename U>
smart_ptr(smart_ptr<U>&& other) {
    ptr_ = other.ptr_;
    if (ptr_) {
      shared_count_ = other.shared_count_;
      other.ptr_ = nullptr;
    }
}
```



**指针类型转换**

c++中有不同的类型强制转换：
`static_cast`、`reinterpret_cast`、`const_cast`、`dynamic_cast`

