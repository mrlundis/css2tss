# CSSTSS
A CSS to TSS (Titanium Style Sheet) compiler.

## Usage
### Example
```coffeescript
compile = require "csstss"
tss = compile "Label, Button { font-family: Arial; }"
```

### Output
```javascript
"Label": {
    "font": {
        "fontFamily": "Arial"
    }
}
"Button": {
    "font": {
        "fontFamily": "Arial"
    }
}
```
