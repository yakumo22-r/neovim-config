#!/bin/bash

# define a variable
name="John Doe"

# if statement
if [ "$name" == "John Doe" ]; then
    echo "Hello, John!"
else
    echo "Hello, stranger!"
fi

# for loop
for i in {1..5}; do
    echo "$i"
done

# while loop
count=0
while [ $count -lt 5 ]; do
    echo "Count: $count"
    ((count++))
done

# function
function greet {
    echo "Hello, \$1!"
}

# call function
greet "Alice"

# array
fruits=("apple" "banana" "cherry")

# access array element
echo ${fruits[1]} # command substitution files=$(ls)

# input/output redirection
echo "Hello, world!" >output.txt
cat <input.txt

# arithmetic expansion
x=5
y=10
echo $((x + y))

# comment
# This is a comment

# shell options
set -o noclobber
