xonsh operators proposal
------------------------

Motivation
**********

The first command substitution operator (now most known as ``$()``) was created in 1979 and until nowadays `it was used to split the one command output and push it as arguments to another command <https://en.wikipedia.org/wiki/Command_substitution>`_.

In xonsh the command substitution operator has the same syntax - ``$()`` - but in xonsh it returns the pure output from one command to another. This behavior not well-known and not expected and leads to a constant need to ``strip``-ping and ``split``-ting the output of the original command. This brings syntax overhead to xonsh commands. This is unexpected behavior for new users. And finally this blurs the difference between another xonsh operators.

The goal of this proposal is to suggest new behavior for command substitution operator in xonsh and changes in another operators to make the behavior more common and consistent and also with shortening the syntax overhead during usage the command substitution operators.

This proposal have no goal to create exactly the same behavior and syntax as in previous shells in the shells history. Also this proposal has no goal to support backwards compatibility exactly. The most use cases was designed with miximization of backwards compatibility in mind but the operators in xonsh are located very close to the core functionality and to achieve the real improvement of syntax and logic it requires step off from backwards compatibility.

Changes
*******

.. list-table::
    :header-rows: 1

    * - Before
      - After
    * - ``$()`` returns output string.
      - ``$()`` returns object that originally the list of lines produced by the Python built in function `splitlines() <https://docs.python.org/3.8/library/stdtypes.html#str.splitlines>`_. The object has additional string representation and functions.
    * - ``!()`` raises error in subproc mode.
      - ``!()`` returns output string in subproc mode - the same as $() before.
    * - ``@(!())`` returns list of lines with trailing new line in every line.
      - ``@(!())`` returns output string the same as ``!()`` in subproc mode.


Changes in use cases
********************

.. list-table::
    :header-rows: 1

    * - Use case
      - Subproc before / after
      - Python before / after
    * - Get single argument
      - ``id @($(whoami).rstrip())``
      
        ``id $(whoami)``
      - ``name = $(whoami).rstrip()``     
            
        ``name = $(whoami).str``
        
    * - Get multiple arguments
      - ``du @($(ls).split('\n'))``
      
        ``du $(ls)``
      - ``files = $(ls).split('\n')``     
            
        ``files = $(ls)``
        

