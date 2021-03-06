
.. list-table::

  * - XEP:
    - 1
  * - Title:
    - Xonsh Operators Proposal - Three operator approach
  * - Author:
    - anki-code
  * - Status:
    - Stopped with `XEP-2 <XEP-2.rst>`_ appearing
  * - Created:
    - 2020-10-24
  * - Xonsh-Version:
    - 0.9.24

Motivation
**********

The first `command substitution <https://en.wikipedia.org/wiki/Command_substitution>`_ operator (now most known as ``$()``)
was created in 1979 and until nowadays it was used to split the one command output and push it as arguments to another command.

In xonsh the command substitution operator has the same syntax - ``$()`` - but in xonsh it returns the pure output from
one command to another. This behavior not well-known, not expected and leads to a constant need to ``strip``-ping
and ``split``-ting the output of the original command. This brings the syntax overhead to xonsh commands. This is unexpected
behavior for new users. And finally this blurs the difference between another xonsh operators.

The goal of this proposal is to suggest a new behavior for the command substitution operator and changes in another
operators to make the behavior more common and consistent and also with shortening the syntax overhead during usage
the command substitution operators.

This proposal have no goal to create exactly the same behavior and syntax as in previous shells in the shells history.
Also this proposal has no goal to support backwards compatibility exactly. The most use cases was designed with
maximization of backwards compatibility in mind but the operators in xonsh are located very close to the core
functionality and to achieve the real improvement of syntax and logic it requires move away from the backwards compatibility.


Approach
********

The idea behind this approach is to divide operators into three types according to the strength of their effect on the output:

* | ``@$()`` is a high strength of separation the output. In the current version of xonsh it's the same as bash ``$()``
    operator that separate the output by whitespaces. This behavior stays unchanged.
  |

* | ``$()`` is a medium strength of separation the output - by lines. The line - is a middle way. For example if the line
    is a filename with spaces it will be saved as one argument (against previous operator that separate all). It's good
    property for the cross-platform and for most use cases.
  |

* | ``!()`` is the zero strength of separation the output. This operator returns pure output to any further custom separation and decoration.
  |

Changes
*******

The changes that suggested. Everything else stays unchanged.

.. list-table::
    :header-rows: 1

    * - Before
      - After

    * - ``$()`` returns output string.
      - ``$()`` returns object that originally the list of lines produced by the Python built in function `splitlines() <https://docs.python.org/3.8/library/stdtypes.html#str.splitlines>`_. The object has additional string representation and functions.

    * - ``!()`` raises error in subproc mode.
      - ``!()`` returns output string in subproc mode - the same as ``$()`` before.

    * - ``@(!())`` returns list of lines with trailing new line in every line.
      - ``@(!())`` returns output string the same as ``!()`` in subproc mode.


Git-branch with changes
***********************

To trying the changes install xonsh from branch:

.. code-block:: bash

    pip install -U git+https://github.com/anki-code/xonsh.git@captured_subproc
    xonsh --no-rc

Note! Not all features described in this proposal are implemented yet i.e. ``@(!())`` still returns the list.
PRs are welcome!

How will the use cases change
*****************************

The table of use cases compares the syntax of the current xonsh and the proposed.

