# VisDoc
A tool to generate html documentation from ActionScript 2.0, 3.0 and Java class files.


## Examples
* [http://asaplibrary.org/](http://arthurclemens.github.io/asaplibrary/html/all-packages.html)
* http://as3.casalib.org/docs/

### Examples older versions of VisDoc
* [smartfoxserver.com](http://docs2x.smartfoxserver.com/api-docs/redbox/html/overview-tree.html)


## Also used by
* https://github.com/jcarpe/jcarpe
* https://github.com/joskoomen/YT-API-AS3
* https://github.com/lucasmotta/NuMediaPlayer


## Usage

VisDoc can be used from the command line (platform neutral, Perl required) or using an application (on Mac).

The application is straightforward. 

Using the command line:
```
perl VisDoc.pl -doc-sources "path/to/my/dir/or/files" -output "path/to/my/output/dir"
```

Additional parameters with default values:
```
footerText            '',
docencoding           'utf-8',
eventHandlerPrefixes  'on,allow',
eventHandlers         1,
extensions            'as,java',
generateNavigation    1,
ignoreClasses         '',
includeSourceCode     0,
projectTitle          'Documentation',
listPrivate           0,
log                   '',
openInBrowser         0,
output                '',
preserveLinebreaks    1,
saveXML               0,
templateCssDirectory  'templates/css',
templateJsDirectory   'templates/js',
templateFreeMarker    'templates/ftl/VisDoc.ftl',
```


## Licence

The MIT License

Copyright (c) 2010-2012 Arthur Clemens, arthur@visiblearea.com and VisDoc contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
