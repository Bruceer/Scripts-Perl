# Scripts-Perl
Collected from daily work



## Makefile学习札记

```makefile
runone_%:
  mkdir -p debug/$*
```

blog/details.py

import markdown
from django.shortcuts import render, get_object_or_404
from .models import Post

def detail(request, pk):
    post = get_object_or_404(Post, pk=pk)
    post.body = markdown.markdown(post.body,
                                  extensions=[
                                     'markdown.extensions.extra',
                                     'markdown.extensions.codehilite',
                                     'markdown.extensions.toc',
                                  ])
    return render(request, 'blog/detail.html', context={'post': post})
