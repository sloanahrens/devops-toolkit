#What is DevOps? From "First" Principles.

DevOps is, to put it simply, the modern art of managing software life-cycles. The learning curve can be steep, and many of the ideas involved can seem confusing or even paranoid to those who lack direct experience with the *need* for DevOps.

What if you had to explain DevOps to somebody who "doesn't know anything about computers"? I thought it was an interesting question, and decided to try to answer it.

So let's start at the beginning. Not the beginning of computer history, but the beginning of computer absractions.

Binary Numbers
---

You can't understand the behavior of computers without understanding how they "think". Computers think in binary. Every single operation done on a computer comes down to binary arithmetic. Luckily it's not that hard to gain a basic understanding of now binary numbers arithmetic works, if you already know how to do decimal arithmetic.

Binary numbers are like decimal numbers, but where decimal numbers use ten digits (0-9), binary uses only two (0-1).

- 0 in binary is 0 in decimal.
- 1 in binary is 1 in decimal.
- 10 in binary is 2 in decimal.
- 11 in binary is 3 in decimal.

The four statements above constitute a two-bit system. With two binary digits, you can represent the (decimal) numbers 0-3.

- 100 in binary is 2^2 = 4 in decimal
- 1000 is 2^3 = 8
- 10000 is 2^4 = 16
- ...
- 1000000 is 2^8 = 256

Notice that it took three bits to represent the (decimal) number 4. It took nine digits to write 256 in binary. Therefore, using eight bits--eight binary digits--I can represent the decimal numbers from 0 (0) to 255 (11111111).

You can see how the decimal versus binary numbers add up by looking at them side-by-side:

```
Binary:  11111111 = 10000000 + 1000000 + 100000 + 10000 + 1000 + 100 + 10 + 1
Decimal: 255      = 128      + 64      + 32     + 16    + 8    + 4   + 2  + 1
```

Remember how old-school [Link](https://en.wikipedia.org/wiki/The_Legend_of_Zelda) could only hold up to 255 Rupees? Eight-bit system is why.


Computers and Assembly Language.
---

Modern computers are almost all based on the [Von Neumann architecture](https://en.wikipedia.org/wiki/Von_Neumann_architecture). A simplified picture of Von Neumann architecture is a simple processor and some RAM.

A processor has a [word-size](https://en.wikipedia.org/wiki/Word_(computer_architecture)), always a multiple of two and usually a multiple of eight. 64-bit processors are the norm these days. The simplest processor, and where you would start if you wanted to learn how to do all the math, would be an 8-bit processor (like the original [Nintendo Entertainment System](https://en.wikipedia.org/wiki/Nintendo_Entertainment_System)).

So an 8-bit processor has a "word size" of 8. Every instruction it runs--and the result of every instruction it runs--consist of 8-bit binary numbers. We'll talk about binary numbers in a minute.

Every "cell" of RAM--every individually-addressable unit--is the same size as the word size of the processor, eight bits in the simplest case. Every RAM cell has both an "address" (which never changes) and a "value" (which can change), both of which would be eight bits for an 8-bit processor in the simplest case.

A processor has one or more "registers", where it can store a word-sized amount of data. Could be an address in RAM, could be the result of a calculation and/or the input for another calculation, but it is always a word-sized binary number.

I won't go through and attempt to explain processor instruction sets, but it suffices to say that every instruction a processor can run must be a binary operation that can be encoded as an eight-bit number, whose input(s) and output are always eight-bit binary numbers. The instruction set thus encoded can ALSO be encoded in a human-readable way, and this hardware-specific "programming language" is known as "assembly language" or just "assembler".


Modern Computers
---

Modern processors and RAM systems are much more complex than a simple 8-bit system, of course, but the ideas scale up, and the toy computer model of an 8-bit processor and accompanying RAM gives you the basic idea. Every computation done by a modern cloud computer comes down ultimately to a machine instruction encoded as a binary number, operating on binary numbers and outputting binary numbers. These operations can all also be encoded as statements in a hardware-specific assembly language. We don't use assembly languages to build software, usually, because it's very difficult to use. Our brains don't think like computers. So we add layers of abstraction--higher-level tools--to allow us to express logic we wish the computer to execute in a more natural but still mathematically-precise way.

High-Level Programming Languages
---

High-level languages allow the programmer to express logic in a more natural way than with assembly languages, and offers other advantages as well. Computer code can be written in a single document (in the simplest case), which is always the same no matter what sort of computer runs it. Contrast this with assembly language which is specific for every different kind of processor. C-code can be written in a simple text file, then [compiled]() into an [executable]() for use on specific computers.

Even high-level programming languages come in different levels of abstraction. So-called "low-level high-level languages", especially C, require that the programmer budget, account for, and relinquish their own RAM as needed. Higher-level languages abstract RAM usage away from the programmer and have "garbage collection" to free up RAM that has been used and then abandoned.

High-level interpreted languages like Python and Java go a step further and do away with the hardware-specific compiled executable and instead run the code file(s) line-by-line in an "interpreter" which is itself a [virtual machine]() that is in turn implemented by core developers for each and every available hardware system (including [Raspberry Pi](https://www.raspberrypi.org/documentation/usage/python/)). The Java Virtual Machine is legendary; you can even run [Python on the JVM]() if you really want to. I'm being a little bit sloppy, because Java Bytecode; this Stack Overflow post addresses [JVM versus Python Interpreter](https://stackoverflow.com/questions/441824/java-virtual-machine-vs-python-interpreter-parlance). My point is that organization power in computing is often gained by adding layers of abstraction. Binary -> Assembler -> C-like language -> Python-like language. Each layer adds a lot of complexity but provides for a simpler and more powerful expression of human-crafted logic.

Text Files, Text Editors, and Source Control
---

Almost all software built by humans is represented in some way by text files, and those text files are source control. Source control allows developers to make changes to the code files asynchronously and then merge their changes together and deal with conflicts, issues, bugs, etc in a systematic and pre-defined way. The most popular command-line tool for managing source control is [Git](), and the most popular remote repository hosting service is [Github](https://gitub.com). This model enables open-source software because it can allow many users to contribute expertise, and open-source tools are often hosted on Github.

If you want to submit a pull request (asking that your changes be merged into the `master` branch of a remote code repository), you would first "clone" the repository to your local system (your laptop, say), make your changes to the relevant code text files--perhaps making use of one of any number of available [text editors](https://en.wikipedia.org/wiki/Comparison_of_text_editors), then "commit" your code changes to a "branch" of the repository (repo), "push" your changes, on your branch, to the remote repository, and create a "pull request" asking your branch--and therefore your code changes--be merged into the "master" branch, so that from that point on, everyone who uses the code in the repository will have your changes integrated into the code they use.

Text editors for use with code files come in many shapes and sizes, some specialized for certain languages and some attempting to be quite general. There are text editors that can only be used from the command line, and some that are purely point-and-click or even in some cases drag-and-drop. In the simplest case you might just open your computer's simplest text editor (like [Notepad]() or [TextEdit]()), make a change to a file, save the change, and then push the new version of the file to Github.

- Open-Source Tools
- Automated Testing
- Servers, HTTP, and Web Frameworks
- Hardware emulation and virtual machines
- System administration, Unix, Linux, Ubuntu
- Cloud computing
- Pets versus cattle
- Infrastructure as code, in source control
- Principles of DevOps
- Continuous integration/deployment
- Microservices
- Containerization 
- Orchestration
- Security