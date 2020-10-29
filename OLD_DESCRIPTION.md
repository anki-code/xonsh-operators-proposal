Unsorted

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
