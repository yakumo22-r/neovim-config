#include <algorithm>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <vector>
// macro
#define MACRO std::cout

// Define an enumeration type
enum class Color
{
    RED,
    GREEN,
    BLUE
};

// Basic function declaration
int add(int a, int b) { return a + b; }

// Class template definition
template <typename T>
class Container
{
  public:
    void add(const T& element) { elements.push_back(element); }

    T get(int index) const
    {
        if (index < 0 || static_cast<size_t>(index) >= elements.size())
        {
            throw std::out_of_range("Index out of range");
        }
        return elements[index];
    }

  private:
    std::vector<T> elements;
};

// Inheritance and polymorphism
class Shape
{
  public:
    virtual void draw() const = 0; // Pure virtual function
    virtual ~Shape() {}
};

class Circle : public Shape
{
  public:
    void draw() const override
    {
        std::cout << "Drawing a circle." << std::endl;
    }
};

// Lambda expression and function object
auto compare = [](int a, int b) { return a < b; };

// Function that takes a lambda or function object
void sortVector(std::vector<int>& vec,
                const std::function<bool(int, int)>& comp)
{
    std::sort(vec.begin(), vec.end(), comp);
}

// Exception handling
void mightGoWrong()
{
    bool errorOccurred = true;
    if (errorOccurred)
    {
        throw std::runtime_error("Something went wrong");
    }
}

// Smart pointers
std::unique_ptr<Shape> createShape() { return std::make_unique<Circle>(); }

// Main function
int main()
{
    // Working with STL containers
    std::map<std::string, int> wordCount;
    wordCount["hello"] = 1;
    wordCount["world"] = 2;

    // Using auto keyword
    for (const auto& pair : wordCount)
    {
        std::cout << pair.first << " appears " << pair.second << " times."
                  << std::endl;
    }

    // Try-catch block
    try
    {
        mightGoWrong();
    }
    catch (const std::exception& e)
    {
        std::cerr << "Caught exception: " << e.what() << std::endl;
    }

    // Using the class template
    Container<double> container;
    container.add(3.14);
    std::cout << "Container element: " << container.get(0) << std::endl;

    // Working with smart pointers and polymorphism
    std::unique_ptr<Shape> shape = createShape();
    shape->draw();

    // Using lambda expressions
    std::vector<int> numbers = {3, 1, 4, 1, 5, 9};
    sortVector(numbers, compare);
    for (int num : numbers)
    {
        std::cout << num << ' ';
    }
    std::cout << std::endl;

    return 0;
}
