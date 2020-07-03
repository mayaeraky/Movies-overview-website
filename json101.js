const fs = require('fs')

let book = {
    author : 'Dickens',
    title : 'a tale of two cities'
}

//console.log(book.author)

let bookjson = JSON.stringify(book)
//console.log(bookjson)

//let parsedData = JSON.parse(bookjson)
//console.log(parsedData.title)

//fs.writeFileSync('book.json', bookjson)

let data = fs.readFileSync('book.json')
let StringData = data.toString()
let parsedData = JSON.parse(StringData)


console.log(parsedData.title)