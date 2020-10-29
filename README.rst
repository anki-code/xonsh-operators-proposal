
.. raw:: html

    <p align="center">
    <h1 align="center">xonsh operators proposal</h1>
    </p>

    <p align="center">
    If you like the proposal click ⭐ on the repo and stay in watchers.
    </p>

Motivation
**********

The first `command substitution <https://en.wikipedia.org/wiki/Command_substitution>`_ operator (now most known as ``$()``)
was created in 1979 and until nowadays it was used to split the one command output and push it as arguments to another command.

In xonsh the command substitution operator has the same syntax - ``$()`` - but in xonsh it returns the pure output from
one command to another. This behavior not well-known, not expected and leads to a constant need to ``strip``-ping
and ``split``-ting the output of the original command. This brings syntax overhead to xonsh commands. This is unexpected
behavior for new users. And finally this blurs the difference between another xonsh operators.

The goal of this proposal is to suggest a new behavior for command substitution operator in xonsh and changes in another
operators to make the behavior more common and consistent and also with shortening the syntax overhead during usage
the command substitution operators.

This proposal have no goal to create exactly the same behavior and syntax as in previous shells in the shells history.
Also this proposal has no goal to support backwards compatibility exactly. The most use cases was designed with
maximization of backwards compatibility in mind but the operators in xonsh are located very close to the core
functionality and to achieve the real improvement of syntax and logic it requires step off from backwards compatibility.


Approach
********

The idea behind this approach is to divide operators into three types according to the strength of their effect on the output:

* | ``@$()`` is a high strength of separation the output. In the current version of xonsh it's the same as bash ``$()``
    operator that separate the output by whitespaces. This behavior stays unchanged.
  |

* | ``$()`` is a medium strength of separation the output - by lines. The line - is a middle way. For example if the line
    is a filename with spaced it will be saved as one argument (against previous operator that separate all). It's good
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
      - ``!()`` returns output string in subproc mode - the same as $() before.

    * - ``@(!())`` returns list of lines with trailing new line in every line.
      - ``@(!())`` returns output string the same as ``!()`` in subproc mode.


Git-branch with changes
***********************

To trying the changes install xonsh from branch:

.. code-block:: bash

    pip install -U git+https://github.com/anki-code/xonsh.git@captured_subproc
    xonsh --no-rc


How will the use cases change
*****************************

The table of use cases compares the syntax of the current xonsh and the proposed.

`Switch the page to the better view <https://github.com/anki-code/xonsh-operators-proposal/blob/main/README.rst#how-will-the-use-cases-change>`_ for more comfortable reading the table:

.. list-table::
    :widths: 1 5 30 60
    :header-rows: 1

    * - #
      - Use case
      - Subproc current / proposed
      - Python current / proposed

    * - 1
      - Get single argument
      - ``id @($(whoami).rstrip())``
      
        ``id $(whoami)``
      - ``name = $(whoami).rstrip()``     
            
        ``name = $(whoami).str``
        
    * - 2
      - Get multiple arguments
      - ``du @($(ls).split('\n'))``
      
        ``du $(ls)``
      - ``files = $(ls).split('\n')``     
            
        ``files = $(ls)``

    * - 3
      - Get pure output
      - ``echo -n $(curl https://xon.sh) | wc -c``
      
        ``echo -n !(curl https://xon.sh) | wc -c``
      - ``html = $(curl https://xon.sh)``     
            
        ``html = !(curl https://xon.sh).out``

    * - 4
      - ``grep`` single argument
      - ``cat /etc/passwd | grep $(whoami)``

        Wrong output of all lines in current version.

        One correct single line after update.

      -


Feel free to suggest your use cases.

Backwards compatibility
***********************

What will be broken after update:

.. list-table::
    :widths: 1 70 29
    :header-rows: 1

    * - #
      - Case
      - Fix

    * - 1
      - Functions that expect string but not convert the argument to string representation:

        ``json.loads($(curl https://api.github.com/orgs/xonsh))``

        TypeError: the JSON object must be str.

      - Replace ``$()`` to ``!()`` or use ``$().str``.

    * - 2
      - Using ``!()`` as list i.e. ``@([l.rstrip() for l in !(ls)])``

      - Replace ``!()`` to ``$()``.



What will not be broken after update:

* String function calls i.e. ``$(whoami).strip()``, ``$(ls).split('\n')``.
* Simple conditions i.e. `if $(date | grep 59):`


Proposals to this proposal
**************************
There are two degrees of freedom:

* Setting different behavior of the operator in subproc and python mode.
* Returning the Python object from the operator that has an ability to return list or str representations and has any
  functions and properties.

Current proposal could be improved by suggestion with more optimal or useful properties of the objects that were returned by operators.

Questions
*********

* @scopatz: I think using $() in xonsh to split into a list of arguments is a neat idea,
  but it would necessitate the addition of some default or configurable way to split those arguments.
  For example, should $() be split by lines or by whitespace (like effectively what Bash does)?