.. list-table::
    :widths: 5 30 60
    :header-rows: 1

    * - Use case
      - Subproc current / proposed
      - Python current / proposed

    * - Get single argument.

        ✅ Becomes shorter.

      - ``id @($(whoami).rstrip())``
      
        ``id $(whoami)``
      - ``name = $(whoami).rstrip()``     
            
        ``name = $(whoami).str``
        
    * - Get multiple arguments.

        ✅ Becomes shorter.

      - ``du @($(ls).rstrip().split('\n'))``
      
        ``du $(ls)``
      - ``files = $(ls).rstrip().split('\n')``
            
        ``files = $(ls)``

    * - Get pure output.

        🔀️ The similar.

      - ``echo -n $(curl https://xon.sh) | wc -c``
      
        ``echo -n !(curl https://xon.sh) | wc -c``
      - ``html = $(curl https://xon.sh)``     
            
        ``html = !(curl https://xon.sh).out``

    * - Custom output splitting.

        🔀 Becomes clearer.

      - The similar as python mode.
      - ``shell = $(head -n1 /etc/passwd)[:-1].split(':').pop()``

        ``shell = $(head -n1 /etc/passwd).str.split(':').pop()``

    * - Apply string function to every line.

        ✅ Becomes shorter.

      - The similar as python mode.
      - ``lines = [l.strip() for l in $(ifconfig)[:-1].split('\n')]``

        ``lines = $(ifconfig).lines_strip()``

    * - ``grep`` single argument.

        ✅ Fix the bug.

      - ``cat /etc/passwd | grep $(whoami)``

        Wrong output of all lines in current version.

        One correct single line after update.

      - Not applicable.



Feel free to `suggest your use cases <https://github.com/anki-code/xonsh-operators-proposal/issues>`_.

OutputLines object
******************

In Python mode the ``$()`` operator returns ``OutputLines`` object that:

* Inherited from ``list`` class and is constructed as ``output.splitlines()``.
* Has ``str`` representation as ``os.sep.join(self)``.
* Has ``str`` property to short access i.e. ``name = $(whoami).str``.
* Has all string methods i.e. the ``$().find(txt)`` will return ``str(self).find(txt)``.
* Has all string methods for lines i.e. ``$().lines_find(txt)`` will return ``[l.find(txt) for l in self]``.

*Potentially (to discuss):*

* Has ``lines(sep)`` method to return the lines splitted by ``sep`` i.e. ``fields = $(cat table.txt).lines('|')``.
* Has ``words`` property to return the same as ``@$()`` operator and replace it.
* Has ``out``/``output``/``o`` property to return the same as ``!()`` operator and replace it.
* Will be merged with ``CommandPipeline`` object to replace ``!()`` operator.

In subprocess mode the ``$()`` operator returns ``OutputLines`` object that becomes the list of lines.

Backwards compatibility
***********************

What will be broken after update:

.. list-table::
    :widths: 70 29
    :header-rows: 1

    * - Case
      - Fix

    * - Functions that expect string but not convert the argument to string representation:

        ``json.loads($(curl https://api.github.com/orgs/xonsh))``

        TypeError: the JSON object must be str. List given.

      - Replace ``$()`` to ``!()`` or use ``$().str``.

    * - Using ``!()`` as list i.e. ``@([l.rstrip() for l in !(ls)])``

      - Replace ``!()`` to ``$()``.



What will not be broken after update:

* String function calls i.e. ``$(whoami).strip()``, ``$(ls).split('\n')``.
* Simple conditions i.e. `if $(date | grep 59):`

Questions
*********

1. From @scopatz: I think using $() in xonsh to split into a list of arguments is a neat idea,
   but it would necessitate the addition of some default or configurable way to split those arguments.
   For example, should $() be split by lines or by whitespace (like effectively what Bash does)?

   **Answer**: In this approach the setting of the complex splitting algorithm belongs to ``!()`` operator
   that represents the pure output. It's assumed that the user should use ``@(!(cmd).split('-|-'))``
   approach for complex cases.

2. From @anki-code: Can we use one operator ``$()`` and completely remove ``!()`` by moving the ``!()`` object
   functionality to ``$()``? It looks interesting because in subprocess mode the ``!()`` operator always used with python
   substitution i.e. ``@(!().split())``. Is there a way to remove ``!()`` and do ``@($().split())``. Does it make sense?

   **Answer**: I'm going to review the possibilities to merge ``$()`` and ``!()``. `Discussion <https://github.com/anki-code/xonsh-operators-proposal/issues/1>`_.

3. From @scopatz: What happens with the other subprocess operators depending on their calling modes: ![], !(), $[]

   **Answer**: <todo>

4. From @scopatz: What do we do with the @$() operator? The initial idea for @$() what that you could register
   transformation functions (like a decorator), that would modify output. For example, @upper$() would uppercase
   the output. Or you could apply many times, like @split@upper(). Then what we have now would just be the default
   value: @split$() == @$(). However, this was never fully done, so maybe it is better to drop the syntax entirely.

   **Answer**: Probably we can replace it to something like ``@($().words)`` but it's new syntax overhead and
   new backwards compatibility issue. We'll think about dropping ``@$()`` on final stages of this proposal
   detalization.



Proposals to this proposal
**************************
There are two degrees of freedom:

* Setting different behavior of the operator in subproc and python mode.
* Returning the Python object from the operator that has an ability to return list or str representations and has any
  functions and properties.

Current proposal could be improved by suggestion with more optimal or useful properties of the objects that were returned by operators.
