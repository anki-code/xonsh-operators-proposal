### Changes

| Before | After |
|---|---|
|`$()` returns output string | `$()` returns list of lines from output |
| `!()` raises error in subproc mode | `!()` returns output string in subproc mode - the same as `$()` before |

### Why

It allows to write subproc commands clear and beauty - without explicit stripping:

| Before | After |
|---|---|
| `cat @($(echo filename).strip())` | `cat $(echo filename)` |
| `du -sh @$(ls)` - error around spaces in names | `du -sh $(ls)` |
|  `make -j @($(nproc).strip())` | `make -j $(nproc)` |
| `[f for f in $(ls).rstrip().split('\n')]` | `[f for f in $(ls)]` |
| `echo !(echo echo)` raises error | `echo !(echo echo)` works |

### Consistency
Current operators (xonsh 0.9.24):
|Operator| Subproc | Python |
|--------|---------|--------|
|`$()`   | output | output |
|`!()`   | - | object |
|`@(!())`   | output | - |
|`$[]`   | - | None |
|`![]`   | - | object |
|`@$()`  | splitted output | - |
|`@()`   | python susbstitution | - |

Current operators (xonsh 0.9.24) have a lack of consistency:
| Low: no splitting | Medium: lines splitting | High: full splitting |
|---|---|---|
| `$()` | - | `@$()` |

What changed:
|Operator| Subproc | Python |
|--------|---------|--------|
|`$()`   | ✔️ output lines | ✔️ output lines |
|`!()`   | ✔️ output | object |

Why `@$()` is not working for this?
* `@$()` already has behavior the same as bash splitting. The line `123\n1 2 3` becomes `['123','1','2','3']` that is very special and not be used for file names and another lines that contains spaces.

Why `$()` will be changed?
* `$()` operator is common and well known as command output substitution in many shells.
* and `!()` already works similar as suggested in PR in python mode: `echo @(!(echo 123))` returns `123`. Using it in subproc mode to getting pure output is consistent with python mode.

After this changes the operators logic becomes complete and has consistency::
| Low: no splitting | Medium: lines splitting | High: full splitting |
|---|---|---|
| `!()` | `$()` | `@$()` |

### Install and try
```
pip install -U git+https://github.com/anki-code/xonsh.git@captured_subproc
xonsh --no-rc
du -sh $(ls ~/.xonshrc)
cat /etc/passwd | grep $(whoami)
```

### Some examples
```python
repr($(echo 123))
# ['123']

repr(!(echo 123))
# CommandPipeline object

echo 123 > filename
cat $(echo filename)   # Runs: cat filename
# 123

# count of characters in original text
echo -n !(head filename) | wc -c

# substitution becomes clean
name = $(whoami)  # ['user']
cat /etc/passwd | grep @(name)

# getting a name string
name, = $(whoami)
name = str($(whoami))
name = $(whoami)[0]
name = $(whoami).pop()
```

### What about splitting the lines in `$()`?
The algorithm of splitting lines is Python built in. Nothing special:
```python
' 123\n321 \n'.splitlines()
#[' 123', '123 ']

echo -n ' 123\n321 \n' > qwe
$(cat qwe)
# [' 123', '321 ']
```

### What will break and how to fix:

<table>
<thead>
<tr>
<td>Error</td>
<td>Fix</td>
</tr>
</thead>

<tbody>

<tr>
<td valign="top" >
Using <code>$()</code> as a string argument but it will be a list after PR. <br><br>
<code>json.loads($(curl https://api.github.com/orgs/xonsh))</code><br>
TypeError: the JSON object must be str
</td>
<td valign="top" >
Replace <code>$()</code> to <code>!()</code><br><br>
<code>json.loads(!(curl https://api.github.com/orgs/xonsh))</code><br>
or <code>json.loads(str($(curl https://api.github.com/orgs/xonsh)))</code><br>

</td>
</tr>

<tr>
<td valign="top" >
Call string function.<br><br>
<code>$(whoami).strip()</code><br>
<s>AttributeError: 'OutputLines' object has no attribute 'strip'</s>
</td>
<td valign="top" >
✅ The lines wrapped into <code>OutputLines</code> class that have <code>list</code> behavior with additional <code>str</code> functions. And now you can call <code>$().strip()</code> like before.

</td>
</tr>

</tbody>

</table>

### Additional bonus

The lines wrapped into `OutputLines` class that have `list` behavior with additional `str` and  `lines_<str function>`functions. And now you can:
```python
$(head /etc/passwd).lines_split(':')
#[['root', 'x', '0', '0', 'root', '/root', '/bin/bash'],
# ['daemon', 'x', '1', '1', 'daemon', '/usr/sbin', '/usr/sbin/nologin']]

$(head -n 2 /etc/passwd).find('daemon')
# 32

$(head -n 2 /etc/passwd).lines_find('bin')
# [23, 26]  # positions of bin in every line
```
