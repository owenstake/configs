// order footnote
// get ref footnote
fns = document.querySelectorAll(".md-footnote>.md-text>.md-plain")
let cnt=0
let m = new Map()
for (var i=0;i<fns.length;i++) { 
    let c = fns[i].textContent
    // deal duplicate entry
    if (!m.has(c)) {
        cnt++
        m.set(c,cnt)
    }
    fns[i].textContent = m.get(c)
}

// get footnote and update footnote number and its ref
rfns = document.querySelectorAll(".md-def-footnote>.md-def-name")
for (var i=0;i<rfns.length;i++) { 
    let c = rfns[i].textContent
    rfns[i].textContent = m.get(c)
}


// update figure cnt
let arr = document.querySelectorAll('h1.md-heading,[name^="fig"],[name^="table"]')
let h1cnt = 0
let figCnt = 0
let tableCnt = 0
let regexFig = /^fig:/;
let regexTable = /^table:/;
for (var i=0;i<arr.length;i++) { 
    if (arr[i].tagName == "H1") {
        h1cnt++
    }
    let name = arr[i].getAttribute("name") 
    if (regexFig.test(name)) {
        figCnt++;
        arr[i].setAttribute("number", "Fig-"+h1cnt+"."+figCnt)
    }
    if (regexTable.test(name)) {
        tableCnt++;
        arr[i].setAttribute("number", "Table"+h1cnt+"."+tableCnt)
    }
}

// get all reference
let figRefs = document.querySelectorAll('a[href^="#fig"]')
for (var i=0;i<figRefs.length;i++) { 
    refName = figRefs[i].getAttribute('href').split("#")[1]
    refNode = document.querySelector('[name="'+refName+'"]')
    // 还是直接设置textContent比较好
    refNum = refNode.getAttribute("number")
    figRefs[i].textContent = figRefs[i].textContent.replace(/^fig.*/i, refNum)
}

